class Wagon
  attr_reader :number, :type, :train  

  def initialize(number, type = nil)
    @number = number
    @type = type      
    @train = nil
  end
  
  # Область видимости методов - public и должны быть доступны "из вне" класса
  
  def attach(train)
    @train = train
  end

  def detach()
    @train = nil
  end   
end