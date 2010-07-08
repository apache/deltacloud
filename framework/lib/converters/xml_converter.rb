
module Converters

  ALIASES = {
    :owner=>nil,
    :volume=>:storage_volume,
  }

  def self.url_type(type)
    type = type.to_sym
    return ALIASES[type] if ( ALIASES.keys.include?( type ) )
    type
  end

  def self.tag_name(type)
    tag_name = type.to_s
    tag_name.gsub( /_/, '-' )
  end

  class XMLConverter
    def initialize(link_builder, type)
      @link_builder = link_builder
      @type         = type
    end 

    def convert(obj, builder=nil)
      builder ||= Builder::XmlMarkup.new( :indent=>2 )
      if ( obj.is_a?( Array ) )
        builder.__send__( @type.to_s.pluralize.to_sym ) do
          obj.each do |e|
            convert( e, builder )
          end
        end
      elsif ( obj.is_a?( Hash ) )
        obj = obj.dup
        obj_id = obj.delete(:id)
        builder.__send__( Converters.tag_name( @type ), :href=>@link_builder.send( "#{@type}_url", obj_id ) ) do
          builder.id( obj_id )
          obj.each do |k,v|
            if ( k.to_s =~ /^(.*)_ids$/ )
              type = $1 
              builder.__send__( type.pluralize ) do
                v.each do |each_id|
                  builder.__send__( type, @link_builder.send( "#{type}_url", each_id ) )
                end
              end
            elsif ( k.to_s =~/^(.*)_id$/ )
              type = $1
              url_type = Converters.url_type( $1 )
              unless ( url_type.nil? )
                if ( v.nil? )
                  builder.__send__( type )
                else
                  builder.__send__( type, @link_builder.send( "#{url_type}_url", v ) )
                end
              else
                if ( v.nil? )
                  builder.__send__( "#{type}_id" )
                else
                  builder.__send__( "#{type}_id", v )
                end
              end
            else
              builder.__send__( Converters.tag_name( k ), v )
            end
          end
        end
      end
      return builder.target!
    end
  end
end
