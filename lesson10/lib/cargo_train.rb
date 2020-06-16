# frozen_string_literal: false

require_relative 'validation'

class CargoTrain < Train
  include Validation
  validate :number, :format, NUMBER_FORMAT
  
  def initialize(number)
    super(number, 'cargo')
    validate!
  end
end
