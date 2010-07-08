
module DCloud
    class BaseModel

      def self.xml_tag_name(name=nil)
        unless ( name.nil? ) 
          @xml_tag_name = name
        end
        @xml_tag_name || self.class.name.downcase.to_sym
      end


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
        check_load_payload
        @id
      end

     
      protected

      attr_reader :client

      def check_load_payload()
        return if @loaded
        xml = @client.fetch_resource( self.class.xml_tag_name.to_sym, @uri )
        load_payload(xml)
      end

      def load_payload(xml=nil)
        unless ( xml.nil? )
          @loaded = true
          @id = xml.text( 'id' ) 
        end
      end

      def unload
        @loaded = false
      end

    end
end
