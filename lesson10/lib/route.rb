# frozen_string_literal: false

require_relative 'instance_counter'
require_relative 'validation'

class Route
  include InstanceCounter
  include Validation

  attr_reader :number, :stations, :first_station, :last_station
  
  validate :first_station, :type, Station
  validate :last_station, :type, Station

  def initialize(first_station, last_station)
    @first_station = first_station
    @last_station = last_station
    @stations = [first_station, last_station]
    @number = "#{first_station.name}-#{last_station.name}"

    validate!
    validate_route!
    register_instance
  end

  def add_station(station, index = -2)
    @stations.insert(index, station)
  end

  def remove_station(station)
    @stations.delete(station)
  end

  def validate_route!
    raise ArgumentError, 'stations_same' if @first_station == @last_station
  end
end
