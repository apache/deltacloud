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


require 'deltacloud/base_driver'
require 'converters/xml_converter'

module DriverHelper

  def convert_to_xml(type, obj)
    if ( [ :flavor, :account, :image, :realm, :instance, :storage_volume, :storage_snapshot ].include?( type ) )
      Converters::XMLConverter.new( self, type ).convert(obj)
    end
  end

  def catch_auth
    begin
      yield
    rescue Deltacloud::AuthException => e
      authenticate_or_request_with_http_basic() do |n,p|
      end
    end
  end

  def safely(&block)
    begin
      block.call
    rescue Deltacloud::AuthException => e
      @response.status=403
      "<error>#{e.message}</error>"
    end
  end

end
