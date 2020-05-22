arr = []
index = 10

while index <= 100
  arr << index
  index += 5
end
print arr

# short version
# range = (10..100)
# print range.step(5).to_a
