class Task < Post

  def initialize
    super

    @due_data = Time.now
  end


  def read_from_console
  end

  def to_strings
  end
end