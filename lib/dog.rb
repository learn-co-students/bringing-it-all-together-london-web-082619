class Dog
attr_reader : id 
attr_accessor :name, :breed

#initializing attributes of dog and setitng id to nil.
def initialize(id = nil, name, breed)
    @id = id 
    @name = name
    @breed = breed 
    end


    #creating table for dog class
def create_table()
sql = << -SQL
CREATE TABLE IF NOT EXIST dogs(
    id INTEGER PRIMARY KEY, 
    name TEXT, 
    breed Breed
); 

    SQL
DB[:conn].execute(sql)

end

#destroy dog table. 
def self.drop_table()
    DB[:conn].execute("DROP TBALE IF EXISTS dogs;")
end

def self.find_by_name(name)
sql = <<- SQL 
SELECT * FROM dogs
WHERE name = ?
LIMIT 1 
SQL 
new_from_db(DB[:conn].execute(sq1, name)[0])

end

def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save()
    new_dog
end

def self.find_by_id(id)
    sql = 'SELECT' * FROM dogs WHERE id = ?
    new_from_db(DB[:conn].execute(sql, id)[0])
end

end