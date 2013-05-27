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
# Author: Dies Koper <diesk@fast.au.fujitsu.com>

require 'xmlsimple'

module Deltacloud
  module Drivers
    module Fgcp

class FgcpClient

  def initialize(cert, key, region = nil, version = '2011-01-31', locale = 'en')
    @version = version
    @locale = locale
    if region.nil?
      cert.subject.to_s =~ /\b[Cc]=(\w\w)\b/
      region = $1.downcase
    end
    # first 'jp' region is now 'jp-east'
    region = 'jp-east' if region == 'jp'
    endpoint = Deltacloud::Drivers::driver_config[:fgcp][:entrypoints]['default'][region] || region

    #proxy settings:
    http_proxy = ENV['http_proxy']
    proxy_uri = URI.parse(http_proxy) if http_proxy

    if proxy_uri
      proxy_addr = proxy_uri.host
      proxy_port = proxy_uri.port
      proxy_user = proxy_uri.user
      proxy_pass = proxy_uri.password
    end

    @uri = URI.parse(endpoint)
    @headers = {'Accept' => 'text/xml', 'User-Agent' => 'OViSS-API-CLIENT'}

    @service = Net::HTTP::Proxy(proxy_addr, proxy_port, proxy_user, proxy_pass).new(@uri.host, @uri.port)
    @service.set_debug_output $stderr if cert.subject.to_s =~ /diesk/ # TODO: use a proper debug mode flag

    # configure client authentication
    @service.use_ssl = (@uri.scheme == 'https')
    @service.key = key
    @service.cert = cert

    # configure server authentication (peer verification)
    ca_certs = ENV['FGCP_CA_CERTS'] # e.g. '/etc/ssl/certs/ca-bundle.crt'
    @service.ca_file = ca_certs if ca_certs and File.file?(ca_certs)
    @service.ca_path = ca_certs if ca_certs and File.directory?(ca_certs)
    @service.verify_mode = (@service.ca_file or @service.ca_path) ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
  end

  ######################################################################
  # API methods
  #####################################################################

  def list_server_types
    #diskImageId is mandatory but value seems to be ignored
    request('ListServerType', {'diskImageId' => 'dummy'})
  end

  def list_vsys
    request('ListVSYS')
  end

  def get_vsys_status(vsys_id)
    request('GetVSYSStatus', {'vsysId' => vsys_id})
  end

  def get_vsys_attributes(vsys_id)
    request('GetVSYSAttributes', {'vsysId' => vsys_id})
  end

  def get_vsys_configuration(vsys_id)
    request('GetVSYSConfiguration', {'vsysId' => vsys_id})
  end

  def list_vsys_descriptor
    request('ListVSYSDescriptor')
  end

  def get_vsys_descriptor_configuration(vsys_descriptor_id)
    request('GetVSYSDescriptorConfiguration', {'vsysDescriptorId' => vsys_descriptor_id})
  end

  def list_vservers(vsys_id)
    request('ListVServer', {'vsysId' => vsys_id})
  end

  def start_vserver(vserver_id)
    request('StartVServer', {'vsysId' => extract_vsys_id(vserver_id), 'vserverId' => vserver_id})
  end

  def stop_vserver(vserver_id, force=false)
    request('StopVServer', {'vsysId' => extract_vsys_id(vserver_id), 'vserverId' => vserver_id, 'force' => force})
  end

  def create_vserver(vserver_name, vserver_type, disk_image_id, network_id)
    request('CreateVServer', {
      'vsysId'      => extract_vsys_id(network_id),
      'vserverName' => vserver_name,
      'vserverType' => vserver_type,
      'diskImageId' => disk_image_id,
      'networkId'   => network_id})
  end

  def create_vservers(vsys_id, vservers_xml)
    @version = '2012-07-20'
    request('CreateMultipleVServer',
      {
        'vsysId'    => vsys_id,
      },
      vservers_xml,
      'vserversXMLFilePath'
    )
  end

  def destroy_vserver(vserver_id)
    request('DestroyVServer', {'vsysId' => extract_vsys_id(vserver_id), 'vserverId' => vserver_id})
  end

  def get_vserver_status(vserver_id)
    request('GetVServerStatus', {'vsysId' => extract_vsys_id(vserver_id), 'vserverId' => vserver_id})
  end

  def get_vserver_initial_password(vserver_id)
    request('GetVServerInitialPassword', {'vsysId' => extract_vsys_id(vserver_id), 'vserverId' => vserver_id})
  end

  def get_vserver_attributes(vserver_id)
    request('GetVServerAttributes', {'vsysId' => extract_vsys_id(vserver_id), 'vserverId' => vserver_id})
  end

  def get_vserver_configuration(vserver_id)
    request('GetVServerConfiguration', {'vsysId' => extract_vsys_id(vserver_id), 'vserverId' => vserver_id})
  end

  def list_disk_images(server_category=nil, vsys_descriptor_id=nil)
    params = {}
    params.merge! 'serverCategory' => server_category if server_category
    params.merge! 'vsysDescriptorId' => vsys_descriptor_id if vsys_descriptor_id

    request('ListDiskImage', params)
  end

  def register_private_disk_image(vserver_id, name, description)
    #TODO: support different attributes for different locales?
    image_descriptor = <<-"eoidxml"
<?xml version="1.0" encoding ="UTF-8"?>
<Request>
  <vserverId>#{vserver_id}</vserverId>
  <locales>
    <locale>
      <lcid>en</lcid>
      <name>#{name}</name>
      <description>#{description}</description>
    </locale>
    <locale>
      <lcid>ja</lcid>
      <name>#{name}</name>
      <description>#{description}</description>
    </locale>
  </locales>
</Request>
eoidxml
    request('RegisterPrivateDiskImage', nil, image_descriptor, 'diskImageXMLFilePath')
  end

  def unregister_disk_image(disk_image_id)
    request('UnregisterDiskImage', {'diskImageId' => disk_image_id})
  end

  def list_efm(vsys_id, efm_type)
    request('ListEFM', {'vsysId' => vsys_id, 'efmType' => efm_type})
  end

  def start_efm(efm_id)
    request('StartEFM', {'vsysId' => extract_vsys_id(efm_id), 'efmId' => efm_id})
  end

  def stop_efm(efm_id)
    request('StopEFM', {'vsysId' => extract_vsys_id(efm_id), 'efmId' => efm_id})
  end

  def create_efm(efm_type, efm_name, network_id)
    request('CreateEFM', {
      'vsysId'    => extract_vsys_id(network_id),
      'efmType'   => efm_type,
      'efmName'   => efm_name,
      'networkId' => network_id}
    )
  end

  def destroy_efm(efm_id)
    request('DestroyEFM', {'vsysId' => extract_vsys_id(efm_id), 'efmId' => efm_id})
  end

  def get_efm_status(efm_id)
    request('GetEFMStatus', {'vsysId' => extract_vsys_id(efm_id), 'efmId' => efm_id})
  end

  def get_efm_configuration(efm_id, configuration_name, configuration_xml=nil)
    request('GetEFMConfiguration',
      {
        'vsysId'            => extract_vsys_id(efm_id),
        'efmId'             => efm_id,
        'configurationName' => configuration_name
      },
      configuration_xml,
      'configurationXMLFilePath'
    )
  end

  def update_efm_configuration(efm_id, configuration_name, configuration_xml=nil)
    request('UpdateEFMConfiguration',
      {
        'vsysId'            => extract_vsys_id(efm_id),
        'efmId'             => efm_id,
        'configurationName' => configuration_name
      },
      configuration_xml,
      'configurationXMLFilePath'
    )
  end

  def list_vdisk(vsys_id)
    request('ListVDisk', {'vsysId' => vsys_id})
  end

  def get_vdisk_status(vdisk_id)
    request('GetVDiskStatus', {'vsysId' => extract_vsys_id(vdisk_id), 'vdiskId' => vdisk_id})
  end

  def get_vdisk_attributes(vdisk_id)
    request('GetVDiskAttributes', {'vsysId' => extract_vsys_id(vdisk_id), 'vdiskId' => vdisk_id})
  end

  def create_vdisk(vsys_id, vdisk_name, size)
    request('CreateVDisk', {'vsysId' => vsys_id, 'vdiskName' => vdisk_name, 'size' => size})
  end

  def destroy_vdisk(vdisk_id)
    request('DestroyVDisk', {'vsysId' => extract_vsys_id(vdisk_id), 'vdiskId' => vdisk_id})
  end

  def attach_vdisk(vserver_id, vdisk_id)
    request('AttachVDisk', {'vsysId' => extract_vsys_id(vserver_id), 'vserverId' => vserver_id, 'vdiskId' => vdisk_id})
  end

  def detach_vdisk(vserver_id, vdisk_id)
    request('DetachVDisk', {'vsysId' => extract_vsys_id(vserver_id), 'vserverId' => vserver_id, 'vdiskId' => vdisk_id})
  end

  def list_vdisk_backup(vdisk_id)
    request('ListVDiskBackup', {'vsysId' => extract_vsys_id(vdisk_id), 'vdiskId' => vdisk_id})
  end

  def backup_vdisk(vdisk_id)
    request('BackupVDisk', {'vsysId' => extract_vsys_id(vdisk_id), 'vdiskId' => vdisk_id})
  end

  def destroy_vdisk_backup(vsys_id, backup_id)
    request('DestroyVDiskBackup', {'vsysId' => vsys_id, 'backupId' => backup_id})
  end

  def get_vdisk_backup_copy_key(vsys_id, backup_id)
    @version = '2012-07-20'
    request('GetVDiskBackupCopyKey', {'vsysId' => vsys_id, 'backupId' => backup_id})
  end

  def set_vdisk_backup_copy_key(vsys_id, backup_id, contracts)
    @version = '2012-07-20'
    contracts_xml = <<-"eoctxml"
<?xml version="1.0" encoding ="UTF-8"?>
<Request>
  <contracts>
    <contract>
#{contracts.collect { |c| "      <number>#{c}</number>" }.join("\n")}
    </contract>
  </contracts>
</Request>
eoctxml
    request('SetVDiskBackupCopyKey',
      {
        'vsysId'   => vsys_id,
        'backupId' => backup_id
      },
      contracts_xml,
      'contractsXMLFilePath'
    )
  end

  def external_restore_vdisk(src_vsys_id, src_backup_id, dst_vsys_id, dst_vdisk_id, key)
    @version = '2012-07-20'
    request('ExternalRestoreVDisk', {
      'srcVsysId'   => src_vsys_id,
      'srcBackupId' => src_backup_id,
      'dstVsysId'   => dst_vsys_id,
      'dstVdiskId'  => dst_vdisk_id,
      'key'         => key}
    )
  end

  def list_public_ips(vsys_id=nil)
    if vsys_id.nil?
      request('ListPublicIP')
    else
      request('ListPublicIP', {'vsysId' => vsys_id})
    end
  end

  def allocate_public_ip(vsys_id)
    request('AllocatePublicIP', {'vsysId' => vsys_id})
  end

  def attach_public_ip(vsys_id, public_ip)
    request('AttachPublicIP', {'vsysId' => vsys_id, 'publicIp' => public_ip})
  end

  def detach_public_ip(vsys_id, public_ip)
    request('DetachPublicIP', {'vsysId' => vsys_id, 'publicIp' => public_ip})
  end

  def free_public_ip(vsys_id, public_ip)
    request('FreePublicIP', {'vsysId' => vsys_id, 'publicIp' => public_ip})
  end

  def create_vsys(vsys_descriptor_id, vsys_name)
    request('CreateVSYS', {'vsysDescriptorId' => vsys_descriptor_id, 'vsysName' => vsys_name})
  end

  def destroy_vsys(vsys_id)
    request('DestroyVSYS', {'vsysId' => vsys_id})
  end

  def get_performance_information(vserver_id, interval, data_type=nil)
    @version = '2012-02-18'
    if data_type.nil?
      request('GetPerformanceInformation', {'vsysId' => extract_vsys_id(vserver_id), 'serverId' => vserver_id, 'interval' => interval})
    else
      request('GetPerformanceInformation', {'vsysId' => extract_vsys_id(vserver_id), 'serverId' => vserver_id, 'dataType' => data_type, 'interval' => interval})
    end
  end

  #extract vsysId from vserverId, efmId or networkId
  def extract_vsys_id(id)
    /^(\w+-\w+)\b.*/ =~ id
    $1
  end

  #extract contract id from vserverId, efmId or networkId
  def extract_contract_id(id)
    /^(\w+)-\w+\b.*/ =~ id
    $1
  end

  private

  # params hash is of the form :vserverId => 'ABC123', etc.
  # uses POST if there is an attachment, else GET
  def request(action, params={}, attachment=nil, attachment_name=nil)
    accesskeyid, signature = generate_accesskeyid
    params ||= {}

    params.merge! :Version     => @version unless params.has_key?(:Version)
    params.merge! :Locale      => @locale  unless params.has_key?(:Locale)
    params.merge! :Action      => action,
                  :AccessKeyId => accesskeyid,
                  :Signature   => signature

    begin
      if attachment.nil?
        @uri.query = encode_params(params)
        resp = @service.request_get(@uri.request_uri, @headers)
      else
        #multipart post
        boundary = "BOUNDARY#{Time.now.to_i}"
        body = create_multipart_body(params, attachment, attachment_name, boundary)
        @headers['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
        @uri.query = nil #clear query params from previous request

        resp = @service.request_post(@uri.request_uri, body, @headers)
      end
    rescue => e
      # special treatment for errors like "Errno::ETIMEDOUT: Connection timed out - connect(2)"? (when proxy not set)
      raise e
    end

#    p resp.body
    # API endpoint only returns HTTPSuccess, so different code means connection issues (http proxy, etc.)
    unless resp.is_a?(Net::HTTPSuccess)
      $stderr.print 'error: ' + $!
      raise $!
    end

    xml = XmlSimple.xml_in(resp.body)
    #check for connection errors, incl. NTP sync and auth related errors
    raise "#{xml['responseStatus'][0]}: #{xml['responseMessage'][0]}" unless xml['responseStatus'].to_s =~ /SUCCESS/

    xml
  end

  def generate_accesskeyid
    t = Time.now
    tz = t.zone
    expires = (t.to_i * 1000.0).to_i
    sig_version = '1.0'
    sig_method = 'SHA1withRSA'

    accesskeyid = Base64.encode64([ tz, expires, sig_version, sig_method ].join('&'))
    signature = Base64.encode64(sign(accesskeyid))

    return accesskeyid, signature
  end

  def encode_params(params)
    params.map {|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
  end

  def sign(data)
    digester = OpenSSL::Digest::SHA1.new
    @service.key.sign(digester, data)
  end

  def create_multipart_body(params, attachment, attachment_name, boundary)
    body = "--#{boundary}\r\n"
    body += "Content-Type: text/xml; charset=UTF-8\r\n"
    body += "Content-Disposition: form-data; name=\"Document\"\r\n"
    body += "\r\n"

    body += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    body += "<OViSSRequest>\n"
    params.each_pair do |k,v|
      body += "  <#{k}>#{v}</#{k}>\n"
    end
    body += "</OViSSRequest>"
    body += "\r\n"

    body += "--#{boundary}\r\n"
    body += "Content-Type: application/octet-stream\r\n"
    body += "Content-Disposition: form-data; name=\"#{attachment_name}\"; filename=\"#{attachment_name}.xml\"\r\n"
    body += "\r\n"
    body += attachment
    body += "\r\n--#{boundary}--"
  end

end
    end
  end
end
