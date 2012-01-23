require 'rubygems'
require 'nokogiri'

ENV['API_DRIVER'] = 'mock'
ENV['API_FRONTEND'] = 'cimi'
ENV.delete('API_VERBOSE')

$top_srcdir = File.join(File.dirname(__FILE__), '..', '..', '..', '..')
$:.unshift File.join($top_srcdir, 'lib')

load File.join($top_srcdir, 'lib', 'cimi', 'server.rb')

require 'rack/test'

def last_xml_response
  Nokogiri::XML(last_response.body)
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

def app
  Sinatra::Application
end
