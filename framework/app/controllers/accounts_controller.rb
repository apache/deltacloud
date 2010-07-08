
load 'drivers/ec2.rb'

class AccountsController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    @accounts = driver.accounts( credentials )
    respond_to do |format|
      format.html
      format.json
      format.xml { 
        render :xml=>convert_to_xml( :account, @accounts )
      }
    end
  end


  def show
    @account = driver.account( credentials, params[:id] )
    respond_to do |format|
      format.html { 
        @images = driver.images( credentials, @account[:image_ids] )
      }
      format.json
      format.xml { 
        render :xml=>convert_to_xml( :account, @account )
      }
    end
  end

end
