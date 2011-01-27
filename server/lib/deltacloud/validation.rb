#
# Copyright (C) 2009,2010  Red Hat, Inc.
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

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
      if args[3] and args[3].class.eql?(String)
        @description = args[3]
        @options = []
      end
      @options ||= args[3] || []
      @description ||= args[4] || ''
    end

    def required?
      type.eql?(:required)
    end

    def optional?
      type.eql?(:optional)
    end
  end

  def param(*args)
    raise "Duplicate param #{args[0]} #{params.inspect} #{self.class.name}" if params[args[0]]
    p = Param.new(args)
    params[p.name] = p
  end

  def params
    @params ||= {}
    @params
  end

  # Add the parameters in hash +new+ to already existing parameters. If
  # +new+ contains a parameter with an already existing name, the old
  # definition is clobbered.
  def add_params(new)
    # We do not check for duplication on purpose: multiple calls
    # to add_params should be cumulative
    new.each { |p|  @params[p.name] = p }
  end

  def each_param(&block)
    params.each_value { |p| yield p }
  end

  def validate(all_params, values)
    all_params.each_value do |p|
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
