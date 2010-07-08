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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def bread_crumb
    s = "<ul class='breadcrumb'><li class='first'><a href='/'>&#948</a></li>"
    url = request.path.split('?')  #remove extra query string parameters
    levels = url[0].split('/') #break up url into different levels
    levels.each_with_index do |level, index|
      unless level.blank?
        if index == levels.size-1 ||
           (level == levels[levels.size-2] && levels[levels.size-1].to_i > 0)
          s += "<li class='subsequent'>#{level.gsub(/_/, ' ')}</li>\n" unless level.to_i > 0
        else
            link = levels.slice(0, index+1).join("/")
            s += "<li class='subsequent'><a href=\"#{link}\">#{level.gsub(/_/, ' ')}</a></li>\n"
        end
      end
    end
    s+="</ul>"
  end

  def instance_action_method(action)
    collections[:instances].operations[action.to_sym].method
  end

  def driver_has_feature?(feature_name)
    not driver.features(:instances).select{ |f| f.name.eql?(feature_name) }.empty?
  end

  def driver_has_auth_features?
    driver_has_feature?(:authentication_password) || driver_has_feature?(:authentication_key)
  end

  def driver_auth_feature_name
    return 'key' if driver_has_feature?(:authentication_key)
    return 'password' if driver_has_feature?(:authentication_password)
  end

end
