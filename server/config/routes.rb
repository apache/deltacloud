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

ActionController::Routing::Routes.draw do |map|

  map.root :controller=>'root'

  map.resource :api, :controller=>'Api'

  map.resources :flavors, :path_prefix=>'api'
  map.resources :hardware_profiles, :path_prefix=>'api',
    :as=>'hardware-profiles',
    :only=>[ :index, :show ]

  map.resources :realms,  :path_prefix=>'api'
  map.resources :images,  :path_prefix=>'api'

  map.resource :instance_states, :path_prefix=>'api',
    :as=>'instance-states',
    :only=>[ :show ]

  map.resources :instances, :path_prefix=>'api',
    :member=>{
      :destroy=>:post,
      :stop=>:post,
      :start=>:post,
      :reboot=>:post,
    }

  map.resource :storage, :path_prefix=>'api' do |s|
    s.resources :volumes, :controller=>'StorageVolumes'
    s.resources :snapshots, :controller=>'StorageSnapshots'
  end

end
