# encoding: utf-8
#
# (c) goodprogrammer.ru
#
# Пример примитивной реализации веб-фреймворка "Руби на Шпалах"
#
# Базовый контроллер "Руби на шпалах" — функционал рендеринга шаблона
# и сохранения ответа
#
class BasicController
  attr_accessor :response
  attr_accessor :params
  attr_accessor :template_name

  # при создании динамически загружаем все шаблоны из папки ./views/*.rhtml
  # и все модели из папки ./models/*.rb
  def initialize
    @templates = {}
    # запоминаем все шаблоны в хеше (ключ - имя файла, значение - содержимое шаблона)
    Dir['./views/*.rhtml'].each do |file|
      @templates[File.basename(file, '.*')] = File.read(file)
    end
  end

  # Основной боевой метод любого контроллера
  # динамически вызывает экшен и сохраняет результат рендеринга шаблона
  def action(method_name, params)
    # сохраняем параметры в этом экземпляре
    self.params = params

    # по умолчанию имя шаблона равно имены экшена
    self.template_name = method_name

    # динамически вызываем экшен по имени методы в этом контроллере
    self.send(method_name)

    # рендерим шаблон и запоминаем в поле response
    self.response = render(template_name)
  end


  def render(template_name)
    template = @templates[template_name]
    return nil unless template

    # заменяем все @переменные в шаблоне на вызовы соотв. переменных из контроллера!
    result = template.gsub(/@\w+/) do |match|
      # если этот контроллер отзывается на переменную
      if self.instance_variable_defined?(match)
        # взять ее значение
        self.instance_variable_get(match)
      else
        # иначе - не трогать, оставить совпадение в шаблоне
        match
      end
    end

    return result
  end
end