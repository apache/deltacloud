require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

describe InstanceProfile do

  before do
    @instance = InstanceProfile.new(
      'm1-small',
      :hwp_memory => '512',
      :hwp_cpu => '1'
    )
  end

  it 'advertise the overrides' do
    @instance.overrides.keys.must_include :cpu
    @instance.overrides.keys.must_include :memory
  end

end
