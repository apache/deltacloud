
module Converters
  class XMLConverter
    def initialize(link_builder, type)
      @link_builder = link_builder
      @type         = type
    end 

    def convert(obj, builder=nil)
      builder ||= Builder::XmlMarkup.new
      if ( obj.is_a?( Array ) )
        builder.__send__( @type.to_s.pluralize.to_sym ) do
          obj.each do |e|
            convert( e, builder )
          end
        end
      elsif ( obj.is_a?( Hash ) )
        builder.__send__( @type ) do
          obj.each do |k,v|
            builder.__send__( k, v )
          end
        end
      end
      return builder.target!
    end
  end
end
