require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require 'minitest/autorun'
require_relative './common.rb'

class CIMITestHelper
  def settings; OpenStruct.new(:root_url => '//'); end
  def url(path); '/cimi' + path; end
  include Sinatra::Rabbit::URLFor(CIMI.collections)
end

describe CIMI do

  before do
    @api = CIMITestHelper.new
  end

  it 'generate url helpers for CIMI model' do
    @api.machines_url.must_equal '/cimi/machines'
    @api.machine_url('123').must_equal '/cimi/machines/123'
    @api.machines_url(:format => 'json').must_equal '/cimi/machines?format=json'
  end

  it 'generate proper url for ResourceMetadata' do
    @api.resource_metadata_url.must_equal '/cimi/resource_metadata'
    @api.resource_metadata_url('123').must_equal '/cimi/resource_metadata/123'
    @api.resource_metadata_url(:format => 'json').must_equal '/cimi/resource_metadata/?format=json'
  end

end
