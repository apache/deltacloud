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

require 'open3'

class InstanceStatesController < ApplicationController

  include DriverHelper
  include ConversionHelper

  around_filter :catch_auth

  def show
    #@states = driver.instance_states()
    @machine = driver.instance_state_machine()
    respond_to do |format|
      format.html
      format.json
      format.xml
      format.gv
      format.png {
        gv = render_to_string( :file=>'instance_states/show.gv.erb' )
        png =  ''
        cmd = 'dot -Gsize="7.7,7" -Tpng'
        Open3.popen3( cmd ) do |stdin, stdout, stderr|
          stdin.write( gv )
          stdin.close()
          png = stdout.read
        end
        render :text=>png, :content_type=>'image/png'
      }
    end
  end

end
