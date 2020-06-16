# frozen_string_literal: false

require_relative 'instance_counter'
require_relative 'validation'

class Wagon
  include Manufacturer
  include InstanceCounter
  include Validation

  TYPES = %w[cargo passenger].freeze

  attr_reader :number, :type, :train, :free_place

  @@wagons = {}
  
  validate :number, :presence

  def self.all
    @@wagons.keys.join(', ')
  end

  def initialize(number, type = nil, place = nil)
    @number = number
    @type = type
    @place = place

    validate!
    validate_wagon!
    register_instance

    @train = nil
    @@wagons[number] = self
    @free_place = place
  end

  # Область видимости методов - public и должны быть доступны "из вне" класса

  def busy_place(volume)
    free_place = @free_place - volume
    raise ArgumentError, 'no_free_place' if free_place.negative?

    @free_place = free_place
  end

  def occupied_place
    @place - @free_place
  end

  def attach(train)
    @train = train
  end

  def detach
    @train = nil
  end

  def validate_wagon!
    raise ArgumentError, 'incorrect_type_wagon' unless TYPES.include? @type
  end
end
