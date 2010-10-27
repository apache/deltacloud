require 'lib/deltacloud'

skip_methods = [ "id=", "uri=" ]

begin
  @dc=DeltaCloud.new('mockuser', 'mockpassword', 'http://localhost:3001/api')
rescue
  puts "Please make sure that Deltacloud API is running with Mock driver"
  exit(1)
end

@dc.entry_points.keys.each do |ep|
  @dc.send(ep)
end

class_list = DeltaCloud::classes.collect { |c| DeltaCloud::module_eval("::DeltaCloud::API::#{c}")}

def read_method_description(c, method)
  if method =~ /es$/
    "    # Read #{c.downcase} collection from Deltacloud API"
  else
    case method
      when "uri" then
        "    # Return URI to API for this object"
      when "action_urls" then
        "    # Return available actions API URL"
      when "client" then
        "    # Return instance of API client"
      else
        "    # Get #{method} attribute value from #{c.downcase}"
    end
  end
end

def read_parameters(c, method)
  out = []
  if method =~ /es$/
    out << "    # @param [String, #id] Filter by ID"
  end
  out.join("\n")
end

def read_return_value(c, method)
  if method =~ /es$/
    rt = "Array"
  else
    rt = "String"
  end
  "    # @return [String] Value of #{method}"
end

out = []

class_list.each do |c|
  class_name = "#{c}".gsub(/^DeltaCloud::/, '')
  out << "module DeltaCloud"
  out << "  class API"
  @dc.entry_points.keys.each do |ep|
    out << "# Return #{ep.to_s.classify} object with given id\n"
    out << "# "
    out << "# #{@dc.documentation(ep.to_s).description.split("\n").join("\n# ")}"
    out << "# @return [#{ep.to_s.classify}]"
    out << "def #{ep.to_s.gsub(/s$/, '')}"
    out << "end"
    out << "# Return collection of #{ep.to_s.classify} objects"
    out << "# "
    out << "# #{@dc.documentation(ep.to_s).description.split("\n").join("\n# ")}"
    @dc.documentation(ep.to_s, 'index').params.each do |p|
      out << p.to_comment
    end
    out << "# @return [Array] [#{ep.to_s.classify}]"
    out << "def #{ep}(opts={})"
    out << "end"
  end
  out << "  end"
  out << "  class #{class_name}"
  c.instance_methods(false).each do |method|
    next if skip_methods.include?(method)
    params = read_parameters(class_name, method)
    retval = read_return_value(class_name, method)
    out << read_method_description(class_name, method)
    out << params if params
    out << retval if retval
    out << "    def #{method}"
    out << "      # This method was generated dynamically from API"
    out << "    end\n"
  end
  out << "  end"
  out << "end"
end

FileUtils.rm_r('doc') rescue nil
FileUtils.mkdir_p('doc')
File.open('doc/deltacloud.rb', 'w') do |f|
  f.puts(out.join("\n"))
end
system("yardoc -m markdown --readme README --title 'Deltacloud Client Library' 'lib/*.rb' 'doc/deltacloud.rb' --verbose")
FileUtils.rm('doc/deltacloud.rb')
