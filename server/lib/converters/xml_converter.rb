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

module Converters

  ( ALIASES = {
    :owner=>nil,
    :volume=>:storage_volume,
  } ) unless defined?( ALIASES )

  def self.url_type(type)
    type = type.to_sym
    return ALIASES[type] if ( ALIASES.keys.include?( type ) )
    type
  end

  def self.tag_name(type)
    tag_name = type.to_s
    tag_name.gsub( /_/, '-' )
  end

  class XMLConverter
    def initialize(link_builder, type)
      @link_builder = link_builder
      @type         = type
    end

    def convert(obj, builder=nil)
      builder ||= Builder::XmlMarkup.new( :indent=>2 )
      if ( obj.is_a?( Array ) )
        builder.__send__( @type.to_s.pluralize.gsub( /_/, '-' ).to_sym ) do
          obj.each do |e|
            convert( e, builder )
          end
        end
      else
        case ( obj )
          when Flavor
            builder.flavor( :href=>@link_builder.send( :flavor_url,  obj.id ) ) {
              builder.id( obj.id )
              builder.architecture( obj.architecture )
              builder.memory( obj.memory )
              builder.storage( obj.storage )
            }
          when Image
            builder.image( :href=>@link_builder.send( :image_url, obj.id ) ) {
              builder.id( obj.id )
              builder.owner_id( obj.owner_id )
              builder.name( obj.name )
              builder.description( obj.description )
              builder.architecture( obj.architecture )
            }
          when Realm
            builder.realm( :href=>@link_builder.send( :realm_url, obj.id ) ) {
              builder.id( obj.id )
              builder.name( obj.name )
              builder.state( obj.state )
              if ( obj.limit == :unlimited )
                builder.limit()
              else
                builder.limit( obj.limit )
              end
            }
          when Instance
            builder.instance( :href=>@link_builder.send( :instance_url, obj.id ) ) {
              builder.id( obj.id )
              builder.name( obj.name )
              builder.owner_id( obj.owner_id )
              builder.image( :href=>@link_builder.send( :image_url, obj.image_id ) )
              builder.flavor( :href=>@link_builder.send( :flavor_url, obj.flavor_id ) )
              builder.__send__( 'hardware-profile', :href=>@link_builder.send( :hardware_profile_url, obj.instance_profile.name) ) do
                builder.id( obj.instance_profile.name )
                obj.instance_profile.overrides.each do |p, v|
                  u = ::Deltacloud::HardwareProfile::unit(p)
                  builder.property( :kind=>:fixed, :name=>p, :unit=>u, :value=>v )
                end
              end
              builder.realm( :href=>@link_builder.send( :realm_url, obj.realm_id ) ) if obj.realm_id
              builder.state( obj.state )
              builder.actions {
                if ( obj.actions )
                  obj.actions.each do |action|
                    builder.link( :rel=>action, :href=>@link_builder.send( "#{action}_instance_url", obj.id ) )
                  end
                end
              }
              builder.__send__( 'public-addresses' ) {
                obj.public_addresses.each do |address|
                  builder.address( address )
                end
              }
              builder.__send__( 'private-addresses' ) {
                obj.private_addresses.each do |address|
                  builder.address( address )
                end
              }
            }
          when StorageVolume
            builder.__send__('storage-volume', :href=>@link_builder.send( :storage_volume_url, obj.id )) {
              builder.id( obj.id )
              builder.created( obj.created )
              builder.state( obj.state )
              builder.capacity( obj.capacity )
              builder.device( obj.device )
              if ( obj.instance_id )
                builder.instance( :href=>@link_builder.send( :instance_url, obj.instance_id ) )
              else
                builder.instance()
              end
            }
          when StorageSnapshot
            builder.__send__('storage-snapshot', :href=>@link_builder.send( :storage_snapshot_url, obj.id )) {
              builder.id( obj.id )
              builder.created( obj.created )
              builder.state( obj.state )
              if ( obj.storage_volume_id )
                builder.__send__('storage-volume', :href=>@link_builder.send( :storage_volume_url, obj.storage_volume_id ) )
              else
                builder.__send( 'storage-volume' )
              end
            }
        end
      end
      return builder.target!
    end
  end
end
