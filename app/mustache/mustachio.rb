class Mustachio < Mustache
  def initialize(action)
    @action = action
    action.instance_variables.each do |instance_variable|
      self.instance_variable_set(instance_variable, action.instance_variable_get(instance_variable))
    end
  end
  
  def method_missing(method, *args)
    @action.send(method,*args)
  end
end