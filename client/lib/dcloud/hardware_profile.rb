#
# Copyright (C) 2009  Red Hat, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


require 'dcloud/base_model'

module DCloud
    class HardwareProfile < BaseModel

      class Property
        class Range
          attr_reader :first, :last
          def initialize(element)
            if element
              @first = element.attributes['first']
              @last = element.attributes['last']
            end
          end
          def present?
            ! @first.nil?
          end
        end
        class Enum
          attr_reader :entries
          def initialize(element)
            @entries = []
            if element
              element.get_elements( 'entry' ).each do |entry|
                @entries << entry.attributes['value']
              end
            end
          end
          def present?
            ! @entries.empty?
          end
        end
        attr_reader :name, :kind, :unit, :value, :range, :enum

        def initialize(xml, name)
          @name = name
          p = REXML::XPath.first(xml, "property[@name = '#{name}']")
          if p
            @value = p.attributes['value']
            @unit = p.attributes['unit']
            @kind = p.attributes['kind']
            @range = Range.new(p.get_elements('range')[0]) if @kind=='range'
            @enum = Enum.new(p.get_elements('enum')[0]) if @kind=='enum'
          end
        end

        def present?
          ! @value.nil?
        end

        # FIXME: how to  range/enum/kind bits fit into this?
        def to_s
          v = @value || "---"
          u = @unit || ""
          u = "" if ["label", "count"].include?(u)
          "#{v} #{u}"
        end
      end

      class FloatProperty < Property
        def initialize(xml, name)
          super(xml, name)
          @value = @value.to_f if @value
        end
      end

      class IntegerProperty < Property
        def initialize(xml, name)
          super(xml, name)
          @value = @value.to_i if @value
        end
      end

      xml_tag_name :hardware_profile

      attribute :memory
      attribute :storage
      attribute :cpu
      attribute :architecture

      def initialize(client, uri, xml=nil)
        super( client, uri, xml )
      end

      def load_payload(xml=nil)
        super(xml)
        unless xml.nil?
          @memory = FloatProperty.new(xml, 'memory')
          @storage = FloatProperty.new(xml, 'storage')
          @cpu = IntegerProperty.new(xml, 'cpu')
          @architecture = Property.new(xml, 'architecture')
        end
      end

      def to_plain
        sprintf("%-15s | %-6s | %10s | %10s ", id[0, 15],
                architecture.to_s[0,6], memory.to_s[0,10], storage.to_s[0,10])
      end

      private
      def property_value(xml, name)
        p = REXML::XPath.first(xml, "property[@name = '#{name}']")
        p ? p.attributes['value'] : ""
      end
    end
end
