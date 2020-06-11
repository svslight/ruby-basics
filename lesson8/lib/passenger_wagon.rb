class PassengerWagon < Wagon
  attr_reader :busy_seats, :free_seats
  
  def initialize(number, count_seats)
    super(number, 'passenger', count_seats)
  end
  
  def busy_place(seats = 1)
    super(seats)
  end
end

