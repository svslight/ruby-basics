require_relative 'instance_counter'

class Station
  include InstanceCounter
  
  attr_reader :name, :trains 
  
  @@stations = {}
  
  def initialize(name)        
    @name = name
    @trains = []     
    @@stations[name] = self  

    register_instance
  end
  
  def self.all
    @@stations.keys.join(', ')
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
