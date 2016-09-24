# XXX/ Этот код необходим только при использовании русских букв на Windows
if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

# Подключаем класс Post и его детей
require_relative 'lib/post.rb'
require_relative 'lib/link.rb'
require_relative 'lib/task.rb'
require_relative 'lib/memo.rb'


puts "Привет я твой блокнот! "
puts "Что хотите записать в блокнот?"

# массив возможных видов Записи (поста)
choices = Post.post_types.keys
choice = -1

until choice >= 0 && choice < choices.size # пока юзер не выбрал правильно
  # выводим заново массив возможных типов поста
  choices.each_with_index do |type, index|
    puts "\t#{index}. #{type}"
  end
  choice = STDIN.gets.chomp.to_i
end
# создаем запись с помощью стат. метода класса Post
entry = Post.create(choices[choice])
# Просим пользователя ввести пост
entry.read_from_console
# Сохраняем пост в базу данных
rowid = entry.save_to_db
puts "Ура, запись сохранена в базе, id = #{rowid}"
