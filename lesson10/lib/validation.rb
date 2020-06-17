# frozen_string_literal: false

class ValidationError < StandardError; end

module Validation
  RULES = {
    type: proc { |value, class_name| raise ValidationError, 'invalid_type' unless value.is_a? class_name },
    format: proc { |value, regexp| raise ValidationError, 'invalid_format' unless value =~ regexp },
    presence: proc { |value| raise ValidationError, 'invalid_presence' if value.to_s.empty? }
  }.freeze

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def validations
      @validations ||= []
    end

    def validate(attr_name, type_validation, optional_param = nil)
      rule = RULES[type_validation]
      @validations ||= []
      @validations << { attr_name: attr_name, rule: rule, optional_param: optional_param }
    end
  end

  module InstanceMethods
    def validate!
      self.class.validations.each do |validation|
        attr_value = instance_variable_get("@#{validation[:attr_name]}".to_sym)
        optional_param = validation[:optional_param]

        validation[:rule].call(attr_value, optional_param)
      end
    end

    def valid?
      validate!
      true
    rescue ValidationError
      false
    end
  end
end
