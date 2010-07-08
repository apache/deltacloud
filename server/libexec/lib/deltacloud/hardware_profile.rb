
module Deltacloud
  class HardwareProfile

    attr_reader :name
    attr_reader :cpu
    attr_reader :architecture
    attr_reader :memory
    attr_reader :storage

    def initialize(name,&block)
      @name         = name
      @cpu          = 1
      @memory       = 0
      @storage      = 0
      @architecture = 1
      @mutable      = false
      instance_eval &block
    end

    def cpu(values=nil)
      ( @cpu = values ) unless values.nil?
      @cpu
    end

    def architecture(values=nil)
      ( @architecture = values ) unless values.nil?
      @architecture
    end

    def memory(values=nil)
      ( @memory = values ) unless values.nil?
      @memory
    end

    def storage(values=nil)
      ( @storage = values ) unless values.nil?
      @storage
    end

    def mutable
      @mutable = true
    end

    def immutable
      @mutable = false
    end

    def mutable?
      @mutable
    end

  end
end
