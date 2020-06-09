require_relative 'instance_counter'

class Wagon
  include Manufacturer
  include InstanceCounter
  
  attr_reader :number, :type, :train  

  @@wagons = {}
  
  TYPES = %w[cargo passenger].freeze

  def initialize(number, type = nil)
    @number = number
    @type = type      
    @train = nil
    @@wagons[number] = self
    
    validate!
    register_instance
  end
  
  # Область видимости методов - public и должны быть доступны "из вне" класса
  
  def self.all
    @@wagons.keys.join(', ')
  end
  
  def attach(train)
    @train = train
  end

  def detach()
    @train = nil
  end
  
  def validate!
    raise ArgumentError, 'incorrect_type' unless TYPES.include? @type
  end      
end