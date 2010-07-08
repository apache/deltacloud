
class BaseModel

  def self.attribute(attr, type=:string)
    build_accessor attr
    attributes[attr] = type
  end

  def self.has_one(attr, type)
    build_accessor attr
    has_ones[attr] = type
  end

  def self.has_many(*attrs)
    attrs.each do |attr|
      build_accessor attr
      has_manys << attr
    end
  end

  def self.attributes
    @attributes ||= {}
  end

  def self.has_ones
    @has_ones ||= {}
  end

  def self.has_manyes
    @has_manys ||= []
  end

  def self.build_accessor(attr)
    eval " 
      def #{attr}
        check_load_payload
        @#{attr}
      end
      def #{attr}=(v)
        @#{attr} = v
      end
    "
  end

  attr_reader :uri
  attr_reader :resource_id

  def initialize(client, uri=nil, init=nil)
    @client      = client
    @uri         = uri
    @loaded      = false
    load_payload( init )
  end

  def check_load_payload()
    return if @loaded
    init = @client.fetch( @uri )
    load_payload(init)
  end

  def load_payload(init=nil)
    unless ( init.nil? )
      @loaded = true
      @resource_id = init[:id] 
      self.class.attributes.each{|attr,type| 
        value = convert( init[attr], type )
        self.send( "#{attr}=", value )
      }
      self.class.has_ones.each{|attr,type|
        type_class = eval( type.to_s )
        ref_uri = init[attr]
        value = type_class.new( @client, ref_uri ) 
        self.send( "#{attr}=", value )
      }
    end
  end


  def convert(value, type)
    case ( type )
      when :float
        return value.to_f
      when :int
        return value.to_i
      when :string
        return value.to_s
      else
        return value
    end
  end

end
