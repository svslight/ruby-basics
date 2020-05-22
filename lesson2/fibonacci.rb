fibonacci = [0, 1]

loop do
  next_num = fibonacci[-1] + fibonacci[-2]
  break if next_num > 100
  fibonacci << next_num
end

print fibonacci
