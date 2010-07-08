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


class Instance < BaseModel

  attr_accessor :owner_id
  attr_accessor :image_id
  attr_accessor :flavor_id
  attr_accessor :name
  attr_accessor :realm_id
  attr_accessor :state
  attr_accessor :actions
  attr_accessor :public_addresses
  attr_accessor :private_addresses

 def initialize(init=nil)
   super(init)
   self.actions = [] if self.actions.nil?
   self.public_addresses = [] if self.public_addresses.nil?
   self.private_addresses = [] if self.private_addresses.nil?
  end
end
