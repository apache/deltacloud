
load 'converters/xml_converter.rb'

module ConversionHelper

  def convert_to_xml(type, obj)
    case ( type )
      when :image
        Converters::XMLConverter.new( self, type ).convert(obj)
      when :instance
    end
  end

end
