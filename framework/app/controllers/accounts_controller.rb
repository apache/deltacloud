
load 'drivers/ec2.rb'

class AccountsController < ApplicationController

  include DriverHelper

  around_filter :catch_auth

  def index
    @accounts = driver.accounts( credentials )
    respond_to do |format|
      format.html
      format.json
      format.xml { render :xml=>@accounts.to_xml( :skip_types=>true, :link_builder=>self ) }
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
        render :xml=>@account.to_xml( :link_builder=>self ) 
      }
    end
  end

end
