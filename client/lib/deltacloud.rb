#
# Copyright (C) 2009  Red Hat, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require 'rest_client'
require 'rexml/document'
require 'logger'
require 'dcloud/flavor'
require 'dcloud/realm'
require 'dcloud/image'
require 'dcloud/instance'
require 'dcloud/storage_volume'
require 'dcloud/storage_snapshot'
require 'dcloud/state'
require 'dcloud/transition'
require 'base64'

class DeltaCloud

  attr_accessor :logger
  attr_reader   :api_uri
  attr_reader   :entry_points
  attr_reader   :driver_name
  attr_reader   :last_request_xml
  attr_reader   :features

  def self.driver_name(url)
    DeltaCloud.new( nil, nil, url) do |client|
      return client.driver_name
    end
  end

  def initialize(name, password, api_uri, opts={}, &block)
    @logger       = Logger.new( STDERR )
    @name         = name
    @password     = password
    @api_uri      = URI.parse( api_uri )
    @entry_points = {}
    @verbose      = opts[:verbose]
    @features = {}
    discover_entry_points
    connect( &block )
    self
  end


  def connect(&block)
    @http = RestClient::Resource.new( api_uri.to_s , :accept => 'application/xml' )
    discover_entry_points
    block.call( self ) if block
    self
  end

  def api_host
    @api_uri.host
  end

  def api_port
    @api_uri.port
  end

  def api_path
    @api_uri.path
  end

  def feature?(collection, name)
    @features.has_key?(collection) && @features[collection].include?(name)
  end

  def flavors(opts={})
    flavors = []
    request(entry_points[:flavors], :get, opts) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'flavors/flavor' ).each do |flavor|
        uri = flavor.attributes['href']
        flavors << DCloud::Flavor.new( self, uri, flavor )
      end
    end
    flavors
  end

  def flavor(id)
    request( entry_points[:flavors], :get, {:id=>id } ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( '/flavor' ).each do |flavor|
        uri = flavor.attributes['href']
        return DCloud::Flavor.new( self, uri, flavor )
      end
    end
  end

  def fetch_flavor(uri)
    xml = fetch_resource( :flavor, uri )
    return DCloud::Flavor.new( self, uri, xml ) if xml
    nil
  end

  def fetch_resource(type, uri)
    request( uri ) do |response|
      doc = REXML::Document.new( response )
      if ( doc.root && ( doc.root.name == type.to_s.gsub( /_/, '-' ) ) )
        return doc.root
      end
    end
    nil
  end

  def fetch_documentation(collection, operation=nil)
    response = @http["docs/#{collection}#{operation ? "/#{operation}" : ''}"].get(:accept => "application/xml")
    doc = REXML::Document.new( response.to_s )
    if operation.nil?
      docs = {
        :name => doc.get_elements('docs/collection').first.attributes['name'],
        :description => doc.get_elements('docs/collection/description').first.text,
        :operations => []
      }
      doc.get_elements('docs/collection/operations/operation').each do |operation|
        p = {}
        p[:name] = operation.attributes['name']
        p[:description] = operation.get_elements('description').first.text
        p[:parameters] = []
        operation.get_elements('parameter').each do |param|
          p[:parameters] << param.attributes['name']
        end
        docs[:operations] << p
      end
    else
      docs = {
        :name => doc.get_elements('docs/operation').attributes['name'],
        :description => doc.get_elements('docs/operation/description').first.text,
        :parameters => []
      }
      doc.get_elements('docs/operation/parameter').each do |param|
        docs[:parameters] << param.attributes['name']
      end
    end
    docs
  end

  def instance_states
    states = []
    request( entry_points[:instance_states] ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'states/state' ).each do |state_elem|
        state = DCloud::State.new( state_elem.attributes['name'] )
        state_elem.get_elements( 'transition' ).each do |transition_elem|
          state.transitions << DCloud::Transition.new(
                                 transition_elem.attributes['to'],
                                 transition_elem.attributes['action']
                               )
        end
        states << state
      end
    end
    states
  end

  def instance_state(name)
    found = instance_states.find{|e| e.name.to_s == name.to_s}
    found
  end

  def realms(opts={})
    realms = []
    request( entry_points[:realms], :get, opts ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'realms/realm' ).each do |realm|
        uri = realm.attributes['href']
        realms << DCloud::Realm.new( self, uri, realm )
      end
    end
    realms
  end

  def realm(id)
    request( entry_points[:realms], :get, {:id=>id } ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'realm' ).each do |realm|
        uri = realm.attributes['href']
        return DCloud::Realm.new( self, uri, realm )
      end
    end
    nil
  end

  def fetch_realm(uri)
    xml = fetch_resource( :realm, uri )
    return DCloud::Realm.new( self, uri, xml ) if xml
    nil
  end

  def images(opts={})
    images = []
    request_path = entry_points[:images]
    request( request_path, :get, opts ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'images/image' ).each do |image|
        uri = image.attributes['href']
        images << DCloud::Image.new( self, uri, image )
      end
    end
    images
  end

  def image(id)
    request( entry_points[:images], :get, {:id=>id } ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'image' ).each do |instance|
        uri = instance.attributes['href']
        return DCloud::Image.new( self, uri, instance )
      end
    end
    nil
  end

  def instances(opts={})
    instances = []
    request( entry_points[:instances], :get, opts ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'instances/instance' ).each do |instance|
        uri = instance.attributes['href']
        instances << DCloud::Instance.new( self, uri, instance )
      end
    end
    instances
  end

  def instance(id)
    request( entry_points[:instances], :get, {:id=>id } ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'instance' ).each do |instance|
        uri = instance.attributes['href']
        return DCloud::Instance.new( self, uri, instance )
      end
    end
    nil
  end

  def post_instance(uri)
    request( uri, :post ) do |response|
      return true
    end
    return false
  end

  def fetch_instance(uri)
    xml = fetch_resource( :instance, uri )
    return DCloud::Instance.new( self, uri, xml ) if xml
    nil
  end

  def create_instance(image_id, opts={})
    name = opts[:name]
    realm_id = opts[:realm]
    flavor_id = opts[:flavor]

    params = {}
    ( params[:realm_id] = realm_id ) if realm_id
    ( params[:flavor_id] = flavor_id ) if flavor_id
    ( params[:name] = name ) if name

    params[:image_id] = image_id
    request( entry_points[:instances], :post, {}, params ) do |response|
      doc = REXML::Document.new( response )
      instance = doc.root
      uri = instance.attributes['href']
      return DCloud::Instance.new( self, uri, instance )
    end
  end

  def storage_volumes(opts={})
    storage_volumes = []
    request( entry_points[:storage_volumes] ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'storage-volumes/storage-volume' ).each do |instance|
        uri = instance.attributes['href']
        storage_volumes << DCloud::StorageVolume.new( self, uri, instance )
      end
    end
    storage_volumes
  end

  def storage_volume(id)
    request( entry_points[:storage_volumes], :get, {:id=>id } ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'storage-volume' ).each do |storage_volume|
        uri = storage_volume.attributes['href']
        return DCloud::StorageVolume.new( self, uri, storage_volume )
      end
    end
    nil
  end

  def fetch_storage_volume(uri)
    xml = fetch_resource( :storage_volume, uri )
    return DCloud::StorageVolume.new( self, uri, xml ) if xml
    nil
  end

  def storage_snapshots(opts={})
    storage_snapshots = []
    request( entry_points[:storage_snapshots] ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'storage-snapshots/storage-snapshot' ).each do |instance|
        uri = instance.attributes['href']
        storage_snapshots << DCloud::StorageSnapshot.new( self, uri, instance )
      end
    end
    storage_snapshots
  end

  def storage_snapshot(id)
    request( entry_points[:storage_snapshots], :get, {:id=>id } ) do |response|
      doc = REXML::Document.new( response )
      doc.get_elements( 'storage-snapshot' ).each do |storage_snapshot|
        uri = storage_snapshot.attributes['href']
        return DCloud::StorageSnapshot.new( self, uri, storage_snapshot )
      end
    end
    nil
  end

  def fetch_storage_snapshot(uri)
    xml = fetch_resource( :storage_snapshot, uri )
    return DCloud::StorageSnapshot.new( self, uri, xml ) if xml
    nil
  end

  def fetch_image(uri)
    xml = fetch_resource( :image, uri )
    return DCloud::Image.new( self, uri, xml ) if xml
    nil
  end

  private

  attr_reader :http

  def discover_entry_points
    return if @discovered
    request(api_uri.to_s) do |response|
      doc = REXML::Document.new( response )
      @driver_name = doc.root.attributes['driver']
      doc.get_elements( 'api/link' ).each do |link|
        rel = link.attributes['rel'].to_sym
        uri = link.attributes['href']
        @entry_points[rel] = uri
        @features[rel] ||= []
        link.get_elements('feature').each do |feature|
          @features[rel] << feature.attributes['name'].to_sym
        end
      end
    end
    @discovered = true
  end

  def request(path='', method=:get, query_args={}, form_data={}, &block)
    if ( path =~ /^http/ )
      request_path = path
    else
      request_path = "#{api_uri.to_s}#{path}"
    end
    if query_args[:id]
      request_path += "/#{query_args[:id]}"
      query_args.delete(:id)
    end
    query_string = URI.escape(query_args.collect{|k,v| "#{k}=#{v}"}.join('&'))
    request_path += "?#{query_string}" unless query_string==''
    headers = {
      :authorization => "Basic "+Base64.encode64("#{@name}:#{@password}"),
      :accept => "application/xml"
    }

    logger << "Request [#{method.to_s.upcase}] #{request_path}]\n"  if @verbose

    if method.eql?(:get)
      RestClient.send(method, request_path, headers) do |response|
        @last_request_xml = response
        yield response.to_s
      end
    else
      RestClient.send(method, request_path, form_data, headers) do |response|
        @last_request_xml = response
        yield response.to_s
      end
    end
  end

end
