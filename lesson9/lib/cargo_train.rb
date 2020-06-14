# frozen_string_literal: false

class CargoTrain < Train
  def initialize(number)
    super(number, 'cargo')
  end
end
