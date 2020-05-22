
array = []

3.times do
  print 'Введите коэффициент: '
  array << gets.to_f
end

a, b, c = array

puts "a = #{a}, b = #{b}, c = #{c}"

if a == 0
  print 'Переменная а не должна быть равна нулю, повторите ввод!'
  exit
end


d = b**2 - 4 * a * c

if d > 0
  square_root = Math.sqrt(d)
  x1 = (-b + square_root) / (2 * a)
  x2 = (-b - square_root) / (2 * a)
  puts "Дискриминант: #{d}. Корни: #{x1}, #{x2}"
elsif d == 0
  x = -b / (2 * a)
  puts "Дискриминант: #{d}. Корень: #{x}"
else
  puts 'Корней нет'
end