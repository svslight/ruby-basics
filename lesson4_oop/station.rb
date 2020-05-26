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
  
  def show_trains(type = 'all')
    if type == 'all'
      "Quantity trains(#{type}): #{@trains.size}"
    else
       "Quantity trains(#{type}): #{train_type(type).size}"
    end
  end
  
  def train_type(type)
    @trains.select { |train| train.type == type }
  end  
end
