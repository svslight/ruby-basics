# frozen_string_literal: false

module Accessors
  def attr_accessor_with_history(*attr_names)
    attr_names.each do |attr_name|
      var_name = "@#{attr_name}".to_sym

      var_history = "#{attr_name}_history"
      var_history_name = "@#{var_history}".to_sym

      define_method(attr_name) { instance_variable_get(var_name) }
      define_method(var_history) { instance_variable_get(var_history_name) }

      define_method("#{attr_name}=") do |value|
        var_history = instance_variable_get(var_history_name) || []
        var_prev_value = instance_variable_get(var_name)
        var_history << var_prev_value

        instance_variable_set(var_name, value)
        instance_variable_set(var_history_name, var_history)
      end
    end
  end

  def strong_attr_accessor(attr, class_name)
    var_name = "@#{attr}".to_sym

    define_method("#{attr}=") do |value|
      raise ArgumentError, 'invalid_type' unless value.is_a? class_name

      instance_variable_set(var_name, value)
    end
  end
end
