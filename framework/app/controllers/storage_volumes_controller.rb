class StorageVolumesController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    @volumes = driver.storage_volumes( credentials, :id=>params[:id] )
    respond_to do |format|
      format.html
      format.json
      format.xml {
        render :xml=>convert_to_xml( :storage_volume, @volumes )
      }
    end
  end

  def show
    @volume = driver.storage_volume( credentials, :id => params[:id] )
    respond_to do |format|
      format.html
      format.json
      format.xml {
        render :xml=>convert_to_xml( :storage_volume, @volume )
      }
    end
  end

end
