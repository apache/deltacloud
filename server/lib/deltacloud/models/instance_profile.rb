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

# Model to store the hardware profile applied to an instance together with
# any instance-specific overrides
class InstanceProfile < BaseModel
  attr_accessor :memory
  attr_accessor :storage
  attr_accessor :architecture
  attr_accessor :cpu

  def initialize(hwp_name, args = {})
    opts = args.inject({ :id => hwp_name.to_s }) do |m, e|
      k, v = e
      m[$1] = v if k.to_s =~ /^hwp_(.*)$/
      m
    end
    super(opts)
  end

  def name
    id
  end

  def overrides
    [:memory, :storage, :architecture, :cpu].inject({}) do |h, p|
      if v = instance_variable_get("@#{p}")
        h[p] = v
      end
      h
    end
  end
end
