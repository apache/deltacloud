load 'drivers/ec2.rb'

class StorageVolumesController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    @volumes = driver.volumes( credentials )
    puts @volumes.inspect
    respond_to do |format|
      format.html
    end
  end

  def show
    @volume = driver.volume( credentials, params[:id] )
    respond_to do |format|
      format.html
      format.json
      format.xml {
      }
    end
  end

end
