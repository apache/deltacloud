module HardwareProfilesHelper

  def format_hardware_aspect(values)
    f = ''
    case ( values )
      when Range
        f = "#{values.begin} - #{values.end}"
      when Array
        f = values.join( ', ' )
      else
        f = values.to_s
    end
    f
  end

end
