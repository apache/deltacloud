#
# Copyright (C) 2009  Red Hat, Inc.
#
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

require 'base64'
require 'restclient'
require 'nokogiri'
require 'digest/md5'
require 'json'

module RHEVM

  class FixtureNotFound < Exception; end

  class Client

    attr_reader :base_uri
    attr_reader :host
    attr_reader :entry_points
    attr_reader :username

    # Define a list of supported collections which will be handled automatically
    # by method_missing
    @@COLLECTIONS = [ :templates, :clusters, :storagedomains, :vms, :datacenters ]

    def initialize(username, password, base_uri, opts={})
      @username, @password = username, password
      uri = URI.parse(base_uri)
      @host = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      @base_uri = base_uri
      @entry_points = {}
      discover_entry_points()
    end

    def method_missing(method_name, *args)
      opts = args[0] if args[0].class.eql?(Hash)
      opts ||= {}
      if @@COLLECTIONS.include?(method_name.to_sym)
        if opts[:id]
          object = Nokogiri::XML(get("#{@entry_points[method_name.to_s]}#{opts[:id]}"))
          element = method_name.to_s
          element = 'data_centers' if method_name.eql?(:datacenters)
          @current_element = element
          inst = ::RHEVM.const_get(element.classify)
          return inst::new(self, object)
        else
          objects = Nokogiri::XML(get(@entry_points[method_name.to_s]))
          objects_arr = []
          element = method_name.to_s
          # FIXME:
          # This is an exception/or bug in RHEV-M API:
          # (uri is /datacenters but root element it 'data_centers')
          element = 'data_centers' if method_name.eql?(:datacenters)
          element = 'storage_domains' if method_name.eql?(:storagedomains)
          @current_element = element
          (objects/"#{element}/#{element.singularize}").each do |item|
            inst = ::RHEVM.const_get(element.classify)
            objects_arr << inst.new(self, item)
          end
          return objects_arr
        end
      end
    end

    def vm_action(action, vm)
      response = post("#{@base_uri}/vms/#{vm}/%s" % action)
      Nokogiri::XML(response)
    end

    def create_vm(opts="")
      Nokogiri::XML(post("#{@base_uri}/vms", opts))
    end

    def delete_vm(id)
      delete("#{@base_uri}/vms/#{id}")
    end

    def delete(uri)
      headers = {
        :authorization => "Basic " + Base64.encode64("#{@username}:#{@password}"),
        :accept => 'application/xml',
      }
      RestClient.delete(uri, headers).to_s
    end

    def get(uri)
      headers = {
        :authorization => "Basic " + Base64.encode64("#{@username}:#{@password}"),
        :accept => 'application/xml',
      }
      if ENV['RACK_ENV'] == 'test'
        response = mock_request(:get, uri, {}, headers)
      else
        response = RestClient.get(uri, headers).to_s
      end
      response
    end

    def post(uri, params="")
      headers = {
        :authorization => "Basic " + Base64.encode64("#{@username}:#{@password}"),
        :accept => 'application/xml',
        :content_type => 'application/xml'
      }
      params = "<action/>" if params.size==0
      if ENV['RACK_ENV'] == 'test'
        response = mock_request(:post, uri, params, headers)
      else
        response = RestClient.post(uri, params, headers).to_s
      end
      response
    end

    def discover_entry_points()
      return if @discovered
      doc = Nokogiri.XML(get(@base_uri))
      doc.xpath('api/link').each() do |link|
        @entry_points[link['rel']] = @host + link['href']
      end
      @discovered = true
    end

    def read_fake_url(filename)
      fixture_file = "../tests/rhevm/support/fixtures/#{filename}"
      if File.exists?(fixture_file)
        puts "Using fixture: #{fixture_file}"
        return JSON::parse(File.read(fixture_file))
      else
        raise FixtureNotFound.new
      end
    end

    def mock_request(*args)
      http_method, request_uri, params, headers = args[0].to_sym, args[1], args[2], args[3]
      params ||= {}
      fixture_filename = "#{Digest::MD5.hexdigest("#{http_method}#{request_uri}#{params.inspect}#{headers}")}.fixture"
      begin
        read_fake_url(fixture_filename)[2]["body"]
      rescue FixtureNotFound
        if http_method.eql?(:get)
          r = RestClient.send(http_method, request_uri, headers)
        elsif http_method.eql?(:post)
          r = RestClient.send(http_method, request_uri, params, headers)
        else
          r = RestClient.send(http_method, request_uri, headers)
        end
        response = {
          :body => r.to_s,
          :status => r.code,
          :content_type => r.headers[:content_type]
        }
        fixtures_dir = "../tests/rhevm/support/fixtures/"
        FileUtils.mkdir_p(fixtures_dir)
        puts "Saving fixture #{fixture_filename}"
        File.open(File::join(fixtures_dir, fixture_filename), 'w') do |f|
          f.puts [request_uri, http_method, response].to_json
        end and retry
      end
    end

    def singularize(str)
      str.gsub(/s$/, '')
    end

  end

  class BaseModel
    attr_accessor(:id, :href, :name)

    def initialize(client, xml)
      @client = client
      @id = xml[:id]
      @href = "#{@client.base_uri}#{xml[:href]}"
      @name = xml.xpath('name').text
    end
  end

  class StorageDomain < BaseModel
    attr_accessor(:status, :storage_type, :storage_address, :storage_path)
    attr_accessor(:name, :available, :used, :kind)

    def initialize(client, xml)
      super(client, xml)
      @kind = xml.xpath('type').text
      @name = xml.xpath('name').text
      @storage_type = xml.xpath('storage/type').text
      @storage_address = xml.xpath('storage/address').text
      @storage_path = xml.xpath('storage/path').text
      @address = xml.xpath('storage/address').text
      @available = xml.xpath('available').text.to_f
      @used= xml.xpath('used').text.to_f
    end
  end

  class Vm < BaseModel
    attr_accessor(:status, :memory, :sockets, :cores, :bootdevs, :host, :cluster, :template, :vmpool, :profile)
    attr_accessor(:creation_time, :storage, :nics, :display)

    def initialize(client, xml)
      super(client, xml)
      @status = xml.xpath('status').text
      @memory = xml.xpath('memory').text.to_f
      @profile = xml.xpath('type').text
      @sockets = xml.xpath('cpu/topology').first[:sockets] rescue ''
      @cores = xml.xpath('cpu/topology').first[:cores] rescue ''
      @bootdevs = []
      xml.xpath('os/boot').each do |boot|
        @bootdevs << boot[:dev]
      end
      @host = xml.xpath('host')[:id]
      @cluster = xml.xpath('cluster').first[:id]
      @template = xml.xpath('template').first[:id]
      @vmpool = xml.xpath('vmpool').first[:id] if xml.xpath('vmpool').size >0
      @creation_time = xml.xpath('creation_time').text
      storage_link = xml.xpath('link[@rel="disks"]').first[:href]
      disks_response = Nokogiri::XML(client.get("#{client.host}#{storage_link}"))
      @storage = disks_response.xpath('disks/disk/size').collect { |s| s.text.to_f }
      @storage = @storage.inject(nil) { |p, i| p ? p+i : i }
      @display = {
        :type => (xml/'display/type').text,
        :address => (xml/'display/address').text,
        :port => (xml/'display/port').text
      } if (xml/'display')
      @nics = get_nics(client, xml)
      self
    end

    private

    def get_nics(client, xml)
      nics = []
      doc = Nokogiri::XML(client.get(client.host + (xml/'link[@rel="nics"]').first[:href]))
      (doc/'nics/nic').each do |nic|
        nics << {
          :mac => (nic/'mac').first[:address],
          :address => (nic/'ip').first ? (nic/'ip').first[:address]  : nil
        }
      end
      nics
    end

  end

  class Template < BaseModel
    attr_accessor(:status, :memory, :name, :description)
    
    def initialize(client, xml)
      super(client, xml)
      @status = (xml/'status').text
      @memory = (xml/'memory').text
      @description = (xml/'description').text
    end
  end

  class DataCenter < BaseModel
    attr_accessor :name, :storage_type, :description, :status

    def initialize(client, xml)
      super(client, xml)
      @name, @storage_type, @description = (xml/'name').text, (xml/'storage_type').text, (xml/'description').text
      @status = (xml/'status').text
    end
  end

  class Cluster < BaseModel
    attr_accessor :name, :datacenter_id, :cpu

    def initialize(client, xml)
      super(client, xml)
      @name = (xml/'name').text
      @datacenter_id = (xml/'data_center').first['id']
      @cpu = (xml/'cpu').first['id']
      @name = (xml/'name').text
    end
  end

end

class String

  unless method_defined?(:classify)
    # Create a class name from string
    def classify
      self.singularize.camelize
    end
  end

  unless method_defined?(:camelize)
    # Camelize converts strings to UpperCamelCase
    def camelize
      self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end

  unless method_defined?(:singularize)
    # Strip 's' character from end of string
    def singularize
      self.gsub(/s$/, '')
    end
  end

  # Convert string to float if string value seems like Float
  def convert
    return self.to_f if self.strip =~ /^([\d\.]+$)/
    self
  end

  # Simply converts whitespaces and - symbols to '_' which is safe for Ruby
  def sanitize
    self.strip.gsub(/(\W+)/, '_')
  end

end
