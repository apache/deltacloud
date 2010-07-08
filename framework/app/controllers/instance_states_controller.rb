class InstanceStatesController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def show
    @states = driver.instance_states()
    respond_to do |format|
      format.html
      format.json
      format.xml
    end
  end

end
