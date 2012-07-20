require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'models', 'base_model.rb')
require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'models', 'instance_profile.rb')

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
