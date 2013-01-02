module Deltacloud

  def self.test_environment?
    ENV['RACK_ENV'] == 'test' || ENV['DELTACLOUD_NO_DATABASE']
  end

  unless test_environment?
    require 'data_mapper'
    require_relative './db/provider'
    require_relative './db/entity'
    require_relative './db/machine_template'
    require_relative './db/address_template'
  end

  DATABASE_LOCATION = ENV['DATABASE_LOCATION'] || File.join('/', 'var', 'tmp', "deltacloud-mock-#{ENV['USER']}", 'db.sqlite')

  def self.initialize_database
    DataMapper::Logger.new($stdout, :debug) if ENV['API_VERBOSE']
    dbdir = File::dirname(DATABASE_LOCATION)
    FileUtils::mkdir(dbdir) unless File::directory?(dbdir)
    DataMapper::setup(:default, "sqlite://#{DATABASE_LOCATION}")
    DataMapper::finalize
    DataMapper::auto_upgrade!
  end

end

Deltacloud::initialize_database unless Deltacloud.test_environment?
