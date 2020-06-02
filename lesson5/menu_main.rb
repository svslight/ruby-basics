require_relative 'station.rb'
require_relative 'route.rb'
require_relative 'train.rb'
require_relative 'wagon.rb'
require_relative 'passenger_train.rb'
require_relative 'cargo_train.rb'
require_relative 'passenger_wagon.rb'
require_relative 'cargo_wagon.rb'

class MenuMain
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
      else
        return
    end
  end
  
  private
  
  # Меню блоков действий  
  def menu_stations
    actions = {
      create: lambda { create_stations },
      show: lambda { show_stations }
    }
    menu_block("Станции", actions)
  end
  
  def menu_routes
    actions = {
      create: lambda { create_routes },
      manage: lambda { manage_routes },
      show: lambda { show_routes }
    }
    menu_block("Маршруты", actions)
  end
  
  def menu_wagons
    actions = {
      create: lambda { create_wagons },
      show: lambda { show_wagons }
    }
    menu_block("Вагоны", actions)
  end
  
  def menu_trains
    actions = {
      create: lambda { create_trains },
      manage: lambda { manage_trains },
      show: lambda { show_trains }
    }
    menu_block("Поезда", actions)      
  end
  
  # Создание Станций   
  def create_stations
    submenu_block(
      "Станции",
      "\nВведите название (новой станции) (или пункт меню)",
    ) do |result|
            
      begin
        station = Station.new(result)
      rescue => e
        puts e.message
      else
        @stations << station
        puts "Станция создана: #{result}"
      end      
    end
  end  
  
  # Создание маршрутов
  def create_routes
    if @stations.length < 2
      print "\nПеред созданием (маршрута), необходимо создать (минимум 2 станции)"
      menu_routes
    end

    submenu_block(
      "Маршруты",
      "\nВведите названия (начальной и конечной станций) маршрута (или пункт меню). Доступные станции: #{verify(:@name, @stations)}",
    ) do |result|           
      first_station, last_station = result.split(",")
      first_station = @stations.detect { |station| station.name == first_station }
      last_station = @stations.detect { |station| station.name == last_station }      

      if !first_station
        puts "Внимание!!! Начальной станции не существует. Повторите ввод!"
        next
      end

      if !last_station
        puts "Внимание!!! Конечной станции не существует. Повторите ввод!"
        next
      end

      begin
        route = Route.new(first_station, last_station)
      rescue => e
        puts e.message
      else
        @routes << route
        puts "Создан маршрут (#{route.number}) со станциями: #{verify(:@name, [route.first_station, route.last_station])}"
      end
    end
  end  

  # Создание вагонов
  def create_wagons
    typeWagon = Hash.new
    
    typeWagon['g'] = {
      type: 'cargo',
      ru: 'грузовой',
      class_item: CargoWagon
    }

    typeWagon['p'] = {
      type: 'passenger',
      ru: 'пассажирский',
      class_item: PassengerWagon
    }
    
    submenu_block(
      "Вагоны",
      "\nВведите (номер вагона и тип) (или пункт меню): (num,g) (g = #{typeWagon['g'][:ru]}, p = #{typeWagon['p'][:ru]})",
    ) do |result|
      number, type = result.split(",") 

      begin
        wagon = typeWagon[type][:class_item].new(number)
      rescue => e
        puts e.message
      else
        @wagons << wagon
        print "\nСоздан (#{typeWagon[type][:ru]}) вагон с номером: #{wagon.number}"
      end      
    end
  end

  # Создание поездов
  def create_trains
    typeTrain = Hash.new  
      
    typeTrain['g'] = {
      type: 'cargo',
      ru: 'грузовой',
      class_item: CargoTrain
    }

    typeTrain['p'] = {
      type: 'passenger',
      ru: 'пассажирский',
      class_item: PassengerTrain
    }

    submenu_block(
      "Поезда",
      "\nВведите (номер и тип поезда) (или пункт меню): (num,g) (g = #{typeTrain['g'][:ru]}, p = #{typeTrain['p'][:ru]})",
    ) do |result|
      number, type = result.split(",")
      dublicated = Train.find(number)
      
      if dublicated
        puts "Поезд с номером #{number} уже существует..."
        next
      end

      begin
        train = typeTrain[type][:class_item].new(number)
      rescue => e
        puts e.message
      else
        @trains << train
        puts "Создан (#{typeTrain[type][:ru]}) поезд с номером: #{train.number}"
      end      
    end
  end  
 
  # Информация о станции
  def show_stations
    submenu_block(
      "Станции",
      "\nВведите (название станции) для получения информации",
    ) do |result|
      station = @stations.detect { |station| station.name == result }
      
      if !station
        puts "Внимание!!! Такой станции нет. Повторите ввод!"
        next
      end

      puts "Информация о станции #{station.name}: "      
      if station.trains.length > 0
        puts "Список поездов: #{verify(:@number, station.trains)}:"
        puts "* грузовые: #{verify(:@number, station.select_trains(:cargo))}"
        puts "* пассажирские: #{verify(:@number, station.select_trains(:passenger))}"
      else
        puts "* на станции нет поездов..."
      end
    end
  end
  
  # Информация о маршруте
  def show_routes
    submenu_block(
      "Маршруты",
      "\nВведите (маршрут) для получения информации",
    ) do |result|
      route = @routes.detect { |route| route.number == result }
      
      if !route
        puts "Внимание!!! Введен несуществующий маршрут. Повторите ввод!"
        next
      end

      puts "Информация о маршруте (#{route.number}):"
      puts "* список станций: #{verify(:@name, route.stations)}"
    end
  end
  
  # Информация о поезде (вызов подменю)
  def show_trains
    submenu_block(
      "Поезда",
      "\nВведите (номер поезда) для получения информации",
    ) do |result|
      train = @trains.detect { |train| train.number == result }

      if !train
        puts "Внимание!!! Введен несуществующий номер вагона. Повторите ввод!"
        next
      end
      information_train(train)
    end
  end
  
  # Информация о поезде
  def information_train(train)
    typeTrain = { cargo: 'грузовой', passenger: 'пассажирский' }
    puts "Информация о поезде (#{train.number}:)"
    puts "* тип - #{typeTrain[train.type]}"
    puts "* текущая скорость - #{train.speed}"

    if train.route
      puts "* маршрут (#{train.route.number}), со станциями: #{verify(:@name, train.route.stations)}"
    else
      puts "* маршрут - не присвоен поезду"
    end

    puts "* текущая станция - #{train.current_station.name}" if train.current_station
    puts "* следующая станция - #{train.next_station.name}" if train.next_station
    puts "* предыдущая станция - #{train.previous_station.name}" if train.previous_station

    if train.wagons.length > 0
      puts "* вагоны в количестве (#{train.wagons.length}): #{verify(:@number, train.wagons)}"
    else
      puts "* вагоны - отсутствуют"
    end
  end
  
  # Информация о вагоне (вызов подменю)
  def show_wagons
    submenu_block(
      "Вагоны",
      "\nВведите (номер вагона) для получения информации",
    ) do |result|
      wagon = @wagons.detect { |wagon| wagon.number == result }      
      typeWagon = { cargo: 'грузовой', passenger: 'пассажирский' }

      if !wagon
        puts "Внимание!!! Введен несуществующий номер вагона. Повторите ввод!"
        next
      end

      puts "Информация о вагоне (#{wagon.number}):"
      puts "* тип - #{typeWagon[wagon.type]}"
      
      if wagon.train
        puts "* прицеплен к поезду - #{wagon.train.number}"
      else
        puts "* вагон свободен"
      end
    end
  end
 
  # Управление маршрутами (вызов подменю)
  def manage_routes
    submenu_block(
      "Маршруты",
      "\nВведите (маршрут) для изменения(или пункт меню): (first_station-last_station)",
    ) do |result|
      route = @routes.detect { |route| route.number == result }
      
      if !route
        puts "Внимание! Маршрут не существует. Повторите ввод!"
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
  
  # Управление поездами (вызов подменю)
  def manage_trains
    submenu_block(
      "Поезда",
      "\nВведите (номер поезда) для внесения изменений (или пункт меню)",
    ) do |result|
      train = @trains.detect { |train| train.number == result }
      
      if !train
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

  # Добавить вагоны к поезду
  def add_wagon_to_train(train)
    loop do     
      if train.wagons.length > 0
        puts "К поезду (#{train.number}) прицеплены вагоны: #{verify(:@number, train.wagons)}"
      else
        puts "У поезда (#{train.number}) нет прицепленных вагонов..."
      end

      free_wagons = @wagons.select { |wagon| !wagon.train }
      if free_wagons.length == 0
        puts "Свободные вагоны отсутствуют..."
        break
      end

      print "\nСвободные вагоны: #{verify(:@number, free_wagons)}"
      print "\nВведите (номер вагона), чтобы прицепить к поезду (#{train.number})"
      print "\n1 - Вернуться в меню: 'Управления Поездами'"
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
          wagon = free_wagons.detect { |wagon| wagon.number == choice }

          if wagon            
            begin
              train.add_wagon(wagon)
            rescue => e            
              typeWagon = { cargo: 'грузовой', passenger: 'пассажирский' }              
              case e.message
                when 'type_incorrected'
                  puts "Введен некорректный тип вагона (#{typeWagon[wagon.type]}). К поезду (#{train.number}) можно прицепить вагон с типом (#{typeWagon[train.type]})"
                when 'non_zero_speed'
                  puts "Невозможно прицепить вагон, поезд (#{train.number}) находится в движении, текущая скорость - #{train.speed}"
                else
                  raise
              end 
            else
              puts "Вагон (#{wagon.number}) прицеплен к поезду (#{train.number})"
            end            
          else
            puts "Внимание!!! Некорректный ввод. Пожалуйста, повторите!"
            next
          end           
      end 
    end 
  end 
  
  # Удалить вагоны
  def remove_wagon_from_train(train)
    loop do
      if train.wagons.length > 0
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
          wagon = free_wagons.detect { |wagon| wagon.number == choice }

          if wagon
            begin
              train.remove_wagon(wagon)
            rescue => e
              if (e.message == 'non_zero_speed')
                puts "Невозможно отцепить вагон! Поезд (#{train.number}) находится в движении, текущая скорость - #{train.speed}"
              end
            else
              puts "Вагон (#{wagon.number}) отцеплен от поезда (#{train.number})"
            end
          else
            puts "Внимание!!! Некорректный ввод. Пожалуйста, повторите!"
            next
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

      free_routes = @routes.select { |route| route != train.route }
      if free_routes.length == 0
        puts "Доступные маршруты отсутствуют: ... "
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
          route = free_routes.detect { |route| route.number == choice }
          if route
            train.add_route(route)
            puts "Маршрут (#{route.number}) со станциями: #{verify(:@name, route.stations)} -> присвоен поезду: #{train.number}"
          else
            puts "Внимание!!! Введен некорректный маршрут. Повторите ввод!"
            next
          end
      end
    end
  end
  
  # Привести поезд в движение
  def speed_up_train(train)
    if train.speed > 0
      puts "Поезд (#{train.number}) уже находится в движении. Текущая скорость - #{train.speed}"
    else
      train.speed_up
      puts "Поезд (#{train.number}) приведен в движение. Текущая скорость - #{train.speed}"
    end
  end
  
  # Остановить поезд
  def speed_down_train(train)
    if train.speed == 0
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
   
  # Добавить станцию в маршрут
  def add_station_to_route(route)
    loop do
      free_stations = @stations.select { |station| !(route.stations.include? station) }
      
      if free_stations.length == 0
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
          station = free_stations.detect { |station| station.name == choice }

          if station
            route.add_station(station)
            print "\nСтанция (#{station.name}) добавлена в маршрут: #{route.number}"
            print "\nМаршрут (#{route.number}), включает станции: #{verify(:@name, route.stations)}"
          else
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

      if stations.length == 0
        print "\nНет промежуточных станций к удалению из маршрута (#{route.number})"
        break
      end

      print "\nДоступные станции к удалению: #{verify(:@name, stations)} из маршрута (#{route.number})"
      print "\n\nВведите (название станции), которую нужно удалить из маршрута (#{route.number})"
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
          station = stations.detect { |station| station.name == choice }

          if station
            route.remove_station(station)
            puts "Станция (#{station.name}) удалена из маршрута (#{route.number})"
            puts "Маршрут (#{route.number}), включает станции: #{verify(:@name, route.stations)}"
          else
            puts "Внимание!!! Введено некорректное имя станции. Повторите ввод!"
            next
          end
      end
    end
  end

  # Меню блока
  def menu_block(block_name, actions)
    actions_new = {}
    print "\nУправление блоком #{block_name}: "   
    
    actions.each.with_index(1) do |(type, count), index|
      actions_new[index] = type  
      case type
        when :create
          print "\n #{index} - Создать"
        when :manage
          print "\n #{index} - Управлять"
        when :show
          print "\n #{index} - Получить информацию"
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
      "Станции" => {
        items: @stations,
        params: :@name, 
        block_menu: lambda { menu_stations }
      },
      "Маршруты" => {
        items: @routes,
        params: :@number, 
        block_menu: lambda { menu_routes }
      },
      "Вагоны" => {
        items: @wagons,
        params: :@id, 
        block_menu: lambda { menu_wagons }
      },
      "Поезда" => {
        items: @trains,
        params: :@number, 
        block_menu: lambda { menu_trains }
      },       
    }
    
    items = block_items [block_name][:items]
    params = block_items [block_name][:params]
    block_menu = block_items [block_name][:block_menu]   
 
    continue = nil
    loop do
      print action if action 
      print "\n 1 - Вернуться в меню блока #{block_name}"      
      print "\n 0 - Вернуться в главное меню"
      print "\n Выполните ввод: "       

      result = gets.chomp
      case result
        when '1'
          continue = block_menu
          break
        when '0'
          continue = lambda { menu_main }
          break
        else
          continue = block_menu
          yield(result) if block_given?
        end
    end

    puts "Внимание! #{block_name} не созданы" if items.length == 0
    continue.call        
  end  
  
  # Проверить элемент
  def verify(param, items)
    result = ""
    items.each { |item| result << "#{item.instance_variable_get(param)},"}
    result.rstrip.chop
  end  
end

menu = MenuMain.new
menu.menu_main
