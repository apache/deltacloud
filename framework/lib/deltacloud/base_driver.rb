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


module DeltaCloud

  class AuthException < Exception
  end

  class BaseDriver

    def instance_states()
      []
    end

    def instance_actions_for(state)
      actions = []
      state_key = state.downcase.to_sym
      states = instance_states()
      current_state = states.find{|e| e.first == state.downcase.to_sym }
      if ( current_state )
        actions = current_state.last.values.uniq
        actions.reject!{|e| e == :_auto_}
      end
      actions
    end

    def flavor(credentials, opts)
      flavors = flavors(credentials, opts)
      return flavors.first unless flavors.empty?
      nil
    end

    def flavors(credentials, ops)
      []
    end

    def flavors_by_architecture(credentials, architecture)
      flavors(credentials, :architecture => architecture)
    end

    def realm(credentials, opts)
      realms = realms(credentials, opts)
      return realms.first unless realms.empty?
      nil
    end

    def realms(credentials, opts=nil)
      []
    end

    def image(credentials, opts)
      images = images(credentials, opts)
      return images.first unless images.empty?
      nil
    end

    def images(credentials, ops)
      []
    end

    def instance(credentials, opts)
      instances = instances(credentials, opts)
      return instances.first unless instances.empty?
      nil
    end

    def instances(credentials, ops)
      []
    end

    def create_instance(credentials, image_id, opts)
    end
    def start_instance(credentials, id)
    end
    def stop_instance(credentials, id)
    end
    def reboot_instance(credentials, id)
    end

    def storage_volume(credentials, opts)
      volumes = storage_volumes(credentials, opts)
      return volumes.first unless volumes.empty?
      nil
    end

    def storage_snapshot(credentials, opts)
      snapshots = snapshots(credentials, opts)
      return snapshots.first unless snapshots.empty?
      nil
    end

    def snapshots(credentials, ops)
      []
    end

    def filter_on(collection, attribute, opts)
      return collection if opts.nil?
      return collection if opts[attribute].nil?
      filter = opts[attribute]
      if ( filter.is_a?( Array ) )
        return collection.select{|e| filter.include?( e.send(attribute) ) }
      else
        return collection.select{|e| filter == e.send(attribute) }
      end
    end
  end

end
