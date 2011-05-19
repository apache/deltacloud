module Deltacloud
  module ExceptionHandler

    class DeltacloudException < StandardError

      attr_accessor :code, :name, :message, :backtrace, :request

      def initialize(code, name, message, backtrace, details, request=nil)
        @code, @name, @message = code, name, message
        @details = details
        @backtrace = backtrace
        @request = request
        self
      end

    end

    class AuthenticationFailure < DeltacloudException
      def initialize(e, details)
        super(401, e.class.name, e.message, e.backtrace, details)
      end
    end

    class ValidationFailure < DeltacloudException
      def initialize(e, details)
        super(400, e.class.name, e.message, e.backtrace, details)
      end
    end

    class BackendError < DeltacloudException

      attr_accessor :cause

      def initialize(e, details)
        super(500, e.class.name, e.message, e.backtrace, details)
      end
    end

    class ProviderError < DeltacloudException
      def initialize(e, details)
        super(502, e.class.name, e.message, e.backtrace, details)
      end
    end

    class ExceptionDef
      attr_accessor :status
      attr_accessor :message
      attr_reader   :conditions
      attr_reader   :handler

      def initialize(conditions, &block)
        @conditions = conditions
        instance_eval(&block) if block_given?
      end

      def status(code)
        self.status = code
      end

      def message(message)
        self.message = message
      end

      def details(details)
        self.details = details
      end

      def exception(handler)
        self.handler = handler
      end

      # Condition can be class or regexp
      #
      def match?(e)
        @conditions.each do |c|
          return true if c.class == Class && e.class == c
          return true if c.class == Regexp && (e.class.name =~ c or e.message =~ c)
        end
        return false
      end

      def handler(e)
        return @handler if @handler
        case @status
          when 401 then Deltacloud::ExceptionHandler::AuthenticationFailure.new(e, @details)
          when 400 then Deltacloud::ExceptionHandler::ValidationFailure.new(e, @details)
          when 500 then Deltacloud::ExceptionHandler::BackendError.new(e, @details)
          when 502 then Deltacloud::ExceptionHandler::ProviderError.new(e, @details)
        end
      end

    end

    class Exceptions
      attr_reader :exception_definitions

      def initialize(&block)
        @exception_definitions = []
        instance_eval(&block) if block_given?
        self
      end

      def on(*conditions, &block)
        @exception_definitions << ExceptionDef::new(conditions, &block) if block_given?
      end
    end

    def self.exceptions(&block)
      @definitions = Exceptions.new(&block).exception_definitions if block_given?
      @definitions 
    end

    def safely(&block)
      begin
        block.call
      rescue => e
        Deltacloud::ExceptionHandler::exceptions.each do |exdef|
          raise exdef.handler(e) if exdef.match?(e)
        end
        $stderr.puts "# UNCAUGHT EXCEPTION  ~> '#{e.class}' - "
        $stderr.puts "# #{e.message}"
        $stderr.puts "# #{e.backtrace.join("\n")}"
        $stderr.puts "##############"
        raise BackendError.new(e, e.message)
      end
    end

  end

end
