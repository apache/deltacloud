class FlavorsController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    @flavors = driver.flavors( credentials )
    respond_to do |format|
      format.html
      format.xml {
        render :xml=>convert_to_xml( :flavor, @flavors )
      }
    end
  end

  def show
    @flavor = driver.flavor( credentials, params[:id] )
    respond_to do |format|
      format.html
      format.json
      format.xml {
        render :xml=>convert_to_xml( :flavor, @flavor )
      }
    end
  end

end
