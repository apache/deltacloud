require 'uri'
require 'net/http'
require 'logger'
require 'rexml/document'

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
          flavors << convert( :flavor, flavor )
        end
      end
    end
    flavors 
  end

  def images(opts={})
    images = []
    request_path = entry_points[:images]
    if ( opts[:owner] )
      request_path += "?owner=#{opts[:owner]}"
    end
    request( request_path ) do |response|
      if ( response.is_a?( Net::HTTPSuccess ) )
        doc = REXML::Document.new( response.body )
        doc.get_elements( 'images/image' ).each do |image|
          images << convert( :image, image )
        end
      end
    end
    images
  end

  def instances(opts={})
    instances = []
    request( entry_points[:instances] ) do |response|
      if ( response.is_a?( Net::HTTPSuccess ) )
        doc = REXML::Document.new( response.body )
        doc.get_elements( 'instances/instance' ).each do |instance|
          instances << convert( :instance, instance )
        end
      end
    end
    instances
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

  CONVERSIONS = {
    :flavor=>{
      :storage=>:to_f,
      :memory=>:to_f,
    }
  }

  attr_reader :http

  def convert(type, elem)
    hash = {}
    elem.elements.each do |element|
      key = element.name.gsub( /-/, '_' ).to_sym
      value = element.text
      conversions = CONVERSIONS[type]
      ( conversion = conversions[key] ) if conversions
      ( value = value.send( conversion ) ) if conversion
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
          uri = link.text
          @entry_points[rel.to_sym] = uri
        end
      end
    end
  end

  def request(path='', method=:get, &block)
    if ( path =~ /^http/ ) 
      request_path = path
    else
      request_path = "#{api_path}#{path}"
    end
    logger << "Request [#{request_path}]\n"
    request = eval( "Net::HTTP::#{method.to_s.capitalize}" ).new( request_path )
    request.basic_auth( @name, @password )
    request['Accept'] = 'text/xml'
    http.request( request, &block )
  end

end
