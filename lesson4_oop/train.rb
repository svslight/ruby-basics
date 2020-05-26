class Train
  attr_accessor :speed
  attr_reader :number, :type, :wagons
  
  def initialize(number, type, wagons = 9)
    @number = number
    @type = type
    @wagons = wagons
    @speed = 0
  end 
  
  def add_wagon
    @wagons += 1 if @speed == 0
  end
  
  def remove_wagon
    @wagons -= 1 if @speed == 0 && @wagons > 0
  end
  
  def speed_up(speed)
    self.speed += speed if speed > 0
  end
  
  def stop
    self.speed = 0
  end  

  def route=(route)
    @route = route
    @current_station_index = 0
  end
    
  def current_station
    @route.stations[@current_station_index]
  end
  
  def previous_station
    @route.stations[@current_station_index - 1] unless @current_station_index == 0
  end
  
  def next_station
    @route.stations[@current_station_index + 1] unless @current_station_index == @route.stations.size - 1
  end
  
  
  def next_station_index
    @current_station_index + 1 if @current_station_index && @current_station_index != @route.stations.length - 1
  end

  def prev_station_index
    @current_station_index - 1 if @current_station_index && @current_station_index != 0
  end      
    
    
  def move_next_station
    move(next_station_index)
  end

  def move_prev_station
    move(prev_station_index)
  end
  
 def move(station_index)
   @route.stations[@current_station_index].remove_train(self)
   @route.stations[station_index].add_train(self)
   @current_station_index = station_index
 end
  
end
