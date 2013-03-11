require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require 'minitest/autorun'
require_relative './common.rb'

describe CIMI::Collections::Volumes do

  def create_model(model_class, attr)
    model = model_class.new(attr)
    svc_class = CIMI::Service::const_get(model_class.name.split('::').last)
    svc_class.new(nil, :model => model).save
    model
  end

  before do
    def app; run_frontend(:cimi) end
    authorize 'mockuser', 'mockpassword'

    @config = create_model CIMI::Model::VolumeConfiguration,
      :id => "http://localhost:3001/cimi/volume_configurations/1",
      :name => "volume_config",
      :format => "ext3",
      :capacity => 1

    @collection = CIMI::Collections.collection(:volumes)
  end

  def make_volume_create
    vt = CIMI::Model::VolumeTemplate.new
    vt.volume_config.href = @config.id
    CIMI::Model::VolumeCreate.new(:name => "new_cimi_volume_#{Time.now.to_i}",
         :volume_template => vt)
  end

  it 'allows creation of a new volume' do
    vc = make_volume_create
    post '/cimi/volumes', vc.to_json, "CONTENT_TYPE" => "application/json"

    last_response.status.must_equal 201
    model.name.must_equal vc.name
  end
end
