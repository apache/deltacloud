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

class ApiController < ApplicationController

  def show
    @version = 1.0
    @entry_points = [
      [ :flavors, flavors_url ],
      [ :instance_states, instance_states_url ],
      [ :realms, realms_url ],
      [ :images, images_url ],
      [ :instances, instances_url ],
      [ :storage_volumes, storage_volumes_url ],
      [ :storage_snapshots, storage_snapshots_url ],
    ]
    respond_to do |format|
      format.html
      format.json
      format.xml
    end
  end

end
