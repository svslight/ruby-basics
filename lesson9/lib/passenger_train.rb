# frozen_string_literal: false

class PassengerTrain < Train
  def initialize(number)
    super(number, 'passenger')
  end
end
