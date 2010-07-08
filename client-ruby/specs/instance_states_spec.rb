
require 'specs/spec_helper'

Spec::Matchers.define :include_transition do |action,to|
  match do |transitions|
    found = transitions.find{|e| e.action.to_s == action.to_s && e.to.to_s == to.to_s }
    ! found.nil?
  end
end

describe "instance-states" do

  it_should_behave_like "all resources"

  it "should allow retrieval of instance-state information" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance_states = client.instance_states
      instance_states.should_not be_nil
      instance_states.should_not be_empty

      instance_states[0].name.should eql( 'pending' )
      instance_states[0].transitions.size.should eql( 1 )
      instance_states[0].transitions[0].should be_auto

      instance_states[1].name.should eql( 'running' )
      instance_states[1].transitions.size.should eql( 2 )
      instance_states[1].transitions.should include_transition( :reboot, :running )
      instance_states[1].transitions.should include_transition( :stop, :terminated )
    end
  end 

  it "should allow retrieval of a single instance-state blob" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance_state = client.instance_state( :pending )
      instance_state.should_not be_nil
      instance_state.name.should eql( 'pending' )
      instance_state.transitions.size.should eql( 1 )
      instance_state.transitions[0].should be_auto

      instance_state = client.instance_state( :running )
      instance_state.name.should eql( 'running' )
      instance_state.transitions.size.should eql( 2 )
      instance_state.transitions.should include_transition( :reboot, :running )
      instance_state.transitions.should include_transition( :stop, :terminated )
    end
  end


end
