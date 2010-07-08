class ImagesController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    build_filter( :id )
    build_filter( :owner_id )
    build_filter( :architecture )
    @images = driver.images( credentials, @filter )

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
