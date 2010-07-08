
load 'drivers/ec2.rb'

class CredentialsController < ApplicationController

  include DriverHelper

  def show
  end

  def edit
  end

  def update
    driver.credentials_definition.each do |p|
      session[:credentials][p[:name]] = params[p[:name]]
    end
    redirect_to :action=>:show
  end

end
