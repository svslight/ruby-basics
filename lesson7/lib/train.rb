require_relative 'instance_counter'

class Train
  include Manufacturer
  include InstanceCounter
  
  attr_accessor :speed
  attr_reader :number, :type, :wagons, :route
  
  NUMBER_FORMAT = /^[a-z0-9]{3}-*[a-z0-9]{2}$/i.freeze
  TYPES = %w[cargo passenger].freeze
  
  @@trains = {}
  
  def initialize(number, type = nil)
    @number = number
    @type = type
    
    validate!
    register_instance
        
    @speed = 0
    @wagons = []    
    @@trains[number] = self 
  end
  
  def self.find(number)
    @@trains[number]
  end  
 
  def self.all
    @@trains.keys.join(', ')
  end
  
  def add_route(route)
    @route = route
    @current_station_index = 0
  end
  
  def add_wagon(wagon)
    raise ArgumentError, 'incorrect_type' if wagon.type != @type
    raise ArgumentError, 'non_zero_speed' if @speed != 0
    
    wagon.attach(self)
    @wagons.push(wagon)
  end
  
  def remove_wagon(wagon)
    raise ArgumentError, 'non_zero_speed' if @speed != 0
    
    wagon.detach()
    @wagons.delete(wagon)
  end
  
  def count_wagons
    @wagons.size
  end
  
  def speed_up
    self.speed = current_speed
  end
  
  def stop
    self.speed = 0
  end  
      
  def current_station
    get_station(@current_station_index)
  end
  
  def next_station
    get_station(next_station_index)
  end
  
  def previous_station
    get_station(prev_station_index)
  end    
    
  def move_next_station
    move(next_station_index)
  end

  def move_prev_station
    move(prev_station_index)
  end
 
  private 
  
  # Данные методы не должны быть доступны "из вне" класса, 
  # доступны только внутри данного класса (и не доступны подклассам) и не используются в клиентском коде.
 
  def next_station_index
    @current_station_index + 1 if @current_station_index && @current_station_index != @route.stations.length - 1
  end

  def prev_station_index
    @current_station_index - 1 if @current_station_index && @current_station_index != 0
  end 
  
  def get_station(station_index)
    station_index && @route.stations[station_index]
  end
  
  def move(station_index)
    @route.stations[@current_station_index].remove_train(self)
    @route.stations[station_index].add_train(self)    
    @current_station_index = station_index
  end
  
  def current_speed
    200
  end
  
  def validate!
    raise ArgumentError, 'incorrect_number' unless @number =~ NUMBER_FORMAT
    raise ArgumentError, 'incorrect_type' unless TYPES.include? @type
  end
  
end
