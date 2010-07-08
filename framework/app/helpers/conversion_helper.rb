
load 'converters/xml_converter.rb'

module ConversionHelper

  def convert_to_xml(type, obj)
    if ( [ :account, :image, :instance, :storage_volume, :storage_snapshot ].include?( type ) )
      Converters::XMLConverter.new( self, type ).convert(obj)
    end
  end

end
