# frozen_string_literal: false

require_relative 'validation'

class PassengerTrain < Train
  include Validation
  validate :number, :format, NUMBER_FORMAT

  def initialize(number)
    super(number, 'passenger')
    validate!
  end
end
