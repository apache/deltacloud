require 'rubygems'
require 'nokogiri'
require 'rack/test'

ENV['API_FRONTEND'] = 'cimi'

load File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'lib', 'deltacloud_rack.rb')

Deltacloud::configure do |server|
  server.root_url '/cimi'
  server.version '1.0.0'
  server.klass 'CIMI::API'
end.require_frontend!

def last_xml_response
  Nokogiri::XML(last_response.body)
end

class IndexEntrypoint < Sinatra::Base
  get "/" do
    redirect Deltacloud[:root_url], 301
  end
end

=begin
def app
  Rack::URLMap.new(
    "/" => IndexEntrypoint.new,
    Deltacloud[:root_url] => CIMI::API,
    "/stylesheets" =>  Rack::Directory.new( "public/stylesheets" ),
    "/javascripts" =>  Rack::Directory.new( "public/javascripts" )
  )
end
=end

def app
  Rack::Builder.new {
    map '/' do
      use Rack::Static, :urls => ["/stylesheets", "/javascripts"], :root => "public"
      run Rack::Cascade.new([CIMI::API])
    end
  }
end

def new_machine
  @@new_machine
end

def set_new_machine(machine)
  @@new_machine = machine
end

class String

  def to_class_name
    to_collection_name
  end

  def to_entity_name
    to_collection_name.uncapitalize
  end

  def to_collection_name
    self.tr(' ', '').singularize
  end

  def to_collection_uri
    self.tr(' ', '_').downcase
  end

  def to_entity_uri
    to_collection_uri.pluralize
  end

end
