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
begin
  require 'AWS'
rescue LoadError
  puts "ERROR: Please install Amazon-EC2 gem first. (gem install amazon-ec2)"
  exit(1)
end

module Deltacloud
  module Drivers
    module EC2
class EC2Driver < Deltacloud::BaseDriver

  feature :instances, :user_data

  define_hardware_profile('m1-small') do
    cpu              1
    memory         1.7 * 1024
    storage        160
    architecture 'i386'
  end

  define_hardware_profile('m1-large') do
    cpu                4
    memory           7.5 * 1024
    storage          850
    architecture 'x86_64'
  end

  define_hardware_profile('m1-xlarge') do
    cpu                8
    memory            15 * 1024
    storage         1690
    architecture 'x86_64'
  end

  define_hardware_profile('c1-medium') do
    cpu                5
    memory           1.7 * 1024
    storage          350
    architecture 'i386'
  end

  define_hardware_profile('c1-xlarge') do
    cpu              20
    memory            7 * 1024
    storage        1690
    architecture 'x86_64'
  end

  define_hardware_profile('m2-xlarge') do
    cpu               6.5
    memory           17.1 * 1024
    storage         420
    architecture    'x86_64'
  end

  define_hardware_profile('m2-2xlarge') do
    cpu              13
    memory           34.2 * 1024
    storage         850
    architecture    'x86_64'
  end

  define_instance_states do
    start.to( :pending )          .automatically
    pending.to( :running )        .automatically
    pending.to( :stopping )       .on( :stop )
    pending.to( :stopped )        .automatically
    stopped.to( :running )        .on( :start )
    running.to( :running )        .on( :reboot )
    running.to( :stopping )       .on( :stop )
    shutting_down.to( :stopped )  .automatically
    stopped.to( :finish )         .automatically
  end

  #
  # Images
  #

  def images(credentials, opts={} )
    ec2 = new_client(credentials)
    img_arr = []
    config = { :owner_id => "amazon" }
    config.merge!({ :owner_id => opts[:owner_id] }) if opts and opts[:owner_id]
    config.merge!({ :image_id => opts[:id] }) if opts and opts[:id]
    safely do
      ec2.describe_images(config).imagesSet.item.each do |image|
        img_arr << convert_image(image)
      end
    end
    img_arr = filter_on( img_arr, :architecture, opts )
    img_arr.sort_by{|e| [e.owner_id, e.name]}
  end

  #
  # Realms
  #

  def realms(credentials, opts=nil)
    ec2 = new_client(credentials)
    realms = []
    safely do
      ec2.describe_availability_zones.availabilityZoneInfo.item.each do |ec2_realm|
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
      ec2_instances = ec2.describe_instances.reservationSet
      return [] unless ec2_instances
      ec2_instances.item.each do |item|
        item.instancesSet.item.each do |ec2_instance|
          instances << convert_instance( ec2_instance, item.ownerId )
        end
      end
    end
    instances = filter_on( instances, :id, opts )
    instances = filter_on( instances, :state, opts )
    instances
  end


  def create_instance(credentials, image_id, opts)
    ec2 = new_client( credentials )
    realm_id = opts[:realm_id]
    image = image(credentials, :id => image_id )
    hwp = find_hardware_profile(credentials, opts[:hwp_id], image.id)
    ec2_instances = ec2.run_instances(
      :image_id => image.id,
      :user_data => opts[:user_data],
      :key_name => opts[:key_name],
      :availability_zone => realm_id,
      :monitoring_enabled => true,
      :instance_type => hwp.name.tr('-', '.'),
      :disable_api_termination => false,
      :instance_initiated_shutdown_behavior => 'terminate'
    )
    convert_instance( ec2_instances.instancesSet.item.first, 'pending' )
  end

  def reboot_instance(credentials, id)
    ec2 = new_client(credentials)
    safely do
      ec2.reboot_instances( :instance_id => id )
    end
  end

  def stop_instance(credentials, id)
    ec2 = new_client(credentials)
    safely do
      ec2.terminate_instances( :instance_id => id )
    end
  end

  def destroy_instance(credentials, id)
    ec2 = new_client(credentials)
    safely do
      ec2.terminate_instances( :instance_id => id )
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
        ec2.describe_volumes(:volume_id => opts[:id]).volumeSet.item.each do |ec2_volume|
          volumes << convert_volume( ec2_volume )
        end
      else
        ec2_volumes = ec2.describe_volumes.volumeSet
        return [] unless ec2_volumes
        ec2_volumes.item.each do |ec2_volume|
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
        ec2.describe_snapshots(:owner => 'self', :snapshot_id => opts[:id]).snapshotSet.item.each do |ec2_snapshot|
          snapshots << convert_snapshot( ec2_snapshot )
        end
      else
        ec2_snapshots = ec2.describe_snapshots(:owner => 'self').snapshotSet
        return [] unless ec2_snapshots
        ec2_snapshots.item.each do |ec2_snapshot|
          snapshots << convert_snapshot( ec2_snapshot )
        end
      end
    end
    snapshots
  end

  private

  def new_client(credentials)
    AWS::EC2::Base.new(
      :access_key_id => credentials.user,
      :secret_access_key => credentials.password
    )
  end

  def convert_image(ec2_image)
    Image.new( {
      :id=>ec2_image['imageId'],
      :name=>ec2_image['name'] || ec2_image['imageId'],
      :description=>ec2_image['description'] || ec2_image['imageLocation'] || '',
      :owner_id=>ec2_image['imageOwnerId'],
      :architecture=>ec2_image['architecture'],
    } )
  end

  def convert_realm(ec2_realm)
    Realm.new( {
      :id=>ec2_realm['zoneName'],
      :name=>ec2_realm['regionName'],
      :limit=>ec2_realm['zoneState'].eql?('available') ? :unlimited : 0,
      :state=>ec2_realm['zoneState'].upcase,
    } )
  end

  def convert_instance(ec2_instance, owner_id)
    state = ec2_instance['instanceState']['name'].upcase
    state_key = state.downcase.underscore.to_sym
    realm_id = ec2_instance['placement']['availabilityZone']
    (realm_id = nil ) if ( realm_id == '' )
    hwp_name = ec2_instance['instanceType'].gsub( /\./, '-')
    Instance.new( {
      :id=>ec2_instance['instanceId'],
      :name => ec2_instance['imageId'],
      :state=>state,
      :image_id=>ec2_instance['imageId'],
      :owner_id=>owner_id,
      :realm_id=>realm_id,
      :public_addresses=>( ec2_instance['dnsName'] == '' ? [] : [ec2_instance['dnsName']] ),
      :private_addresses=>( ec2_instance['privateDnsName'] == '' ? [] : [ec2_instance['privateDnsName']] ),
      :flavor_id=>ec2_instance['instanceType'].gsub( /\./, '-'),
      :instance_profile =>InstanceProfile.new(hwp_name),
      :actions=>instance_actions_for( state ),
    } )
  end

  def convert_volume(ec2_volume)
    StorageVolume.new( {
      :id=>ec2_volume['volumeId'],
      :created=>ec2_volume['createTime'],
      :state=>ec2_volume['status'].upcase,
      :capacity=>ec2_volume['size'],
      :instance_id=>ec2_volume['snapshotId'],
      :device=>ec2_volume['attachmentSet'],
    } )
  end

  def convert_snapshot(ec2_snapshot)
    StorageSnapshot.new( {
      :id=>ec2_snapshot['snapshotId'],
      :state=>ec2_snapshot['status'].upcase,
      :storage_volume_id=>ec2_snapshot['volumeId'],
      :created=>ec2_snapshot['startTime'],
    } )
  end

  def safely(&block)
    begin
      block.call
    rescue AWS::AuthFailure => e
        raise Deltacloud::AuthException.new
    rescue Exception => e
        puts "ERROR: #{e.message}"
    end
  end

end

    end
  end
end
