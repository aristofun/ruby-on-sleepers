# encoding: utf-8
#
# (c) goodprogrammer.ru
#
# Пример примитивной реализации веб-фреймворка "Руби на Шпалах"
#
# Примитивная модель - тупой сохранятель содержимого в памяти по ID
class Quote
  # какие у этой модели есть поля
  attr_accessor :id
  attr_accessor :text
  attr_accessor :created_at

  # хранилище всех объектов в памяти руби процесса
  # примитивный аналог in memory DB
  # ключ - id, значение - экземпляр объекта (модель)
  @@all_models = {}

  # Сохраняет новую модель, назначает ей уникальный id
  def self.create(text)
    model = Quote.new
    model.text = text
    model.created_at = Time.now
    model.save
  end

  # метод экземпляра, сохраняет данный экземпляр модели с уникальным id
  def save
    self.id = @@all_models.keys.last.to_i + 1
    @@all_models[self.id] = self

    # возвращаем самого себя (модель)
    return self
  end

  # список моделей сейчас в памяти
  def self.all
    @@all_models.values
  end
end