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
require 'right_aws'

module Deltacloud
  module Drivers
class Ec2Driver < DeltaCloud::BaseDriver

  #
  # Flavors
  #
  FLAVORS = [
    Flavor.new( {
      :id=>'m1-small',
      :memory=>1.7,
      :storage=>160,
      :architecture=>'i386',
    } ),
    Flavor.new( {
      :id=>'m1-large',
      :memory=>7.5,
      :storage=>850,
      :architecture=>'x86_64',
    } ),
    Flavor.new( {
      :id=>'m1-xlarge',
      :memory=>15,
      :storage=>1690,
      :architecture=>'x86_64',
    } ),
    Flavor.new( {
      :id=>'c1-medium',
      :memory=>1.7,
      :storage=>350,
      :architecture=>'x86_64',
    } ),
    Flavor.new( {
      :id=>'c1-xlarge',
      :memory=>7,
      :storage=>1690,
      :architecture=>'x86_64',
    } ),
  ]

  INSTANCE_STATES = [
    [ :begin, { 
        :pending=>:create,
    } ],
    [ :pending, { 
        :running=>:_auto_,
        :stopped=>:stop, 
    } ],
    [ :running, { 
        :running=>:reboot, 
        :shutting_down=>:stop,
    } ],
    [ :shutting_down, { 
        :stopped=>:_auto_,
    } ],
    [ :stopped, {
        :end=>:_auto_,
    } ],
  ]

  def instance_states()
    INSTANCE_STATES 
  end

  def flavors(credentials, opts=nil)
    return FLAVORS if ( opts.nil? )
    results = FLAVORS
    results = filter_on( results, :id, opts )
    results = filter_on( results, :architecture, opts )
    results
  end

  #
  # Images
  #

  def images(credentials, opts=nil )
    puts(opts)
    ec2 = new_client( credentials )
    images = []
    safely do
      if ( opts && opts[:id] )
        ec2.describe_images(opts[:id]).each do |ec2_image|
          if ( ec2_image[:aws_id] =~ /^ami-/ )
            images << convert_image( ec2_image )
          end
        end
        filter_on( images, :owner_id, opts )
      elsif ( opts && opts[:owner_id] )
        ec2.describe_images_by_owner( opts[:owner_id] ).each do |ec2_image|
          if ( ec2_image[:aws_id] =~ /^ami-/ )
            images << convert_image( ec2_image )
          end
        end
      else
        ec2.describe_images().each do |ec2_image|
          if ( ec2_image[:aws_id] =~ /^ami-/ )
            images << convert_image( ec2_image )
          end
        end
      end
    end

    images = filter_on( images, :architecture, opts )
    images.sort_by{|e| [e.owner_id,e.description]}
  end

  #
  # Realms
  #

  def realms(credentials, opts=nil)
    ec2 = new_client(credentials)
    realms = []
    safely do
      ec2.describe_availability_zones.each do |ec2_realm|
        realms << convert_realm( ec2_realm )
      end
    end
    realms
  end

  #
  # Instances
  #

  def instances(credentials, opts=nil)
    ec2 = new_client(credentials)
    instances = []
    safely do
      param = opts.nil? ? nil : opts[:id]
      ec2.describe_instances( param ).each do |ec2_instance|
        instances << convert_instance( ec2_instance )
      end
    end
    instances
  end

  def create_instance(credentials, image_id, opts)
    ec2 = new_client( credentials )
    realm_id = opts[:realm_id]
    flavor_id = opts[:flavor_id]
    unless ( flavor_id )
      image = image(credentials, :id=>image_id )
      flavor = flavor( credentials, :architecture=>image.architecture )
      ( flavor_id = flavor.id ) if ( flavor ) 
    end
    flavor_id.gsub!( /-/, '.' ) if flavor_id
    ec2_instances = ec2.run_instances(
                          image_id,
                          1,1,
                          [],
                          nil,
                          '',
                          'public',
                          flavor_id,
                          nil,
                          nil,
                          realm_id )
    convert_instance( ec2_instances.first )
  end

  def reboot_instance(credentials, id)
    ec2 = new_client(credentials)
    safely do
      ec2.reboot_instances( id )
    end
  end

  def stop_instance(credentials, id)
    ec2 = new_client(credentials)
    safely do
      ec2.terminate_instances( id )
    end
  end

  def destroy_instance(credentials, id)
    ec2 = new_client(credentials)
    safely do
      ec2.terminate_instances( id )
    end
  end

  #
  # Storage Volumes
  #

  def storage_volumes(credentials, opts=nil)
    ec2 = new_client( credentials )
    volumes = []
    safely do
      if (opts)
        ec2.describe_volumes(opts[:id]).each do |ec2_volume|
          volumes << convert_volume( ec2_volume )
        end
      else
        ec2.describe_volumes().each do |ec2_volume|
          volumes << convert_volume( ec2_volume )
        end
      end
    end
    volumes
  end

  #
  # Storage Snapshots
  #

  def storage_snapshots(credentials, opts=nil)
    ec2 = new_client( credentials )
    snapshots = []
    safely do
      if (opts)
        ec2.describe_snapshots(opts[:id]).each do |ec2_snapshot|
          snapshots << convert_snapshot( ec2_snapshot )
        end
      else
        ec2.describe_snapshots(opts).each do |ec2_snapshot|
          snapshots << convert_snapshot( ec2_snapshot )
        end
      end
    end
    snapshots
  end

  private

  def new_client(credentials)
    if ( credentials[:name].nil? || credentials[:password].nil? || credentials[:name] == '' || credentials[:password] == '' )
      raise DeltaCloud::AuthException.new
    end
    RightAws::Ec2.new(credentials[:name], credentials[:password], :cache=>false )
  end

  def convert_image(ec2_image)
    Image.new( {
      :id=>ec2_image[:aws_id],
      :description=>ec2_image[:aws_location],
      :owner_id=>ec2_image[:aws_owner],
      :architecture=>ec2_image[:aws_architecture],
    } )
  end

  def convert_realm(ec2_realm)
    Realm.new( {
      :id=>ec2_realm[:zone_name],
      :name=>ec2_realm[:zone_name],
      :limit=>:unlimited,
      :state=>ec2_realm[:zone_state].upcase,
    } )
  end

  def convert_instance(ec2_instance)
    state = ec2_instance[:aws_state].upcase
    state_key = state.downcase.underscore.to_sym

    realm_id = ec2_instance[:aws_availability_zone]
    (realm_id = nil ) if ( realm_id == '' )
    Instance.new( {
      :id=>ec2_instance[:aws_instance_id],
      :state=>ec2_instance[:aws_state].upcase,
      :image_id=>ec2_instance[:aws_image_id],
      :owner_id=>ec2_instance[:aws_owner],
      :realm_id=>realm_id,
      :public_addresses=>( ec2_instance[:dns_name] == '' ? [] : [ec2_instance[:dns_name]] ),
      :private_addresses=>( ec2_instance[:private_dns_name] == '' ? [] : [ec2_instance[:private_dns_name]] ),
      :flavor_id=>ec2_instance[:aws_instance_type].gsub( /\./, '-'),
      :actions=>instance_actions_for( ec2_instance[:aws_state].upcase ),
    } )
  end

  def convert_volume(ec2_volume)
    StorageVolume.new( {
      :id=>ec2_volume[:aws_id],
      :created=>ec2_volume[:aws_created_at],
      :state=>ec2_volume[:aws_status].upcase,
      :capacity=>ec2_volume[:aws_size],
      :instance_id=>ec2_volume[:aws_instance_id],
      :device=>ec2_volume[:aws_device],
    } )
  end

  def convert_snapshot(ec2_snapshot)
    StorageSnapshot.new( {
      :id=>ec2_snapshot[:aws_id],
      :state=>ec2_snapshot[:aws_status].upcase,
      :storage_volume_id=>ec2_snapshot[:aws_volume_id],
      :created=>ec2_snapshot[:aws_started_at],
    } )
  end

  def safely(&block)
    begin
      block.call
    rescue RightAws::AwsError => e
      if ( e.include?( /SignatureDoesNotMatch/ ) )
        raise DeltaCloud::AuthException.new
      elsif ( e.include?( /InvalidClientTokenId/ ) )
        raise DeltaCloud::AuthException.new
      else
        e.errors.each do |error|
          puts "ERROR #{error.inspect}"
        end
      end
    end
  end

end

  end
end

