
class Transition

  attr_accessor :to
  attr_accessor :action

  def initialize(to, action)
    @to = to
    @action = action
  end

  def auto?()
    @action.nil?
  end

end
