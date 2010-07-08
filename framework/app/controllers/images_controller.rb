#load 'representations/xml'
load 'drivers/ec2.rb'
#require 'right_aws'

class ImagesController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    if ( params[:owner].nil? ) 
      @images = driver.images( credentials )
    else
      @images = driver.images( credentials, params[:owner] )
    end

    respond_to do |format|
      format.html 
      format.json
      #format.xml { render :xml=>@images.to_xml(:skip_types=>true, :link_builder=>self) }
      format.xml { 
        render :xml=>convert_to_xml( :image, @images ) 
      }
    end
  end

  def show
    driver = Drivers::EC2.new
    @image = driver.image( credentials, params[:id] )

    respond_to do |format|
      format.html
      format.json
      format.xml { render :xml=>@image.to_xml( :link_builder=>self ) }
    end
  end

end
