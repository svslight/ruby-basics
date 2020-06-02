class Train
  attr_accessor :speed
  attr_reader :number, :type, :wagons, :route
  
  @@trains = {}
  
  def initialize(number, type = nil)
    @number = number
    @type = type    
    @speed = 0
    @wagons = []
    @@trains[number] = self
  end
  
  def self.find(number)
    @@trains[number]
  end
  
  def add_route(route)
    @route = route
    @current_station_index = 0
  end
  
  def add_wagon(wagon)
    raise 'type_incorrected' if wagon.type != @type
    raise 'non_zero_speed' if @speed != 0
    
    wagon.attach(self)
    @wagons.push(wagon)
  end
  
  def remove_wagon(wagon)
    raise 'non_zero_speed' if @speed != 0
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
 
  protected 
  
  # Данные методы не должны быть доступны "из вне" класса, 
  # доступны только внутри данного класса (доступны подклассам) и не используются в клиентском коде.
 
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
end
