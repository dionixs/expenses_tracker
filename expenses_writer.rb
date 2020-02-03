require 'rexml/document' # подключаем парсер
require 'date'

current_path = File.dirname(__FILE__)
file_name = current_path + '/my_expenses.xml'

abort 'Файл my_expenses.xml не найден!' unless File.exist?(file_name)

file = File.new(file_name, 'r:UTF-8')

begin
  doc = REXML::Document.new(file)
rescue REXML::ParseException => e
  puts 'XML файл поврежден!'
  abort e.message
end

file.close

puts 'На что вы потратили деньги?'
expense_text = STDIN.gets.strip

puts 'Сколько вы потратили?'
expense_amount = STDIN.gets.to_i

puts 'Укажите дату траты в формате ДД.ММ.ГГГГ, например 12.05.2003 (пустое поле - сегодня)'
date_input = STDIN.gets.strip

expense_date = if date_input == ''
                 Date.today
               else
                 Date.parse(date_input)
               end

puts 'В какую категорию занести трату?'
expense_category = STDIN.gets.strip

expenses = doc.elements.find('expenses').first

expense = expenses.add_element 'expense',
                               'date' => expense_date.to_s,
                               'category' => expense_category,
                               'amount' => expense_amount

expense.text = expense_text

file = File.new(file_name, 'w:UTF-8')
doc.write(file, 2)
file.close

puts "\n\nЗапись успешно сохранена!"
