vocals_hash = {}
count = 1

('a'..'z').each do |letter|
  vocals_hash[letter] = count if ['a','e','i','o','u'].include?(letter)
  count += 1
end

puts vocals_hash