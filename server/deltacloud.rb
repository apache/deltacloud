# Add ./lib into load path
$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'deltacloud/base_driver'
require 'deltacloud/hardware_profile'
require 'deltacloud/state_machine'

require 'deltacloud/models/base_model'
require 'deltacloud/models/flavor'
require 'deltacloud/models/realm'
require 'deltacloud/models/image'
require 'deltacloud/models/instance'
require 'deltacloud/models/storage_snapshot'
require 'deltacloud/models/storage_volume'
