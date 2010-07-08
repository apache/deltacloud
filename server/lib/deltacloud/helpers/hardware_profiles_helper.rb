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

  def hardware_property_unit(prop)
    u = prop.unit
    u = "" if ["label", "count"].include?(u)
    u = "vcpus" if prop.name == :cpu
    u
  end
end
