sides = []

3.times do
  print 'Введите сторону треугольника: '
  sides << gets.to_f
end

a, b, c = sides.sort
puts "#{sides}"

if sides.uniq.length == 1
  puts 'Треугольник является равносторонним'
elsif (a == b) || (a == c) || (b == c)
  puts 'Треугольник является равнобедренным'
elsif a**2 + b**2 == c**2
  puts 'Треугольник является прямоугольным'
else
  puts 'Треугольник разносторонний'
end