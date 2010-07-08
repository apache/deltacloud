
class BaseModel

  def self.attribute(attr)
    build_reader attr
  end

  def self.build_reader(attr)
    eval "
      def #{attr}
        check_load_payload
        @#{attr}
      end
    "
  end

  attr_reader :uri

  def initialize(client, uri=nil, xml=nil)
    @client      = client
    @uri         = uri
    @loaded      = false
    load_payload( xml )
  end

  def id()
    @id
  end

  def check_load_payload()
    return if @loaded
    xml = @client.fetch_resource( self.class.name.downcase.to_sym, @uri )
    load_payload(xml)
  end

  def load_payload(xml=nil)
    unless ( xml.nil? )
      @loaded = true
      @id = xml.text( 'id' ) 
    end
  end

end
