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

require 'rubygems'
require 'restclient'
require 'nokogiri'
require 'digest/md5'
require 'json'

module RHEVM

  # NOTE: Injected file will be available in floppy drive inside
  #       the instance. (Be sure you 'modprobe floppy' on Linux)
  FILEINJECT_PATH = "deltacloud-user-data.txt"

  def self.client(url)
    RestClient::Resource.new(url)
  end

  class BackendVersionUnsupportedException < StandardError; end
  class RHEVMBackendException < StandardError
    def initialize(message)
      @message = message
      super
    end

    def message
      @message
    end
  end

  class Client

    attr_reader :credentials, :api_entrypoint

    def initialize(username, password, api_entrypoint)
      @credentials = { :username => username, :password => password }
      @api_entrypoint = api_entrypoint
    end

    def vms(opts={})
      headers = {
        :accept => "application/xml; detail=disks; detail=nics; detail=hosts"
      }
      headers.merge!(auth_header)
      if opts[:id]
        vm = Client::parse_response(RHEVM::client(@api_entrypoint)["/vms/%s" % opts[:id]].get(headers)).root
        [ RHEVM::VM::new(self, vm)]
      else
        Client::parse_response(RHEVM::client(@api_entrypoint)["/vms"].get(headers)).xpath('/vms/vm').collect do |vm|
          RHEVM::VM::new(self, vm)
        end
      end
    end

    def vm_action(id, action, headers={})
      headers.merge!(auth_header)
      headers.merge!({:accept => 'application/xml'})
      if action==:delete
        RHEVM::client(@api_entrypoint)["/vms/%s" % id].delete(headers)
      else
        headers.merge!({ :content_type => 'application/xml' })
        begin
          client_response = RHEVM::client(@api_entrypoint)["/vms/%s/%s" % [id, action]].post('<action/>', headers)
        rescue
          if $!.is_a?(RestClient::BadRequest)
            fault = (Nokogiri::XML($!.http_body)/'//fault/detail')
            fault = fault.text.gsub(/\[|\]/, '') if fault
          end
          fault ||= $!.message
          raise RHEVMBackendException::new(fault)
        end
        xml_response = Client::parse_response(client_response)

        return false if (xml_response/'action/status').first.text.strip.upcase!="COMPLETE"
      end
      return true
    end

    def api_version?(major)
      headers = {
        :content_type => 'application/xml',
        :accept => 'application/xml'
      }
      headers.merge!(auth_header)
      result_xml = Nokogiri::XML(RHEVM::client(@api_entrypoint)["/"].get(headers))
      (result_xml/'/api/system_version').first[:major].strip == major
    end

    def cluster_version?(cluster_id, major)
      headers = {
        :content_type => 'application/xml',
        :accept => 'application/xml'
      }
      headers.merge!(auth_header)
      result_xml = Nokogiri::XML(RHEVM::client(@api_entrypoint)["/clusters/%s" % cluster_id].get(headers))
      (result_xml/'/cluster/version').first[:major].strip == major
    end

    def create_vm(template_id, opts={})
      opts ||= {}
      builder = Nokogiri::XML::Builder.new do
        vm {
          name opts[:name] || "i-#{Time.now.to_i}"
          template_(:id => template_id)
          cluster(:id => opts[:realm_id].empty? ? clusters.first.id : opts[:realm_id])
          type_ opts[:hwp_id] || 'desktop'
          memory opts[:hwp_memory] ? (opts[:hwp_memory].to_i*1024*1024).to_s : (512*1024*1024).to_s
          cpu {
            topology( :cores => (opts[:hwp_cpu] || '1'), :sockets => '1' )
          }
          if opts[:user_data] and not opts[:user_data].empty?
            if api_version?('3') and cluster_version?((opts[:realm_id] || clusters.first.id), '3')
              custom_properties {
                #
                # FIXME: 'regexp' parameter is just a temporary workaround. This
                # is a reported and verified bug and should be fixed in next
                # RHEV-M release.
                #
                custom_property({
                  :name => "floppyinject",
                  :value => "#{RHEVM::FILEINJECT_PATH}:#{opts[:user_data]}",
                  :regexp => "^([^:]+):(.*)$"})
              }
            else
              raise BackendVersionUnsupportedException.new
            end
          end
        }
      end
      headers = opts[:headers] || {}
      headers.merge!({
        :content_type => 'application/xml',
        :accept => 'application/xml',
      })
      headers.merge!(auth_header)
      begin
        vm = RHEVM::client(@api_entrypoint)["/vms"].post(Nokogiri::XML(builder.to_xml).root.to_s, headers)
      rescue
        if $!.respond_to?(:http_body)
          fault = (Nokogiri::XML($!.http_body)/'/fault/detail').first
          fault = fault.text.gsub(/\[|\]/, '') if fault
        end
        fault ||= $!.message
        raise RHEVMBackendException::new(fault)
      end
      RHEVM::VM::new(self, Nokogiri::XML(vm).root)
    end

    def create_template(vm_id, opts={})
      opts ||= {}
      builder = Nokogiri::XML::Builder.new do
        template_ {
          name opts[:name]
          description opts[:description]
          vm(:id => vm_id)
        }
      end
      headers = opts[:headers] || {}
      headers.merge!({
        :content_type => 'application/xml',
        :accept => 'application/xml',
      })
      headers.merge!(auth_header)
      template = RHEVM::client(@api_entrypoint)["/templates"].post(Nokogiri::XML(builder.to_xml).root.to_s, headers)
      RHEVM::Template::new(self, Nokogiri::XML(template).root)
    end

    def destroy_template(id, headers={})
      headers.merge!({
        :content_type => 'application/xml',
        :accept => 'application/xml',
      })
      headers.merge!(auth_header)
      RHEVM::client(@api_entrypoint)["/templates/%s" % id].delete(headers)
      return true
    end

    def templates(opts={})
      headers = {
        :accept => "application/xml"
      }
      headers.merge!(auth_header)
      rhevm_templates = RHEVM::client(@api_entrypoint)["/templates"].get(headers)
      Client::parse_response(rhevm_templates).xpath('/templates/template').collect do |t|
        RHEVM::Template::new(self, t)
      end
    end

    def template(template_id)
      headers = {
        :accept => "application/xml"
      }
      headers.merge!(auth_header)
      rhevm_template = RHEVM::client(@api_entrypoint)["/templates/%s" % template_id].get(headers)
      RHEVM::Template::new(self, Client::parse_response(rhevm_template).root)
    end

    def clusters(opts={})
      headers = {
        :accept => "application/xml; detail=datacenters"
      }
      headers.merge!(auth_header)
      if opts[:id]
        vm = Client::parse_response(RHEVM::client(@api_entrypoint)["/clusters/%s" % opts[:id]].get(headers)).root
        [ RHEVM::Cluster::new(self, vm)]
      else
        Client::parse_response(RHEVM::client(@api_entrypoint)["/clusters"].get(headers)).xpath('/clusters/cluster').collect do |vm|
          RHEVM::Cluster::new(self, vm) if has_datacenter?(vm)
        end.compact
      end
    end

    def datacenters(opts={})
      headers = {
        :accept => "application/xml"
      }
      headers.merge!(auth_header)
      rhevm_datacenters = RHEVM::client(@api_entrypoint)["/datacenters"].get(headers)
      Client::parse_response(rhevm_datacenters).xpath('/data_centers/data_center').collect do |dc|
        RHEVM::DataCenter::new(self, dc)
      end
    end

    def datacenter(datacenter_id)
      headers = {
        :accept => "application/xml"
      }
      headers.merge!(auth_header)
      rhevm_datacenter = RHEVM::client(@api_entrypoint)["/datacenters/%s" % datacenter_id].get(headers)
      RHEVM::DataCenter::new(self, Client::parse_response(rhevm_datacenter).root)
    end

    def hosts(opts={})
      headers = {
        :accept => "application/xml"
      }
      headers.merge!(auth_header)
      if opts[:id]
        vm = Client::parse_response(RHEVM::client(@api_entrypoint)["/hosts/%s" % opts[:id]].get(headers)).root
        [ RHEVM::Host::new(self, vm)]
      else
        Client::parse_response(RHEVM::client(@api_entrypoint)["/hosts"].get(headers)).xpath('/hosts/host').collect do |vm|
          RHEVM::Host::new(self, vm)
        end
      end
    end

    def storagedomains(opts={})
      headers = {
        :accept => "application/xml"
      }
      headers.merge!(auth_header)
      if opts[:id]
        vm = Client::parse_response(RHEVM::client(@api_entrypoint)["/storagedomains/%s" % opts[:id]].get(headers)).root
        [ RHEVM::StorageDomain::new(self, vm)]
      else
        Client::parse_response(RHEVM::client(@api_entrypoint)["/storagedomains"].get(headers)).xpath('/storage_domains/storage_domain').collect do |vm|
          RHEVM::StorageDomain::new(self, vm)
        end
      end
    end

    def auth_header
      # As RDOC says this is the function for strict_encode64:
      encoded_credentials = ["#{@credentials[:username]}:#{@credentials[:password]}"].pack("m0").gsub(/\n/,'')
      { :authorization => "Basic " + encoded_credentials }
    end

    def base_url
      url = URI.parse(@api_entrypoint)
      "#{url.scheme}://#{url.host}:#{url.port}"
    end

    def self.parse_response(response)
      Nokogiri::XML(response)
    end

    def has_datacenter?(vm)
      value=!(vm/'data_center').empty?
      value
    end
  end

  class BaseObject
    attr_accessor :id, :href, :name
    attr_reader :client

    def initialize(client, id, href, name)
      @id, @href, @name = id, href, name
      @client = client
      self
    end
  end

  class Link
    attr_accessor :id, :href, :client

    def initialize(client, id, href)
      @id, @href = id, href
      @client = client
    end

    def follow
      xml = Client::parse_response(RHEVM::client(@client.base_url)[@href].get(@client.auth_header))
      object_class = ::RHEVM.const_get(xml.root.name.camelize)
      object_class.new(@client, (xml.root))
    end

  end

  class VM < BaseObject
    attr_reader :description, :status, :memory, :profile, :display, :host, :cluster, :template, :macs
    attr_reader :storage, :cores, :username, :creation_time
    attr_reader :ip, :vnc

    def initialize(client, xml)
      super(client, xml[:id], xml[:href], (xml/'name').first.text)
      @username = client.credentials[:username]
      parse_xml_attributes!(xml)
      self
    end

    private

    def parse_xml_attributes!(xml)
      @description = ((xml/'description').first.text rescue '')
      @status = (xml/'status').first.text
      @memory = (xml/'memory').first.text
      @profile = (xml/'type').first.text
      @template = Link::new(@client, (xml/'template').first[:id], (xml/'template').first[:href])
      @host = Link::new(@client, (xml/'host').first[:id], (xml/'host').first[:href]) rescue nil
      @cluster = Link::new(@client, (xml/'cluster').first[:id], (xml/'cluster').first[:href])
      @display = {
        :type => (xml/'display/type').first.text,
        :address => ((xml/'display/address').first.text rescue nil),
        :port => ((xml/'display/port').first.text rescue nil),
        :monitors => (xml/'display/monitors').first.text
      }
      @cores = ((xml/'cpu/topology').first[:cores] rescue nil)
      @storage = ((xml/'disks/disk/size').first.text rescue nil)
      @macs = (xml/'nics/nic/mac').collect { |mac| mac[:address] }
      @creation_time = (xml/'creation_time').text
      @ip = ((xml/'guest_info/ip').first[:address] rescue nil)
      @vnc = {
        :address => ((xml/'display/address').first.text rescue "127.0.0.1"),
        :port => ((xml/'display/port').first.text rescue "5890")
      } unless @ip
    end

  end

  class Template < BaseObject
    attr_reader :description, :status, :cluster

    def initialize(client, xml)
      super(client, xml[:id], xml[:href], (xml/'name').first.text)
      parse_xml_attributes!(xml)
      self
    end

    private

    def parse_xml_attributes!(xml)
      @description = ((xml/'description').first.text rescue nil)
      @status = (xml/'status').first.text
      @cluster = Link::new(@client, (xml/'cluster').first[:id], (xml/'cluster').first[:href])
    end
  end

  class Cluster < BaseObject
    attr_reader :description, :datacenter

    def initialize(client, xml)
      super(client, xml[:id], xml[:href], (xml/'name').first.text)
      parse_xml_attributes!(xml)
      self
    end

    private

    def parse_xml_attributes!(xml)
      @description = ((xml/'description').first.text rescue nil)
      @datacenter = Link::new(@client, (xml/'data_center').first[:id], (xml/'data_center').first[:href])
    end

  end

  class DataCenter < BaseObject
    attr_reader :description, :status

    def initialize(client, xml)
      super(client, xml[:id], xml[:href], (xml/'name').first.text)
      parse_xml_attributes!(xml)
      self
    end

    private

    def parse_xml_attributes!(xml)
      @description = ((xml/'description').first.text rescue nil)
      @status = (xml/'status').first.text
    end
  end

  class Host < BaseObject
    attr_reader :description, :status, :cluster

    def initialize(client, xml)
      super(client, xml[:id], xml[:href], (xml/'name').first.text)
      parse_xml_attributes!(xml)
      self
    end

    private

    def parse_xml_attributes!(xml)
      @description = ((xml/'description').first.text rescue nil)
      @status = (xml/'status').first.text
      @clister = Link::new(@client, (xml/'cluster').first[:id], (xml/'cluster').first[:href])
    end
  end

  class StorageDomain < BaseObject
    attr_reader :available, :used, :kind, :address, :path

    def initialize(client, xml)
      super(client, xml[:id], xml[:href], (xml/'name').first.text)
      parse_xml_attributes!(xml)
      self
    end

    private

    def parse_xml_attributes!(xml)
      @available = (xml/'available').first.text
      @used = (xml/'used').first.text
      @kind = (xml/'storage/type').first.text
      @address = ((xml/'storage/address').first.text rescue nil)
      @path = ((xml/'storage/path').first.text rescue nil)
    end
  end

end

class String
  unless method_defined?(:camelize)
    # Camelize converts strings to UpperCamelCase
    def camelize
      self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end
