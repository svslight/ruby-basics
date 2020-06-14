# frozen_string_literal: false

require_relative 'instance_counter'

class Station
  include InstanceCounter

  attr_reader :name, :trains

  @@stations = {}

  class << self
    def each
      @@stations.each_key { |station| yield station }
    end

    def all
      @@stations.keys.join(', ')
    end
  end

  def initialize(name)
    @name = name
    @trains = []

    validate!
    register_instance

    @@stations[name] = self
  end

  def each_train
    @trains.each { |train| yield train }
  end

  def add_train(train)
    @trains << train
  end

  def remove_train(train)
    @trains.delete(train)
  end

  def select_trains(type)
    @trains.select { |train| train.type == type }
  end

  def validate!
    raise ArgumentError, 'duplicate_name' if @@stations[name]
    raise 'empty_name' if @name.empty? # RuntimeError
  end
end
