require 'rexml/document' # подключаем парсер
require 'date'

current_path = File.dirname(__FILE__)
file_name = current_path + '/my_expenses.xml'

abort 'Файл my_expenses.xml не найден!' unless File.exist?(file_name)

file = File.new(file_name)

# Создаем новый XML объект из файла file
begin
  doc = REXML::Document.new(file)
rescue REXML::ParseException => e
  puts 'XML файл поврежден!'
  abort e.message
end

# траты по дням
amount_by_day = {}

doc.elements.each('expenses/expense') do |item|
  loss_sum = item.attributes['amount'].to_i
  loss_date = Date.parse(item.attributes['date'])

  # иницилизируем нулем значение хэша, если этой даты еще не было
  amount_by_day[loss_date] ||= 0

  amount_by_day[loss_date] += loss_sum
end

file.close

# сумма расходов за каждый месяц
sum_by_month = {}

current_month = amount_by_day.keys.min.strftime('%B %Y')

amount_by_day.keys.sort.each do |key|
  sum_by_month[key.strftime('%B %Y')] ||= 0
  sum_by_month[key.strftime('%B %Y')] += amount_by_day[key]
end

puts "------[ #{current_month}, всего потрачено: #{sum_by_month[current_month]} р. ]--------"

# цикл по всем дням
amount_by_day.keys.sort.each do |key|
  # если текущий день принадлежит уже другому месяцу
  if key.strftime('%B %Y') != current_month
    # мы перешли на новый месяц и теперь он станет текущим
    current_month = key.strftime('%B %Y')
    # выводим заголовок для нового текущего месяца
    puts "------[ #{current_month}, всего потрачено: #{sum_by_month[current_month]} р. ]--------"
  end

  # выводим расходы за конкретный день
  puts "\t#{key.day}: #{amount_by_day[key]} р."
end
