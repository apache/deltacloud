#
# Copyright (C) 2009  Red Hat, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

class StorageSnapshotsController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def index
    @snapshots = driver.storage_snapshots( credentials, :id=>params[:id] )
    respond_to do |format|
      format.html
      format.json
      format.xml {
        render :xml=>convert_to_xml( :storage_snapshot, @snapshots )
      }
    end
  end

  def show
    @snapshot = driver.storage_snapshot( credentials, :id=>params[:id] )
    respond_to do |format|
      format.html
      format.json
      format.xml {
        render :xml=>convert_to_xml( :storage_snapshot, @snapshot )
      }
    end
  end

end
