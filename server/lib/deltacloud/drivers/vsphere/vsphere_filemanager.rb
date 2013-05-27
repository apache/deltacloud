# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#

require 'nokogiri'

module VSphere
  module FileManager


  DIRECTORY_PATH="deltacloud"
  MKISOFS_EXECUTABLE="mkisofs"
  # This value is setted in this way because
  # mkisofs man said, less than this amount
  # he have to pad the content of the iso file
  # that mean a limit of 400 kb file since
  # 1 sector of iso file = 2048 bytes
  ISO_SECTORS=202

  RbVmomi::VIM::Datastore::class_eval do
    def soap
      @soap
    end
  end

  class << self

    def store_iso!(datastore,base64_iso, file_name)
      file = StringIO.new(get_plain_iso(base64_iso).read)
      uploadFile(datastore, file, file_name)
    end

    def user_data!(datastore,base64_content,file_name)
      command="#{MKISOFS_EXECUTABLE} -stream-file-name deltacloud-user-data.txt -stream-media-size #{ISO_SECTORS}"
      iso_file=''
      Open3::popen3(command) do |stdin, stdout, stderr|
        stdin.write(base64_content.unpack("m"))
        stdin.close()
        iso_file=StringIO::new(stdout.read)
      end
      uploadFile(datastore,iso_file,file_name)
    end


    def delete_iso!(datastore,file_name)
      deleteFile(datastore, file_name)
    end

    def store_mapping!(datastore, yaml_object, file_name)
      file = StringIO::new(yaml_object)
      uploadFile(datastore, file, file_name)
    end

    def delete_mapping!(datastore, file_name)
      deleteFile(datastore, file_name)
    end

    def load_mapping(datastore, file_name)
      YAML::load(downloadFile(datastore, file_name))
    end

    def list_mappings(datastore)
      listFolder(datastore)
    end

   private

    def make_directory!(datastore,directory)
      dc=datastore.send(:datacenter)
      dc._connection.serviceContent.fileManager.MakeDirectory :name => "[#{datastore.name}] #{directory}",
                                                              :datacenter => dc,
                                                              :createParentDirectories => false
    end

    def _exist?(datastore,file=nil)
      uri = buildUrl(datastore,file) if file
      uri = buildUrl(datastore) unless file
      http = Net::HTTP.new(uri.host,uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      headers = {
        'cookie' => datastore.send(:soap).cookie,
      }
      request = Net::HTTP::Head.new(uri.request_uri,headers)
      res = http.request(request)
      if res.kind_of?(Net::HTTPSuccess)
        return true
      else
        return false
      end
    end

    def downloadFile(datastore,file_name)
      @uri = buildUrl(datastore,file_name)
      http=Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      headers = { 'cookie' => datastore.send(:soap).cookie }
      request = Net::HTTP::Get.new(@uri.request_uri, headers)
      res = http.request(request)
      raise "download failed: #{res.message}" unless res.kind_of?(Net::HTTPSuccess)
      res.body
    end

    def deleteFile(datastore, file)
      @uri = buildUrl(datastore, file)
      http=Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      headers = { 'cookie' => datastore.send(:soap).cookie }
      request = Net::HTTP::Delete.new(@uri.request_uri, headers)
      res = http.request(request)
      unless res.kind_of?(Net::HTTPSuccess) or res.kind_of?(Net::HTTPServiceUnavailable) or res.kind_of?(Net::HTTPNotFound)
        raise "delete failed: #{res.message} #{file}"
      end
    end

    def listFolder(datastore, folder="")
      @uri = buildUrl(datastore, folder)
      http=Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      headers = { 'cookie' => datastore.send(:soap).cookie }
      request = Net::HTTP::Get.new(@uri.request_uri, headers)
      begin
        res = http.request(request)
        Nokogiri::HTML(res.body).css("table tr a").map { |f| f.text.strip }.reject { |f| f == 'Parent Directory'}
      rescue
        []
      end
    end

    def uploadFile(datastore,file,file_name)
      raise "You need to set the realm_id" if datastore.nil?
      make_directory!(datastore,DIRECTORY_PATH) unless _exist?(datastore)
      @uri = buildUrl(datastore,file_name)
      http=Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      headers = {
        'cookie' => datastore.send(:soap).cookie,
        'content-length' => file.size.to_s,
        'Content-Type' => 'application/octet-stream',
      }
      request = Net::HTTP::Put.new(@uri.request_uri, headers)
      request.body_stream = file
      res = http.request(request)
      raise "upload failed: #{res.message}" unless res.kind_of?(Net::HTTPSuccess)
    end

    # return the url like https://<server_address>/folder/<path>/<file_name>?<query_infos>

    def buildUrl(datastore,file="")
      raise "Requested datastore does not exists or misconfigured" unless datastore.respond_to?(:'_connection')
      uri=URI::HTTPS::build(:host=>datastore._connection.http.address)
      uri.path= ["/folder",DIRECTORY_PATH,file].join("/") if file
      query={:dcPath => datastore.send(:datacenter).name, :dsName => datastore.name }
      uri.query=query.collect{|name, value| "#{name}=#{URI.escape value}"}.join("&")
      uri
    end

    def get_plain_iso(stream)
      unbase64file=stream.unpack('m').to_s
      Zlib::GzipReader.new(StringIO.new(unbase64file))
    end

   end

  end
end
