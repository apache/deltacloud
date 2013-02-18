# Initialize the storage layer we use to persist some CIMI entities
# and attributes.
#
# By default the database backend is sqlite3

require 'sequel'
require 'logger'

require_relative '../db'

# We want to enable validation plugin for all database models
#
Sequel::Model.plugin :validation_class_methods

# Enable Sequel migrations extension
Sequel.extension :migration

# For JRuby we need to different Sequel driver
#
sequel_driver = (RUBY_PLATFORM=='java') ? 'jdbc:sqlite:' : 'sqlite://'

# The default sqlite3 database could be override by 'DATABASE_LOCATION'
# environment variable.
#
# For more details about possible values see:
# http://sequel.rubyforge.org/rdoc/files/doc/opening_databases_rdoc.html
#
DATABASE_LOCATION = ENV['DATABASE_LOCATION'] ||
  "#{sequel_driver}#{File.join(BASE_STORAGE_DIR, 'db.sqlite')}"

DATABASE = Deltacloud::initialize_database

# Detect if there are some pending migrations to run.
# We don't actually run migrations during server startup, just print
# a warning to console
#

DATABASE_MIGRATIONS_DIR = File.join(File.dirname(__FILE__), '..', '..', 'db', 'migrations')

unless Sequel::Migrator.is_current?(DATABASE, DATABASE_MIGRATIONS_DIR)
  warn "WARNING: The database needs to be upgraded. Run: 'deltacloud-db-upgrade' command."
  DATABASE_UPGRADE = true
else
  DATABASE_UPGRADE = false
end
