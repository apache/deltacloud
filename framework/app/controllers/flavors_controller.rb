class FlavorsController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    build_filter( :id )
    build_filter( :architecture )
    @flavors = driver.flavors( credentials, @filter )
    respond_to do |format|
      format.html
      format.xml {
        render :xml=>convert_to_xml( :flavor, @flavors )
      }
    end
  end

  def show
    @flavor = driver.flavor( credentials, :id => params[:id] )
    respond_to do |format|
      format.html
      format.json
      format.xml {
        render :xml=>convert_to_xml( :flavor, @flavor )
      }
    end
  end

end
