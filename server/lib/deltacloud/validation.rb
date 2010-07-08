module Deltacloud::Validation

  class Failure < StandardError
    attr_reader :param
    def initialize(param, msg='')
      super(msg)
      @param = param
    end

    def name
      param.name
    end
  end

  class Param
    attr_reader :name, :klass, :type, :options, :description

    def initialize(args)
      @name = args[0]
      @klass = args[1] || :string
      @type = args[2] || :optional
      @options = args[3] || []
      @description = args[4] || ''
    end

    def required?
      type.eql?(:required)
    end

    def optional?
      type.eql?(:optional)
    end
  end

  def param(*args)
    raise DuplicateParamException if params[args[0]]
    p = Param.new(args)
    params[p.name] = p
  end

  def params
    @params ||= {}
    @params
  end

  def each_param(&block)
    params.each_value { |p| yield p }
  end

  def validate(values)
    each_param do |p|
      if p.required? and not values[p.name]
        raise Failure.new(p, "Required parameter #{p.name} not found")
      end
      if values[p.name] and not p.options.empty? and
          not p.options.include?(values[p.name])
        raise Failure.new(p, "Parameter #{p.name} has value #{values[p.name]} which is not in #{p.options.join(", ")}")
      end
    end
  end
end
