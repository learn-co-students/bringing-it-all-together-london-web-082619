require 'pry'
require_relative "../config/environment.rb"

class Dog

  attr_accessor :name, :breed, :id

  def initialize (id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end



  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed) #here we have to first write the keyword and then pass it the argument. So we write id: and pass it the id we grabbed from row[0] and so on.
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end


  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end
  # this method makes an SQL request by id, uses a bound parameter. Then it connects to the DB and executes the SQL string, passing in an argument of whatever id is passed to the method call. Then it iterates over the returned row (just one in this case since done by ID) and invokes the class method new_from_db to
  # transform the returned row back into a Ruby object. The new_from_db method we know expects to be passed a row, so we pass it the row we are iterating over. end.first just returns the first one returned.



  def self.find_or_create_by(name:, breed:)
    # this method takes two arguments, name and breed. It queries the database to see if the record exists. If it DOES return an array of data then it defines dog_data to be the first element of the array within an array that it returns (kinda a pecularity of the database return - array within an array)
    # then it creates a new dog instance, and for the initialize we are providing the keyword argument so that it knows what piece of data (taken from the array via indexing) goes with which attribute. 
    # if no data is returned from the query, then it will .create a new instance - a class method we earlier built - and again in the initialize we have to provide the keyword before the value we pass it so that it knows what data corresponds to which key. Then we return the dog object, whether it be a newly created one or taken from 
    # the database and reconstructed to a Ruby object
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end



  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end



  def self.drop_table
    sql = <<-SQL
        DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end



  def self.create(breed:, name:) #here we are telling .create what to expect to be passed. Since we are invoking keyword arguments, as used in the initialize (colon after each word), it doesn't need to be in the same order as either the initialize parameters or the code in the line below this one. 
    dog = Dog.new(name: name, breed: breed) #Dog.new looks towards initialize to see what it expects. It expects name and breed. We are pairing the value of 'name' to the keyword of 'name:'
    dog.save # calling the .save method on the new instance of dog
    dog # returning the newly created dog object.
  end



  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end



  def save 
    if self.id
        self.update
    else
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
    
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

end