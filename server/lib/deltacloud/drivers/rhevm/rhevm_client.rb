require 'base64'
require 'restclient'
require 'nokogiri'

module RHEVM

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
      response = RestClient.get(uri, headers).to_s
      response
    end

    def post(uri, params="")
      headers = {
        :authorization => "Basic " + Base64.encode64("#{@username}:#{@password}"),
        :accept => 'application/xml',
        :content_type => 'application/xml'
      }
      params = "<action/>" if params.size==0
      response = RestClient.post(uri, params, headers).to_s
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

    private
    
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
    attr_accessor(:creation_time, :storage)

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
