print 'Введите основание треугольника: '
area = gets.to_f

print 'Введите высоту треугольника: '
height = gets.to_f

triangle_area = (0.5 * area * height).round(3)

puts "Площадь треугольника #{triangle_area}"