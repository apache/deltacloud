DRIVERS = {
  :ec2 => { :name => "EC2" },
  :rackspace => { :name => "Rackspace" },
  :gogrid => { :name => "Gogrid" },
  :rhevm => { :name => "RHEVM" },
  :rimu => { :name => "Rimu", :class => "RimuHostingDriver"},
  :opennebula => { :name => "Opennebula", :class => "OpennebulaDriver" },
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
  name = DRIVER.to_s
  "deltacloud/drivers/#{name}/#{name}_driver.rb"
end

def driver
  require driver_source_name
  @driver ||= eval( driver_class_name ).new
end

