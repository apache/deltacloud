require 'nokogiri'

module VSphere
  module FileManager


  DIRECTORY_PATH="deltacloud"

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
        puts "[ERROR]: Unable to list deltacloud folder"
        []
      end
    end

    def uploadFile(datastore,file,file_name)
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
