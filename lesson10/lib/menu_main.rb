# frozen_string_literal: false

require_relative 'manufacturer.rb'
require_relative 'instance_counter.rb'
require_relative 'station.rb'
require_relative 'route.rb'
require_relative 'train.rb'
require_relative 'wagon.rb'
require_relative 'passenger_train.rb'
require_relative 'cargo_train.rb'
require_relative 'passenger_wagon.rb'
require_relative 'cargo_wagon.rb'

class MenuMain
  TYPE_WAGON = { 'cargo' => 'грузовой', 'passenger' => 'пассажирский' }.freeze
  TYPE_TRAIN = { 'cargo' => 'грузовой', 'passenger' => 'пассажирский' }.freeze

  ERROR_MESSAGES = {
    # 'incorrect_number_train' => 'Введен некорректный формат (номера) поезда. Повторите ввод!',
    'incorrect_type_train' => 'Введен некорректный тип поезда. Повторите ввод!',
    'incorrect_type_wagon' => 'Введен некорректный тип вагона. Повторите ввод!',
    'non_zero_speed' => 'Невозможно прицепить вагон, поезд находится в движении. Остановите поезд!'
  }.freeze

  def initialize
    @stations = []
    @trains = []
    @wagons = []
    @routes = []
  end

  # Главное меню
  def menu_main
    print "\nГлавное меню: "
    print "\n1 - Управление Станциями"
    print "\n2 - Управление Маршрутами"
    print "\n3 - Управление Вагонами"
    print "\n4 - Управление Поездами"
    print "\n0 - Выход из программы"
    print "\n Введите пункт меню: "

    choice = gets.chomp
    case choice
    when '1'
      menu_stations
    when '2'
      menu_routes
    when '3'
      menu_wagons
    when '4'
      menu_trains
    end
  end

  private

  # Меню блоков действий
  def menu_stations
    actions = {
      create: -> { create_stations },
      show: -> { show_stations },
      all: -> { all_stations }
    }
    menu_block('Станции', actions)
  end

  def menu_routes
    actions = {
      create: -> { create_routes },
      manage: -> { manage_routes },
      show: -> { show_routes },
      all: -> { all_routes }
    }
    menu_block('Маршруты', actions)
  end

  def menu_wagons
    actions = {
      create: -> { create_wagons },
      manage: -> { manage_wagons },
      show: -> { show_wagons },
      all: -> { all_wagons }
    }
    menu_block('Вагоны', actions)
  end

  def menu_trains
    actions = {
      create: -> { create_trains },
      manage: -> { manage_trains },
      show: -> { show_trains },
      all: -> { all_trains }
    }
    menu_block('Поезда', actions)
  end

  # Создание Станций
  def create_stations
    submenu_block(
      'Станции',
      "\nВведите название (новой станции) (или пункт меню)"
    ) do |result|
      begin
        station = Station.new(result)
      rescue ArgumentError => e
        raise unless e.message == 'duplicate_name'
        puts "Внимание!!! Такая станция: #{result} уже существует.  Повторите ввод!"
      rescue ValidationError => e
        raise unless e.message == 'invalid_presence'
        puts 'Внимание!!! Название станции не должно быть пустым. Повторите ввод!'
      else
        @stations << station
        puts "Станция создана: #{result}"
      end
    end
  end

  # Общая информация о всех станциях
  def all_stations
    submenu_block(
      'Станции',
      "\nДля получение общей информации по станциям (нажмите Enter)"
    ) do |_result|
      puts "Список станций (#{Station.instances}): #{Station.all}"

      Station.each do |station|
        station = @stations.detect { |s| s.name == station }
        information_stations(station)
      end
    end
  end

  # Информация о станции
  def show_stations
    submenu_block(
      'Станции',
      "\nВведите (название станции) для получения информации"
    ) do |result|
      station = @stations.detect { |s| s.name == result }

      unless station
        puts 'Внимание!!! Такой станции нет. Повторите ввод!'
        next
      end

      information_stations(station)
    end
  end

  def information_stations(station)
    print "\nИнформация о станции (#{station.name}): "

    if !station.trains.empty?
      print "\nСписок поездов:"
      station.each_train do |train|
        print "\n* поезд - #{train.number}; тип - #{TYPE_TRAIN[train.type]}; кол-во вагонов - #{train.wagons.length}"
      end
    else
      print ' * на станции нет поездов...'
    end
  end

  # Создание маршрутов
  def create_routes
    if @stations.length < 2
      print "\nПеред созданием (маршрута), необходимо создать (минимум 2 станции)"
      menu_routes
    end

    submenu_block(
      'Маршруты',
      "\nВведите названия (начальной и конечной станций) маршрута (или пункт меню)." \
        "Доступные станции: #{verify(:@name, @stations)}"
    ) do |result|
      first_station, last_station = result.split(',')

      first_station = @stations.detect { |station| station.name == first_station }
      last_station = @stations.detect { |station| station.name == last_station }

      if !first_station || !last_station
        puts 'Внимание!!! Такой станции не существует. Повторите ввод!'
        next
      end

      begin
        route = Route.new(first_station, last_station)
      rescue ArgumentError => e
        raise unless e.message == 'stations_same'
        puts 'Внимание!!! Начальная и конечная станции маршрута не должны совпадать. Повторите ввод!'
      rescue ValidationError => e
        raise unless e.message == 'invalid_type'
        puts 'Станция не соответствует заданному классу'
      else
        route_exists = @routes.detect { |r| r.number == route.number }

        if route_exists
          puts 'Внимание! Маршрут уже существует. Повторите ввод!'
          next
        end

        @routes << route
        puts "Создан маршрут (#{route.number}) со станциями: #{verify(:@name, [route.first_station, route.last_station])}"
      end
    end
  end

  # Управление маршрутами
  def manage_routes
    submenu_block(
      'Маршруты',
      "\nВведите (маршрут) для изменения(или пункт меню): (Начальная станция-Конечная станция)"
    ) do |result|
      route = @routes.detect { |r| r.number == result }

      unless route
        puts 'Внимание! Маршрут не существует. Повторите ввод!'
        next
      end

      print "\nИнформация о маршруте #{route.number}:"
      print "\n Список станции: #{verify(:@name, route.stations)}"

      print "\n1 - Добавить станции в маршрут"
      print "\n2 - Удалить станции из маршрута"
      print "\n0 - Вернуться в меню блока Маршруты"
      print "\n Введите пункт меню: "

      choice = gets.chomp
      case choice
      when '1'
        add_station_to_route(route)
      when '2'
        remove_station_from_route(route)
      else
        menu_routes
        break
      end
    end
  end

  # Добавить станцию в маршрут
  def add_station_to_route(route)
    loop do
      free_stations = @stations.reject { |station| (route.stations.include? station) }

      if free_stations.empty?
        print "\nНет доступных станций к добавлению..."
        break
      end

      puts "\nДоступные Станции к добавлению: #{verify(:@name, free_stations)}"
      print "\nВведите (название станции) для добавления в маршрут(или пункт меню)"
      print "\n1 - Вернуться в меню: 'Управления Маршрутами'"
      print "\n0 - Вернуться в меню блока: 'Маршруты'"
      print "\n Выполните ввод: "

      choice = gets.chomp
      case choice
      when '1'
        break
      when '0'
        menu_routes
        break
      else
        station = free_stations.detect { |s| s.name == choice }

        begin
          route.add_station(station)
          print "\nСтанция (#{station.name}) добавлена в маршрут: #{route.number}"
          print "\nМаршрут (#{route.number}), включает станции: #{verify(:@name, route.stations)}"
        rescue StandardError
          puts 'Внимание!!! Введено некорректное имя станции. Повторите ввод!'
          next
        end
      end
    end
  end

  # Удаление станции из маршрута
  def remove_station_from_route(route)
    loop do
      stations = route.stations

      if stations.empty?
        print "\nНет промежуточных станций для удаления из маршрута (#{route.number})"
        break
      end

      print "\nДоступные станции к удалению: #{verify(:@name, stations)} из маршрута (#{route.number})"
      print "\nВведите (название станции), которую нужно удалить из маршрута (#{route.number})"
      print "\n1 - Вернуться в меню: 'Управления Маршрутами'"
      print "\n0 - Вернуться в меню блока: 'Маршруты'"
      print "\n Выполните ввод: "

      choice = gets.chomp
      case choice
      when '1'
        break
      when '0'
        menu_routes
        break
      else
        station = stations.detect { |s| s.name == choice }

        begin
          route.remove_station(station)
          puts "Станция (#{station.name}) удалена из маршрута (#{route.number})"
          puts "Маршрут (#{route.number}), включает станции: #{verify(:@name, route.stations)}"
        rescue StandardError
          puts 'Внимание!!! Введено некорректное имя станции. Повторите ввод!'
          next
        end
      end
    end
  end

  # Общая информация о маршрутах
  def all_routes
    submenu_block(
      'Маршруты',
      "\nДля получение общей информации о маршрутах (нажмите Enter)"
    ) do |_result|
      puts "Всего создано маршрутов: #{Route.instances}"
    end
  end

  # Информация о маршруте
  def show_routes
    submenu_block(
      'Маршруты',
      "\nВведите (маршрут) для получения информации"
    ) do |result|
      route = @routes.detect { |r| r.number == result }

      begin
        puts "Информация о маршруте (#{route.number}):"
        puts "* список станций: #{verify(:@name, route.stations)}"
      rescue StandardError
        puts 'Внимание!!! Введен несуществующий маршрут. Повторите ввод!'
        next
      end
    end
  end

  # Создание вагонов
  def create_wagons
    type_wagon = Hash.new({
                            type: 'electrictrain',
                            ru: 'электропоезд',
                            class_name: Wagon
                          })

    type_wagon['g'] = {
      type: 'cargo',
      ru: 'грузовой',
      class_name: CargoWagon
    }

    type_wagon['p'] = {
      type: 'passenger',
      ru: 'пассажирский',
      class_name: PassengerWagon
    }

    submenu_block(
      'Вагоны',
      "\nВведите номер вагона, тип, кол-во мест для пасс.ваг или общий объем для груз.ваг (или пункт меню):" \
        "(11,g/p,68) (g = #{type_wagon['g'][:ru]}, p = #{type_wagon['p'][:ru]})"
    ) do |result|
      number, type, place = result.split(',')

      puts 'Внимание!!! Не все параметры введены. Повторите, пожалуйста!' if !number || !type || !place

      begin
        wagon = type_wagon[type][:class_name].new(number, place.to_i)
      rescue ArgumentError => e
        raise unless e.message == 'incorrect_type_wagon'
        puts "Введен некорректный тип вагона. Повторите, пожалуйста!"
      rescue ValidationError => e
        raise unless e.message == 'invalid_presence'
        puts 'Номер вагона не должно быть пустым. Повторите ввод!'
      else
        @wagons << wagon

        print "\nСоздан (#{type_wagon[type][:ru]}) вагон с номером: #{wagon.number}"
        print "\nОбщий объём (т): #{wagon.free_place}" if wagon.type == 'cargo'
        print "\nКол-во мест: #{wagon.free_place}" if wagon.type == 'passenger'
      end
    end
  end

  # Управление вагонами
  def manage_wagons
    submenu_block(
      'Вагоны',
      "\nВведите (номер вагона) для внесения изменений (или пункт меню): "
    ) do |result|
      wagon = @wagons.detect { |w| w.number == result }

      unless wagon
        puts 'Введен несуществующий номер вагона. Повторите ввод!'
        next
      end

      information_wagon(wagon)

      # if wagon.type == 'cargo'
      # print "\n1 - Чтобы занять свободный объем (т) в грузовом вагоне"
      # else
      # print "\n1 - Чтобы занять свободное место в пассажирском вагоне"
      # end

      print "\n1 - Чтобы занять свободный объем (т) в грузовом вагоне" if wagon.type == 'cargo'
      print "\n1 - Чтобы занять свободное место в пассажирском вагоне" if wagon.type == 'passenger'
      print "\n0 - Вернуться в меню блока: 'Вагоны'"
      print "\n Введите пункт меню: "

      choice = gets.chomp

      if choice == '1'
        print 'Ведите кол-во объема (т), которое необходимо занять в грузовом вагоне: ' if wagon.type == 'cargo'
        print 'Нажмите Enter, чтобы забранировать 1 место в пассажирском вагоне: ' if wagon.type == 'passenger'

        volume = gets.chomp.to_i
        modification_wagon(volume, wagon)
      else
        menu_wagons
        break
      end
    end
  end

  def modification_wagon(volume, wagon)
    wagon.busy_place(volume) if wagon.type == 'cargo'
    wagon.busy_place if wagon.type == 'passenger'
  rescue ArgumentError => e
    raise unless e.message == 'no_free_place'

    print "\n Невозможно занять указанное кол-во объема, свободно - #{wagon.free_place} тонн" if wagon.type == 'cargo'
    print "\n Невозможно забранировать место - свободных мест нет" if wagon.type == 'passenger'
  else
    if wagon.type == 'cargo'
      puts "Вы заняли #{volume} тонн объема"
      puts "Кол-во занятого объема - #{wagon.occupied_place} тонн, " \
        "кол-во свободного объема - #{wagon.free_place} тонн"
    end

    if wagon.type == 'passenger'
      puts 'Вы заняли место'
      puts "Кол-во занятых мест - #{wagon.occupied_place}, " \
        "кол-во свободных мест - #{wagon.free_place}"
    end
  end

  # Общая информация о вагонах
  def all_wagons
    submenu_block(
      'Вагоны',
      "\nДля получение общей информации о вагонах (нажмите Enter)"
    ) do |_result|
      puts "Список вагонов: #{Wagon.all}"
      puts "Всего создано вагонов: #{CargoWagon.instances + PassengerWagon.instances}"
      puts "* пассажирских: #{PassengerWagon.instances}"
      puts "* грузовых: #{CargoWagon.instances}"
    end
  end

  # Информация о вагоне
  def show_wagons
    submenu_block(
      'Вагоны',
      "\nВведите (номер вагона) для получения информации"
    ) do |result|
      wagon = @wagons.detect { |w| w.number == result }

      begin
        information_wagon(wagon)
      rescue StandardError
        puts 'Внимание!!! Введен несуществующий номер вагона. Повторите ввод!'
        next
      end
    end
  end

  # Информация о вагоне
  def information_wagon(wagon)
    puts "Информация о вагоне (#{wagon.number}):"
    puts "* тип - #{TYPE_WAGON[wagon.type]}"
    puts "* свободный объём (т): #{wagon.free_place}" if wagon.type == 'cargo'
    puts "* свободное кол-во мест: #{wagon.free_place}" if wagon.type == 'passenger'

    if wagon.train
      puts "* прицеплен к поезду - #{wagon.train.number}"
    else
      puts '* вагон не прицеплен к поезду - свободен'
    end
  end

  # Создание поездов
  def create_trains
    type_train = Hash.new({
                            type: 'electrictrain',
                            ru: 'электропоезд',
                            class_name: Train
                          })

    type_train['g'] = {
      type: 'cargo',
      ru: 'грузовой',
      class_name: CargoTrain
    }

    type_train['p'] = {
      type: 'passenger',
      ru: 'пассажирский',
      class_name: PassengerTrain
    }

    submenu_block(
      'Поезда',
      "\nВведите (номер, тип) поезда (или пункт меню): (num,g) (g = #{type_train['g'][:ru]}, p = #{type_train['p'][:ru]})"
    ) do |result|
      number, type = result.split(',')

      # train_exists = Train.find(number)
      train_exists = @trains.find { |train| train.number == number }

      if train_exists
        puts "Поезд с номером #{number} уже существует..."
        next
      end

      begin
        train = type_train[type][:class_name].new(number)
      rescue ArgumentError => e
        error_messages(e.message)
      rescue ValidationError => e
        raise unless e.message == 'invalid_format'
        puts 'Введен некорректный формат (номера) поезда. Повторите ввод!'        
      else
        @trains << train
        puts "Создан (#{type_train[type][:ru]}) поезд с номером: #{train.number}"
      end
    end
  end

  # Общая информация о поездах
  def all_trains
    submenu_block(
      'Поезда',
      "\nДля получение общей информации о поездах (нажмите Enter)"
    ) do |_result|
      puts "Список поездов #{Train.all}"
      puts "Всего создано поездов: #{CargoTrain.instances + PassengerTrain.instances}"
      puts "* пассажирских: #{PassengerTrain.instances}"
      puts "* грузовых: #{CargoTrain.instances}"
    end
  end

  # Информация о поезде (вызов подменю)
  def show_trains
    submenu_block(
      'Поезда',
      "\nВведите (номер поезда) для получения информации"
    ) do |result|
      train = @trains.detect { |t| t.number == result }

      begin
        information_train(train)
      rescue StandardError
        puts 'Внимание!!! Введен несуществующий номер поезда. Повторите ввод!'
        next
      end
    end
  end

  # Информация о поезде
  def information_train(train)
    puts "Информация о поезде (#{train.number}):"
    puts "* тип - #{TYPE_TRAIN[train.type]}"
    puts "* текущая скорость - #{train.speed}"

    if train.route
      puts "* маршрут (#{train.route.number}), со станциями: #{verify(:@name, train.route.stations)}"
    else
      puts '* маршрут - не присвоен поезду'
    end

    puts "* текущая станция - #{train.current_station.name}" if train.current_station
    puts "* следующая станция - #{train.next_station.name}" if train.next_station
    puts "* предыдущая станция - #{train.previous_station.name}" if train.previous_station

    if !train.wagons.empty?
      puts '* вагоны: '
      train.each_wagon { |wagon| information_wagon(wagon) }
    else
      puts '* вагоны - отсутствуют'
    end
  end

  # Управление поездами (вызов подменю)
  def manage_trains
    submenu_block(
      'Поезда',
      "\nВведите (номер поезда) для внесения изменений (или пункт меню)"
    ) do |result|
      train = @trains.detect { |t| t.number == result }

      unless train
        puts "\nВнимание!!! Введен несуществующий номер поезда. Повторите ввод!"
        next
      end

      information_train(train)

      print "\n1 - Добавить маршрут"
      print "\n2 - Привести поезд в движение"
      print "\n3 - Остановить поезд"
      print "\n4 - Переместить на следующую станцию"
      print "\n5 - Переместить на предыдущую станцию"
      print "\n6 - Добавить вагоны"
      print "\n7 - Удалить вагоны"
      print "\n0 - Вернуться в меню блока 'Поезда'"
      print "\n Введите пункт меню: "

      choice = gets.chomp
      case choice
      when '1'
        add_route_to_train(train)
      when '2'
        speed_up_train(train)
      when '3'
        speed_down_train(train)
      when '4'
        move_train_to_next_station(train)
      when '5'
        move_train_to_prev_station(train)
      when '6'
        add_wagon_to_train(train)
      when '7'
        remove_wagon_from_train(train)
      else
        menu_trains
        break
      end
    end
  end

  # Добавить вагон к поезду
  def add_wagon_to_train(train)
    loop do
      if !train.wagons.empty?
        puts "К поезду (#{train.number}) прицеплены вагоны: #{verify(:@number, train.wagons)}"
      else
        puts "У поезда (#{train.number}) нет прицепленных вагонов..."
      end

      free_wagons = @wagons.reject(&:train)

      if free_wagons.empty?
        puts 'Свободные вагоны отсутствуют...'
        break
      end

      print "\nСвободные вагоны: #{verify(:@number, free_wagons)}"

      print "\nВведите (номер вагона), чтобы прицепить к поезду (#{train.number})"
      print "\n1 - Вернуться в меню: 'Управления поездами'"
      print "\n0 - Вернуться в меню блока: 'Поезда'"
      print "\n Выполните ввод: "

      choice = gets.chomp
      case choice
      when '1'
        break
      when '0'
        menu_trains
        break
      else
        wagon = free_wagons.detect { |w| w.number == choice }

        unless wagon
          puts 'Внимание!!! Введен некорректный номер вагона. Пожалуйста, повторите!'
          next
        end

        begin
          train.add_wagon(wagon)
        rescue ArgumentError => e
          error_messages(e.message)
        else
          puts "Вагон (#{wagon.number}) прицеплен к поезду (#{train.number})"
        end
      end
    end
  end

  # Удалить вагоны
  def remove_wagon_from_train(train)
    loop do
      if !train.wagons.empty?
        puts "К поезду (#{train.number}) прицеплены вагоны: #{verify(:@number, train.wagons)}"
      else
        puts "У поезда (#{train.number}) - нет вагонов"
        break
      end

      free_wagons = train.wagons

      print "\nВведите (номер вагона), чтобы отцепить от поезда - (#{train.number})"
      print "\n1 - Вернуться в меню: 'Управления поездами'"
      print "\n0 - Ввернуться в меню блока: 'Поезда'"
      print "\n Выполните ввод: "

      choice = gets.chomp
      case choice
      when '1'
        break
      when '0'
        menu_trains
        break
      else
        wagon = free_wagons.detect { |w| w.number == choice }

        unless wagon
          puts 'Внимание!!! Введен некорректный номер вагона. Пожалуйста, повторите!'
          next
        end

        begin
          train.remove_wagon(wagon)
        rescue ArgumentError => e
          raise unless e.message == 'non_zero_speed'
          puts "Невозможно отцепить вагон! Поезд (#{train.number}) находится в движении, текущая скорость - #{train.speed}"
        else
          puts "Вагон (#{wagon.number}) отцеплен от поезда (#{train.number})"
        end
      end
    end
  end

  # Добавить маршрут к поезду
  def add_route_to_train(train)
    loop do
      if train.route
        puts "Поезду (#{train.number}) присвоен маршрут: #{train.route.number}"
      else
        puts "Поезду (#{train.number}) - маршрут не присвоен"
      end

      free_routes = @routes.reject { |route| route == train.route }

      if free_routes.empty?
        puts 'Доступные маршруты отсутствуют: ... '
        break
      end

      print "\nДоступные маршруты: #{verify(:@number, free_routes)}"
      print "\nВведите (маршрут), который хотите присвоить поезду #{train.number} (или пункт меню)"
      print "\n1 - Вернуться в меню: 'Управления Поездами'"
      print "\n0 - Вернуться в меню блока: 'Поезда'"
      print "\n Выполните ввод: "

      choice = gets.chomp
      case choice
      when '1'
        break
      when '0'
        menu_train
        break
      else
        route = free_routes.detect { |r| r.number == choice }

        begin
          train.add_route(route)
          puts "Маршрут (#{route.number}) со станциями: #{verify(:@name, route.stations)} -> присвоен поезду: #{train.number}"
        rescue StandardError
          puts 'Внимание!!! Введен некорректный маршрут. Повторите ввод!'
        end
      end
    end
  end

  # Привести поезд в движение
  def speed_up_train(train)
    if train.speed.positive?
      puts "Поезд (#{train.number}) уже находится в движении. Текущая скорость - #{train.speed}"
    else
      train.speed_up
      puts "Поезд (#{train.number}) приведен в движение. Текущая скорость - #{train.speed}"
    end
  end

  # Остановить поезд
  def speed_down_train(train)
    if train.speed.zero?
      puts "Поезд (#{train.number}) уже остановлен. Текущая скорость - #{train.speed}"
    else
      train.stop
      puts "Поезд (#{train.number}) остановлен. Текущая скорость - #{train.speed}"
    end
  end

  # Переместить на следующую станцию
  def move_train_to_next_station(train)
    if !train.route
      puts "Поезду (#{train.number}) не присвоен маршрут"
    elsif !train.next_station
      puts "Поезд (#{train.number}) невозможно переместить на следующую станцию. Текущая станция поезда (#{train.current_station.name}) - конечная"
    else
      train.move_next_station
      puts "Поезд (#{train.number}) перемещен на станцию - #{train.current_station.name}"
    end
  end

  # Переместить на предыдущую станцию
  def move_train_to_prev_station(train)
    if !train.route
      puts "Поезду (#{train.number}) маршрут не присвоен"
    elsif !train.previous_station
      puts "Поезд (#{train.number}) невозможно переместить на предыдущую станцию. Текущая станция поезда (#{train.current_station.name}) - начальная"
    else
      train.move_prev_station
      puts "Поезд (#{train.number}) перемещен на станцию - #{train.current_station.name}"
    end
  end

  # Меню блока
  def menu_block(block_name, actions)
    actions_new = {}

    print "\nУправление блоком '#{block_name}': "

    actions.each.with_index(1) do |(type, _count), index|
      actions_new[index] = type
      case type
      when :create
        print "\n #{index} - Создать"
      when :manage
        print "\n #{index} - Управлять"
      when :all
        print "\n #{index} - Получить общую информацию блока #{block_name}"
      when :show
        print "\n #{index} - Получить информацию по конкретному элементу блока #{block_name}"
      end
    end

    print "\n 0 - Вернуться в главное меню"
    print "\n Введите пункт меню: "

    choice = gets.chomp.to_i
    action = actions[actions_new[choice]]
    action ? action.call : menu_main
  end

  # Подменю блока
  def submenu_block(block_name, action)
    block_items = {
      'Станции' => {
        items: @stations,
        block_menu: -> { menu_stations }
      },
      'Маршруты' => {
        items: @routes,
        block_menu: -> { menu_routes }
      },
      'Вагоны' => {
        items: @wagons,
        block_menu: -> { menu_wagons }
      },
      'Поезда' => {
        items: @trains,
        block_menu: -> { menu_trains }
      }
    }

    items = block_items [block_name][:items]
    block_menu = block_items [block_name][:block_menu]

    continue = nil
    loop do
      print action if action
      print "\n 1 - Вернуться в меню блока: '#{block_name}'"
      print "\n 0 - Вернуться в 'Главное меню'"
      print "\n Выполните ввод: "

      result = gets.chomp
      case result
      when '1'
        continue = block_menu
        break
      when '0'
        continue = -> { menu_main }
        break
      else
        continue = block_menu
        yield(result) if block_given?
      end
    end

    puts "Внимание! #{block_name} не созданы" if items.empty?
    continue.call
  end

  def error_messages(message)
    @message = ERROR_MESSAGES[message] || raise
    puts @message.to_s
  end

  # Проверить элемент
  def verify(param, items)
    result = ''
    items.each { |item| result << "#{item.instance_variable_get(param)}," }
    result.rstrip.chop
  end
end
