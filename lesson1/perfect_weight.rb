print 'Введите Ваше имя: '
name = gets.chomp.capitalize

print "#{name}, введите Ваш рост: "
height = gets.to_i

perfect_weight = ((height - 110) * 1.15).round(2)

if perfect_weight > 0
  puts "#{name}, Ваш идеальный вес: #{perfect_weight} кг."  
else
  puts 'Ваш вес уже оптимальный'
end