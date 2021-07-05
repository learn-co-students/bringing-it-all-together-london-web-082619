class Dog
  attr_accessor :name, :breed
  attr_reader :id

  ###### Instance methods ######

  def initialize(name: name, breed: breed, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      update
      self
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.breed)

      sql = "SELECT last_insert_rowid() FROM dogs LIMIT 1"
      @id = DB[:conn].execute(sql)[0][0]
      self
    end
  end


  ###### Class methods ######
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT);
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1;
    SQL

    dog = DB[:conn].execute(sql, name)[0]
    new_from_db(dog)
  end

  def self.create(name:, breed:)
    Dog.new(name: name, breed: breed).save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog = DB[:conn].execute(sql, id)[0]
    new_from_db(dog)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?;
    SQL
    dog = DB[:conn].execute(sql, name, breed)

    if dog[0]
      return new_from_db(dog[0])
    else
      return Dog.create(name: name, breed: breed)
    end
  end


end