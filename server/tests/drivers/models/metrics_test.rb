require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe Deltacloud::Metric do

  before do
    @metric = Deltacloud::Metric.new(:id => 'metric1', :entity => 'inst1')
  end

  it 'cat be extended by add_property' do
    @metric.add_property :network, { :max => 100, :min => 10, :avg => 50 }
    @metric.properties.wont_be_empty
    @metric.properties.each do |p|
      p.must_be_kind_of Deltacloud::Metric::Property
    end
  end

end
