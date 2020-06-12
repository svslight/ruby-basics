require_relative 'instance_counter'

class Station
  include InstanceCounter
  
  attr_reader :name, :trains 
  
  @@stations = {}
  
  def initialize(name)              
    @name = name
    @trains = []      
    
    validate!
    register_instance
    
    @@stations[name] = self 
    # @@stations.push(self)  
  end
  
  def self.each
      @@stations.keys.each { |station| yield station }
  end
  
  def each_train
    @trains.each { |train| yield train }
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

  def validate!
    raise ArgumentError, 'duplicate_name' if @@stations[name]
    raise RuntimeError, 'empty_name' if @name.empty?
  end  

end
