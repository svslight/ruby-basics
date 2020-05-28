class Station
  attr_reader :name
  
  def initialize(name)
    @name = name
    @trains = []
  end
   
  def add_train(train)
    #@trains << train
    @trains.push(train)
  end
  
  def remove_train(train)
    @trains.delete(train)
  end
  
  def select_trains(type)
    @trains.select { |train| train.type == type }
  end  
end