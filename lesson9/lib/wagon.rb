# frozen_string_literal: false

require_relative 'instance_counter'

class Wagon
  include Manufacturer
  include InstanceCounter

  TYPES = %w[cargo passenger].freeze

  attr_reader :number, :type, :train, :free_place

  @@wagons = {}

  def self.all
    @@wagons.keys.join(', ')
  end

  def initialize(number, type = nil, place = nil)
    @number = number
    @type = type
    @place = place

    validate!
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

  def validate!
    raise ArgumentError, 'incorrect_type_wagon' unless TYPES.include? @type
  end
end
