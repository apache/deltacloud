module HardwareProfilesHelper

  def format_hardware_property(prop)
    return "&empty;" unless prop
    u = hardware_property_unit(prop)
    case prop.kind
      when :range
      "#{prop.first} #{u} - #{prop.last} #{u} (default: #{prop.default} #{u})"
      when :enum
      prop.values.collect{ |v| "#{v} #{u}"}.join(', ') + " (default: #{prop.default} #{u})"
      else
      "#{prop.value} #{u}"
    end
  end

  def format_instance_profile(ip)
    o = ip.overrides.collect do |p, v|
      u = hardware_property_unit(p)
      "#{p} = #{v} #{u}"
    end
    if o.empty?
      ""
    else
      "with #{o.join(", ")}"
    end
  end

  private
  def hardware_property_unit(prop)
    u = ::Deltacloud::HardwareProfile::unit(prop)
    u = "" if ["label", "count"].include?(u)
    u = "vcpus" if prop == :cpu
    u
  end
end
