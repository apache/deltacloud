CONFIG[:mock] = {
  :driver_name => 'mock',
  :realm_id => 'us',
  :realm_state => 'AVAILABLE',
  :realm_count => 2,
  :flavor_id => 'm1-small',
  :flavor_count => 5,
  :flavor_arch => 'x86_64',
  :image_owner => 'fedoraproject',
  :image_arch => 'i386',
  :image_id => 'img2',
  :image_count => 3,
  :storage_snapshot_id => 'snap2',
  :storage_snapshot_state => 'AVAILABLE',
  :storage_snapshot_count => '2',
  :storage_volume_id => 'vol2',
  :storage_volume_state => 'AVAILABLE',
  :storage_volume_count => 2,
  :instances_count => 180,
  :instance_1_name => "#{Time.now.to_i} testing instance",
  :instance_2_name => "#{Time.now.to_i+1} testing instance",
  :instance_image_id => 'img2',
  :instance_realm => 'us'
}

$DRIVER = :mock
