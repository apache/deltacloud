class StorageSnapshotsController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    @snapshots = driver.snapshots( credentials )
    respond_to do |format|
      format.html
    end
  end

  def show
    @snapshot = driver.snapshot( credentials, params[:id] )
    respond_to do |format|
      format.html
      format.json
      format.xml {
      }
    end
  end

end
