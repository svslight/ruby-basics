cart = {}

loop do
  print 'Введите название товара или стоп: '
  name_product = gets.chomp.downcase
  break if name_product == 'стоп'

  print 'Введите цену за еденицу товара: '
  price = gets.chomp.to_f

  print 'Введите количество купленного товара: '
  count = gets.chomp.to_f

  cart[name_product] = { price: price, count: count, total: price * count }
end

puts "\nСписок покупок:"

cart.each do |name, purchase|
  puts "#{name}: #{purchase[:price]} руб x #{purchase[:count]} шт = #{purchase[:total]} руб"
end
  
purchase_total = cart.sum { |k, v| v[:total] }
puts "Итого сумма всех покупок: #{purchase_total} руб."