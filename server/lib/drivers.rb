DRIVERS = {
  :ec2 => { :name => "EC2" },
  :rackspace => { :name => "Rackspace" },
  :gogrid => { :name => "Gogrid" },
  :rhevm => { :name => "RHEVM" },
  :rimuhosting => { :name => "RimuHosting"},
  :opennebula => { :name => "Opennebula", :class => "OpennebulaDriver" },
  :terremark => { :name => "Terremark"},
  :mock => { :name => "Mock" }
}

def driver_name
  DRIVERS[DRIVER][:name]
end

def driver_class_name
  basename = DRIVERS[DRIVER][:class] || "#{driver_name}Driver"
  "Deltacloud::Drivers::#{driver_name}::#{basename}"
end

def driver_source_name
  File.join("deltacloud", "drivers", "#{DRIVER}", "#{DRIVER}_driver.rb")
end

def driver_mock_source_name
  return File.join('deltacloud', 'drivers', DRIVER.to_s, "#{DRIVER}_driver.rb") if driver_name.eql? 'Mock'
  File.join('deltacloud', 'drivers', DRIVER, "#{DRIVER}_mock_driver.rb")
end

def driver
  require driver_source_name

  if Sinatra::Application.environment.eql? :test
    require driver_mock_source_name
  end

  @driver ||= eval( driver_class_name ).new
end
