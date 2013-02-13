# This will create the directory we use for storing Mock driver
# data and also CIMI database file
#

# By default the location is /var/tmp/deltacloud-{USER}/
#
BASE_STORAGE_DIR = File.join('/', 'var', 'tmp', "deltacloud-#{ENV['USER']}")

# The mock driver YAML files are stored in BASE_STORAGE_DIR/mock
# You can overide this by setting 'DELTACLOUD_MOCK_STORAGE' environment variable
#
MOCK_STORAGE_DIR = ENV['DELTACLOUD_MOCK_STORAGE'] || File.join(BASE_STORAGE_DIR, 'mock')

FileUtils.mkpath(BASE_STORAGE_DIR, :mode => 0750) unless File.directory?(BASE_STORAGE_DIR)
FileUtils.mkpath(BASE_STORAGE_DIR, :mode => 0750) unless File.directory?(MOCK_STORAGE_DIR)
