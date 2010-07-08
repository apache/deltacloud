
load 'drivers/ec2.rb'

require 'ostruct'

class InstancesController < ApplicationController

  include DriverHelper
  include CredentialsHelper

  def index
    @instances = driver.instances( credentials )

    respond_to do |format|
      format.html 
      format.json
      format.xml { render :xml=>@instances.to_xml(:skip_types=>true, :link_builder=>self) }
    end
  end

  def show
    @instance = driver.instance( credentials, params[:id] )

    respond_to do |format|
      format.html
      format.json
      format.xml { render :xml=>@instance.to_xml( :link_builder=>self ) }
    end
  end

  def destroy
    driver.delete_instance( credentials, params[:id] )
    redirect_to :action=>:show
  end

  def new
    @instance = Instance.new( {
                  :new_record=>true,
                  :id=>params[:id],
                  :image=>Image.new( :id=>params[:image_id] ),
                } )
  end

  def create
    instance = driver.create_instance( credentials, params[:instance][:image] )
    redirect_to instance
  end

  ##

  def stop
  end


  def reboot
    driver.reboot_instance( credentials, params[:id] )
    redirect_to :action=>:show
  end

end
