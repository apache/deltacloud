class RealmsController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    build_filter( :id )
    build_filter( :architecture )
    @realms = driver.realms( credentials, @filter )
    respond_to do |format|
      format.html
      format.xml {
        render :xml=>convert_to_xml( :realm, @realms )
      }
    end
  end

  def show
    @realm = driver.realm( credentials, :id => params[:id] )
    respond_to do |format|
      format.html
      format.json
      format.xml {
        render :xml=>convert_to_xml( :realm, @realm )
      }
    end
  end

end
