# encoding: utf-8
# 
# (c) goodprogrammer.ru
# 
# Пример примитивной реализации веб-фреймворка "Руби на Шпалах"
#
# require 'byebug'
require 'socket'
require 'cgi'
require_relative 'routes'

# создаем экземпляр TCP сервера слушающего порт 3000 на локальной машине - шпалу
server = TCPServer.new('localhost', 3000)
STDOUT.puts('Ruby on Sleepers web server listening on http://localhost:3000')

# Бесконечный цикл — каждая итерация прием нового TCP запроса и ответ на него
loop do
  # открываем сокет - наш сервер готов получать новый запрос
  socket = server.accept

  # 1. получаем запрос =========================================================

  # останавливаемся и слушаем сокет - пока кто-то (браузер) не пришлет в него новую строку-запрос
  request = socket.gets

  # Выводим в консоль содержимое запроса (логируем)
  # STDOUT.puts(request)
  # byebug
  
  # 2. разбираем запрос ========================================================
  http_type = request.split(' ')[0]
  http_url = request.split(' ')[1][1..-1]

  # выделяем из урла отдельно путь, отдельно параметры
  path = http_url.split('?')[0]
  params_string = http_url.split('?')[1]

  # логируем что разобрали из реквеста
  STDOUT.puts(http_type)
  STDOUT.puts(http_url)

  if params_string
    # превращаем строку типа key1=aaa&key2=bbb&key3=...
    # в хеш массив {'key1' => ['aaa'], 'key2' => ['bbb'] ...}
    params = CGI::parse(params_string)
    # убираем вложенные массивы в значениях хеша
    params.each { |k, v| params[k] = v[0] }

    # выводим в лог что получилось
    STDOUT.puts('Request params:')
    STDOUT.puts(params)
  end

  # 3. выбираем объект, реагирующий на этот запрос (контроллер) ================

  # все лежит в раутах в спец. хеш массиве
  controller_method = SHPALA_ROUTES["#{http_type}+#{path}"]

  # ищем в раутах путь
  if controller_method
    controller = controller_method.split('#')[0]
    method = controller_method.split('#')[1]

    STDOUT.puts("Controller: #{controller}##{method}")

    # 4. загружаем все контроллеры =============================================
    Dir['./controllers/*_controller.rb'].each do |file|
      require_relative file
    end

    # Динамически создаем экземпляр контроллера и вызываем нужный экшен
    begin
      controller_klass = Object::const_get(controller)
      ctrl = controller_klass.new
      ctrl.action(method, params)

      # сохраняем ответ контроллера
      response = ctrl.response
    rescue Exception => e
      # для простоты любую ошибку воспринимаем как 500
      STDERR.puts(e)
      STDERR.puts(e.backtrace.join("\n"))
      response = '<h1>500 error</h1>'
    end
  else
    # или считаем ошибкой 404 если controller_method из раутов не найден
    response = '<h1>404 error</h1>'
  end

  # ФИНИШНАЯ ПРЯМАЯ - отдаем результаты обратно в сеть...
  #
  # 5. отдаем response его клиенту, итерация цикла закончена ===================

  # Пишем в сокет стандартный HTTP заголовок
  socket.print "HTTP/1.1 200 OK\r\n" +
                 "Content-Type: text/html\r\n" +
                 "Content-Length: #{response.bytesize}\r\n" +
                 "Connection: close\r\n"
  socket.print "\r\n"

  # Пишем в сокет тело ответа
  socket.print response
  # Закрываем соединение
  socket.close
end