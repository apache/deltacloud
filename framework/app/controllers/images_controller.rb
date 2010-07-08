#load 'representations/xml'
load 'drivers/ec2.rb'
#require 'right_aws'

class ImagesController < ApplicationController

  include DriverHelper

  around_filter :catch_auth

  def index
    @images = driver.images( credentials, [ 'ami-015db968', 'ami-015dba68' ])

    respond_to do |format|
      format.html 
      format.json
      format.xml { render :xml=>@images.to_xml(:skip_types=>true, :link_builder=>self) }
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
