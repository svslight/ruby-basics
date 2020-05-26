class Route
  attr_reader :stations
  
  def initialize(first_station, last_station)
    @stations = [first_station, last_station]
  end
  
  def first_station
    stations.first
  end

  def last_station
    stations.last
  end
  
  def add_station(index = -2, station)
    @stations.insert(index, station)
  end
  
  def remove_station(station)
    @stations.delete(station)
  end
  
  def show_route
    @stations.each { |station| station}  
  end
end
