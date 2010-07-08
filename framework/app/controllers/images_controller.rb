class ImagesController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    if ( params[:owner].nil? ) 
      @images = driver.images( credentials )
    else
      @images = driver.images( credentials, :owner => params[:owner] )
    end

    respond_to do |format|
      format.html 
      format.json
      format.xml { 
        render :xml=>convert_to_xml( :image, @images ) 
      }
    end
  end

  def show
    @image = driver.image( credentials, :id => params[:id]  )

    respond_to do |format|
      format.html
      format.json
      format.xml { 
        render :xml=>convert_to_xml( :image, @image ) 
      }
    end
  end

end
