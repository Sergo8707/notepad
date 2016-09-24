# Класс Ссылка, разновидность базового класса "Запись"
class Link < Post

  def initialize
    super # вызываем конструктор родителя
    # инициализируем специфичное для ссылки поле
    @url = ''
  end
  # Спрашиваем 2 строки - адрес ссылки и описание
  def read_from_console
    puts "Адрес ссылки:"
    @url = STDIN.gets.chomp
    # И описание ссылки
    puts "Что за ссылка?"
    @text = STDIN.gets.chomp
  end

  # Массив из трех строк: адрес ссылки, описание и дата создания
  def to_strings
    time_string = "Создано: #{@created_at.strftime("%Y.%m.%d, %H:%M:%S")} \n\r \n\r"

    return [@url, @text, time_string]
  end

  def to_db_hash
    # вызываем родительский метод ключевым словом super и к хэшу, который он вернул
    return super.merge(
        {
            'text' => @text,
            'url' => @url
        }
    )
  end

  # загружаем свои поля из хэш массива
  def load_data(data_hash)
    super(data_hash) #сперва дергаем родительский метод для общих полей

    # теперь прописываем свое специфичное поле
    @url = data_hash['url']
  end
end
