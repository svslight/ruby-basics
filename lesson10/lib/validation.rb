# frozen_string_literal: false

class ValidationError < StandardError; end

module Validation
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def validations
      @validations ||= []
    end

    def validate(attr, type, options = nil)
      @validations ||= []
      @validations << { attr: attr, type: type, options: options }
    end
  end

  module InstanceMethods
    def validate!
      self.class.validations.each do |validation|
        value = instance_variable_get("@#{validation[:attr]}".to_sym)

        send("validate_#{validation[:type]}", value, *validation[:options])
      end
    end

    def validate_presence(value)
      raise ValidationError, 'invalid_presence' if value.to_s.empty?
    end

    def validate_format(value, options)
      raise ValidationError, 'invalid_format' unless value =~ options
    end

    def validate_type(value, options)
      raise ValidationError, 'invalid_type' unless value.is_a? options
    end

    def valid?
      validate!
      true
    rescue ValidationError
      false
    end
  end
end
