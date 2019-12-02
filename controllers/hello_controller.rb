# encoding: utf-8
#
# (c) goodprogrammer.ru
#
# Пример примитивной реализации веб-фреймворка "Руби на Шпалах"
#
require_relative '../models/quote'
require_relative 'basic_controller'

# Пример простого контроллера
class HelloController < BasicController
  # см. routes.rb - на какой путь вызывается этот метод
  def index
    @welcome_title = "Привет, дорогой друг. Сейчас на часах: #{Time.now}"
    last_quote = Quote.all.last

    if last_quote.nil?
      @last_quote = 'Ваша цитата может стать первой!'
    else
      @last_quote = last_quote.text
    end

    @total_quotes = Quote.all.size
  end

  # см. routes.rb - на какой путь вызывается этот метод
  def save
    quote = Quote.create(params['message'])
    @quote = quote.text
    @time = quote.created_at
  end
end
