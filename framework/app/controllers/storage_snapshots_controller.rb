class StorageSnapshotsController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    @snapshots = driver.snapshots( credentials )
    respond_to do |format|
      format.html
      format.json
      format.xml {
        render :xml=>convert_to_xml( :storage_snapshot, @snapshots )
      }
    end
  end

  def show
    @snapshot = driver.snapshot( credentials, :id => params[:id] )
    respond_to do |format|
      format.html
      format.json
      format.xml {
        render :xml=>convert_to_xml( :storage_snapshot, @snapshot )
      }
    end
  end

end
