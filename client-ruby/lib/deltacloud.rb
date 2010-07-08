require 'uri'
require 'net/http'
require 'logger'
require 'rexml/document'

require 'models/flavor'
require 'models/image'
require 'models/instance'

class DeltaCloud

  attr_accessor :logger
  attr_reader :api_uri
  attr_reader :entry_points

  def initialize(name, password, api_uri, &block)
    @logger       = Logger.new( STDERR ) 
    @name         = name
    @password     = password
    @api_uri      = URI.parse( api_uri )
    @entry_points = {}
    connect( &block ) if ( block )
  end

  def connect(&block)
    @http = Net::HTTP.new( api_host, api_port )
    discover_entry_points
    block.call( self ) if block
  end

  def flavors(opts={})
    flavors = []
    request( entry_points[:flavors] ) do |response|
      if ( response.is_a?( Net::HTTPSuccess ) )
        doc = REXML::Document.new( response.body )
        doc.get_elements( 'flavors/flavor' ).each do |flavor|
          uri = flavor.attributes['href']
          flavors << Flavor.new( self, uri, flavor )
        end
      end
    end
    flavors 
  end

  def images(opts={})
    images = []
    request_path = entry_points[:images]
    request( request_path, :get, opts ) do |response|
      if ( response.is_a?( Net::HTTPSuccess ) )
        doc = REXML::Document.new( response.body )
        doc.get_elements( 'images/image' ).each do |image|
          uri = image.attributes['href']
          images << Image.new( self, uri, image )
        end
      end
    end
    images
  end

  def image(id)
    request( entry_points[:images], :get, {:id=>id } ) do |response|
      if ( response.is_a?( Net::HTTPSuccess ) )
        doc = REXML::Document.new( response.body )
        doc.get_elements( 'images/image' ).each do |instance|
          uri = instance.attributes['href']
          return Image.new( self, uri, instance )
        end
      end
    end
    nil
  end

  def fetch_image(uri)
    return Image.new( self, uri, fetch_resource( :image, uri ) )
  end

  def instances()
    instances = []
    request( entry_points[:instances] ) do |response|
      if ( response.is_a?( Net::HTTPSuccess ) )
        doc = REXML::Document.new( response.body )
        doc.get_elements( 'instances/instance' ).each do |instance|
          uri = instance.attributes['href']
          instances << Instance.new( self, uri, instance )
        end
      end
    end
    instances
  end

  def instance(id)
    request( entry_points[:instances], :get, {:id=>id } ) do |response|
      if ( response.is_a?( Net::HTTPSuccess ) )
        doc = REXML::Document.new( response.body )
        doc.get_elements( 'instances/instance' ).each do |instance|
          uri = instance.attributes['href']
          return Instance.new( self, uri, instance )
        end
      end
    end
    nil
  end

  def fetch_instance(uri)
    return Instance.new( self, uri, fetch_resource( :instance, uri ) )
  end

  def create_instance(image_id, flavor_id)
    request( entry_points[:instances], :post, {}, { 'image_id'=>image_id, 'flavor_id'=>flavor_id} ) do |response|
      if ( response.is_a?( Net::HTTPSuccess ) )
        doc = REXML::Document.new( response.body )
        instance = doc.root
        uri = instance.attributes['href']
        return Instance.new( self, uri, instance )
      end
    end  
  end

  def fetch_resource(type, uri)
    request( uri ) do |response|
      doc = REXML::Document.new( response.body )
      if ( doc.root.name == type.to_s )
        return doc.root 
      end
    end
    nil
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

  private

  attr_reader :http

  def build_hash(elem)
    hash = {}
    elem.elements.each do |element|
      key = element.name.gsub( /-/, '_' ).to_sym
      value = element.text || element.attributes['href']
      hash[key] = value
    end
    hash
  end

  def discover_entry_points()
    @entry_points = {}
    logger << "Discoverying entry points at #{@api_uri}\n"
    request do |response|
      if ( response.is_a?( Net::HTTPSuccess ) )
        doc = REXML::Document.new( response.body )
        doc.get_elements( 'api/link' ).each do |link|
          rel = link.attributes['rel']
          uri = link.attributes['href']
          @entry_points[rel.to_sym] = uri
        end
      end
    end
  end

  def request(path='', method=:get, query_args={}, form_data={}, &block)
    if ( path =~ /^http/ ) 
      request_path = path
    else
      request_path = "#{api_path}#{path}"
    end
    query_string = query_args.keys.collect{|key| "#{key}=#{query_args[key]}"}.join("&")
    if ( query_string != '' )
      request_path += "?#{query_string}"
    end
     
    logger << "Request [#{method.to_s.upcase} #{request_path}]\n"
    request = eval( "Net::HTTP::#{method.to_s.capitalize}" ).new( request_path )
    request.basic_auth( @name, @password )
    if ( method == :post )
      request.set_form_data( form_data )
    end
    request['Accept'] = 'text/xml'
    http.request( request, &block )
  end

end
