# пути нашего веб-приложения
# Ключи — HTTP VERB + HTTP URL
# Значения - имя класса контроллера и его метода
SHPALA_ROUTES = {
  'GET+' => 'HelloController#index',
  'GET+index' => 'HelloController#index',
  'GET+save' => 'HelloController#save'
}