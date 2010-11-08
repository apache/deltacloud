module Deltacloud::BackendCapability

  class Failure < StandardError
    attr_reader :capability
    def initialize(capability, msg='')
      super(msg)
      @capability = capability
    end
  end

  attr_reader :capability
  def with_capability(capability)
    @capability = capability
  end

  def check_capability(backend)
    if capability and !backend.respond_to?(capability)
      raise Failure.new(capability, "#{capability} capability not supported by backend #{backend.class.name}")
    end
  end
end
