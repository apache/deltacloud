require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'models', 'base_model.rb')
require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'models', 'instance.rb')

describe Instance do

  before do
    @instance = Instance.new(
      :id => 'inst1',
      :create_image => true,
      :name => 'Instance',
      :instance_profile => 'm1-small',
      :state => 'RUNNING'
    )
  end

  it 'advertise if can be used to create image' do
    @instance.can_create_image?.must_equal true
    @instance.create_image = false
    @instance.can_create_image?.must_equal false
  end

  it 'advertise the current state using is_state?' do
    @instance.is_running?.must_equal true
    @instance.is_stopped?.must_equal false
  end

end
