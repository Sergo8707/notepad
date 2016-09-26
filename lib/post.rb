# Базовый класс "Запись"
# Задает основные методы и свойства, присущие всем разновидностям Записи
require 'sqlite3' #подключаем гем sqlite

class Post

  # статическое поле класса или class variable
  # аналогично статическим методам принадлежит всему классу в целом
  # и доступно незвисимо от созданных объектов
  @@SQLITE_DB_FILE = 'db/notepad.sqlite'

  # теперь нам нужно будет читать объекты из базы данных
  # поэтому удобнее всегда иметь под рукой связь между классом и его именем в виде строки
  def self.post_types
    {'Memo' => Memo, 'Task' => Task, 'Link' => Link}
  end

  # Параметром теперь является строковое имя нужного класса
  def self.create(type)
    return post_types[type].new
  end

  # Находит в базе запись по идентификатору или массив записей из базы данных, который можно например показать в виде таблицы на экране
  def self.find(limit, type, id)

    db = SQLite3::Database.open(@@SQLITE_DB_FILE) # открываем "соединение" к базе SQLite
    # 1. конкретная запись
    if !id.nil?
      db.results_as_hash = true # настройка соединения к базе, он результаты из базы преобразует в Руби хэши
      # выполняем наш запрос, он возвращает массив результатов, в нашем случае из одного элемента
      result = db.execute("SELECT * FROM posts WHERE rowid = ?", id)
      # получаем единственный результат (если вернулся массив)
      result = result[0] if result.is_a? Array
      db.close

      if result.empty?
        puts "Такой id  #{id} не найден в базе :("
        return nil
      else
        # создаем с помощью нашего же метода create экземпляр поста,
        # тип поста мы взяли из массива результатов [:type]
        # номер этого типа в нашем массиве post_type нашли с помощью метода Array#find_index
        post = create(result['type'])
        #   заполним этот пост содержимым
        post.load_data(result)

        return post
      end
      #   эта ветвь выполняется если не передан идентификатор
    else
      # 2. вернуть таблицу записей
      db.results_as_hash = false # настройка соединения к базе, он результаты из базы НЕ преобразует в Руби хэши
      #Формируем запрос в базу с нужными условиями
      query = "SELECT rowid, * FROM posts "

      query += "WHERE type = :type " unless type.nil? # если задан тип, надо добавить условие
      query += "ORDER by rowid DESC " # сортировка - самые свежие в начале

      query += "LIMIT :limit " unless limit.nil?

      statement = db.prepare query

      statement.bind_param('type', type) unless type.nil?
      statement.bind_param('limit', limit) unless limit.nil?

      result = statement.execute! #(query) # выполняем

      statement.close
      db.close

      return result
    end
  end


  # конструктор
  def initialize
    @created_at = Time.now # дата создания записи
    @text = nil # массив строк записи — пока пустой
  end

  # Вызываться в программе когда нужно считать ввод пользователя и записать его в нужные поля объекта
  def read_from_console
    #   todo: должен реализовываться детьми, которые знают как именно считывать свои данные из консоли
  end

  # Возвращает состояние объекта в виде массива строк, готовых к записи в файл
  def to_strings
    #   todo: должен реализовываться детьми, которые знают как именно хранить себя в файле
  end

  # Записывает текущее состояние объекта в файл
  def save
    file = File.new(file_path, "w:UTF-8") # открываем файл на запись

    for item in to_strings do # идем по массиву строк, полученных из метода to_strings
      file.puts(item)
    end

    file.close # закрываем
  end

  # Метод, возвращающий путь к файлу, куда записывать этот объект

  def to_db_hash
    {
        # self — ключевое слово, указывает на 'этот объект',
        # то есть конкретный экземпляр класса, где выполняется в данный момент этот код
        'type' => self.class.name,
        'created_at' => @created_at.to_s
    }
  end

  def file_path
    # Сохраним в переменной current_path место, откуда запустили программу
    current_path = File.dirname(__FILE__)

    # Получим имя файла из даты создания поста метод strftime формирует строку типа "2014-12-27_12-08-31.txt"
    file_name = @created_at.strftime("#{self.class.name}_%Y-%m-%d_%H-%M-%S.txt")

    return current_path + "/" + file_name
  end

  def save_to_db
    db = SQLite3::Database.open(@@SQLITE_DB_FILE) #открыть базу SQLite
    db.results_as_hash = true

    db.execute(
        "INSERT INTO posts (" +
            to_db_hash.keys.join(', ') +
            ") " +
            " VALUES ( " +
            ('?,'*to_db_hash.keys.size).chomp(',') +
            ")",
        to_db_hash.values
    )

    insert_row_id = db.last_insert_row_id
    db.close

    return insert_row_id
  end


  # получает на вход хэш массив данных и должен заполнить свои поля
  def load_data(data_hash)
    @created_at = Time.parse(data_hash['created_at'])
    @text = data_hash['text']
  end
end


