module DCloud
    class State

      attr_accessor :name
      attr_accessor :transitions

      def initialize(name)
        @name = name
        @transitions = []
      end

    end
end
