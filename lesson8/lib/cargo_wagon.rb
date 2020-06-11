class CargoWagon < Wagon
  attr_reader :busy_volume, :free_volume
  
  def initialize(number, volume)
    super(number, 'cargo', volume)
  end  
end