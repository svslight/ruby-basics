print 'Введите число: '
day = gets.to_i
print 'Введите номер месяца: '
month = gets.to_i
print 'Введите год: '
year = gets.to_i

if year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)
  days_in_february = 29
else
  days_in_february = 28
end

days_in_month = [31, days_in_february, 30, 31, 30, 31, 30, 31, 30, 31, 30]

num_day_in_year = days_in_month.first(month - 1).sum(day)
print "С начала #{year} года прошло #{num_day_in_year} дней"
