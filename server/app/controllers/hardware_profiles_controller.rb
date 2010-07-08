class HardwareProfilesController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    @profiles = driver().hardware_profiles
  end

  def show
    @profile = driver().hardware_profile(params[:id])
  end

end
