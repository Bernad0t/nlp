#!/usr/bin/env ruby
# encoding: utf-8

require 'set'

# Функция для нормализации номера
def normalize_number(raw)
  # Удаляем все нецифровые символы
  digits = raw.gsub(/[^\d]/, '')
  
  # Проверяем длину и формат
  case digits.length
  when 11
    # Российские номера: 8 или 7 в начале
    if digits[0] == '8' || digits[0] == '7'
      return "+7 #{digits[1..3]} #{digits[4..6]} #{digits[7..8]} #{digits[9..10]}"
    end
  
  nil
end

PHONE_REGEX = /(?:\+7|8|7|\+3)?[-\s]?\(?\d{3}\)?[-\s]?\d{3}[-\s]?\d{2}[-\s]?\d{2}/

# Функция для извлечения номеров из текста
def extract_numbers(text)
  # Ищем все совпадения
  matches = text.scan(PHONE_REGEX)
  matches.flatten
end

# Основная функция обработки файла
def process_file(path)
  begin
    content = File.read(path, encoding: 'utf-8')
    
    puts "=" * 50
    puts "📱 ВАЛИДАЦИЯ ТЕЛЕФОННЫХ НОМЕРОВ"
    puts "=" * 50
    puts "📂 Файл: #{path}"
    puts "-" * 50
    
    raw_numbers = extract_numbers(content)
    
    puts "Найдено совпадений: #{raw_numbers.length}"
    puts "Совпадения: #{raw_numbers.join(', ')}" unless raw_numbers.empty?
    
    valid_numbers = raw_numbers.map { |num| normalize_number(num) }.compact
    unique_numbers = Set.new(valid_numbers)
    
    puts "-" * 50
    puts "Валидных номеров: #{valid_numbers.length}"
    puts "Уникальных номеров: #{unique_numbers.length}"
    puts "-" * 50
    
    if unique_numbers.any?
      puts "📞 УНИКАЛЬНЫЕ НОМЕРА:"
      unique_numbers.each_with_index do |number, index|
        puts "#{index + 1}. #{number}"
      end
    else
      puts "❌ Валидных номеров не найдено"
    end
    
    puts "=" * 50
    
  rescue Errno::ENOENT
    puts "❌ Ошибка: файл '#{path}' не найден"
  rescue => e
    puts "❌ Произошла ошибка: #{e.message}"
    puts e.backtrace if ENV['DEBUG']
  end
end

# Точка входа
if __FILE__ == $PROGRAM_NAME
  input_file = ARGV[0] || 'input.txt'
  process_file(input_file)
end