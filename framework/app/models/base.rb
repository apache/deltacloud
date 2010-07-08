

class Base

  attr_accessor :id

  def self.simple_attribute(*syms)
    syms.each{|sym| 
      simple_attributes << sym
      attr_accessor sym
    }
  end

  def self.simple_attributes
    @simple_attributes ||= []
  end

  def self.simple_reference_attributes
    @simple_reference_attributes ||= []
  end

  def self.has_one(sym)
    simple_reference_attributes << sym
    self.send( :define_method, sym, proc{
      instance_variable_get( "@#{sym}" )
    })

    self.send( :define_method, "#{sym}=", proc{|arg|
      instance_variable_set( "@#{sym}", arg )
    })
  end

  def self.has_many(sym)
    multi_reference_attributes << sym
    self.send( :define_method, sym, proc{
      instance_variable_set( "@#{sym}", instance_variable_get( "@#{sym}" ) || [] )
      instance_variable_get( "@#{sym}" )
    })

    self.send( :define_method, "#{sym}=", proc{|arg|
      instance_variable_set( "@#{sym}", arg )
    })
  end

  def self.multi_reference_attributes
    @multi_reference_attributes ||= []
  end

  def self.action(sym)
    actions << sym
  end

  def self.actions
    @actions ||= []
  end

  ######

  def initialize(args={})
    @new_record = args[:new_record]
    self.id = args[:id]
    initialize_attributes(args)
  end

  def to_xml(opts={})
    builder = opts[:builder] || Builder::XmlMarkup.new( :indent=>2 )
    ( opts[:builder] = builder ) unless ( opts.keys.include?( :builder ) )

    if ( opts[:skip_root] ) 
      opts.delete(:skip_root)
      to_xml_body(opts)
    else
      builder.__send__( self.class.name.underscore, :self=>opts[:link_builder].polymorphic_url( self ) ) {
        to_xml_body(opts)
      }
    end
  end

  def to_param
    self.id
  end

  def to_xml_body(opts={})
    builder = opts[:builder]
    builder.id( self.id )
    self.class.simple_attributes.each do |attr|
      builder.__send__( attr, self.send( attr ) )
    end
    self.class.simple_reference_attributes.each do |attr|
      value = self.send( attr )
      unless ( value.nil? )
        builder.__send__( attr, :href=>opts[:link_builder].polymorphic_url( value ) )
      end
    end
    self.class.multi_reference_attributes.each do |attr|
      value = self.send( attr )
      builder.__send__( attr ) {
        value.each do |e|
          builder.__send__( "#{attr}".singularize.to_sym, :href=>opts[:link_builder].polymorphic_url( e ) )
        end
      }
    end
    self.class.actions.each do |action|
      builder.__send__( 'link', :rel=>action, :href=>opts[:link_builder].polymorphic_url( self, :action=>action ) )
    end
  end

  def new_record?
    @new_record || false
  end

  private

  def initialize_attributes(args)
    self.class.simple_attributes.each do |attr|
      if ( args.keys.include?( attr ) )
        value = args[attr]
        self.send( "#{attr}=".to_sym, value );
      end
    end
    self.class.simple_reference_attributes.each do |attr|
      value = args[attr]
      if ( args.keys.include?( attr ) )
        value = args[attr]
        self.send( "#{attr}=".to_sym, value );
      end
    end
    self.class.multi_reference_attributes.each do |attr|
      value = args[attr]
      if ( args.keys.include?( attr ) )
        value = args[attr]
        self.send( "#{attr}=".to_sym, value );
      end
    end
  end

end
