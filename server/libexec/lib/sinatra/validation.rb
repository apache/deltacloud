class ValidationFailure < Exception
  attr_reader :name, :spec, :msg
  def initialize(name, spec, msg='')
    @name, @spec, @msg = name, spec, msg
  end
end

error ValidationFailure do
  content_type 'text/xml', :charset => 'utf-8'
  @error = request.env['sinatra.error']
  haml :error, :layout => false
end

def validate_parameters(values, parameters)
  require 'pp'
  parameters.each_key do |p|
    if parameters[p][:type].eql?(:required) and not values[p.to_s]
      raise ValidationFailure.new(p, parameters[p], 'Required parameter not found')
    end
    if parameters[p][:type].eql?(:required) and not parameters[p][:options].empty? and not parameters[p][:options].include?(values[p.to_s])
      raise ValidationFailure.new(p, parameters[p], 'Wrong value for required parameter')
    end
    if parameters[p][:type].eql?(:optional) and not parameters[p][:options].empty? and
      not values[p.to_s].nil? and not parameters[p][:options].include?(values[p.to_s])
      raise ValidationFailure.new(p, parameters[p], 'Wrong value for optional parameter')
    end
  end
end
