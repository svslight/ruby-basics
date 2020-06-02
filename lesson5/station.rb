class Station
  attr_reader :name, :trains
  @@stations = {}
  
  def initialize(name)
    @name = name
    @@stations[name] = self
    @trains = []
  end
  
  def self.all
    @@stations
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
end