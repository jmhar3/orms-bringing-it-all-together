class Dog
    attr_accessor :name, :breed, :id
    def initialize name:, breed:, id: nil
        @name = name
        @breed = breed
        @id = id
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
        DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
    end
    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, name, breed)
        DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end
    def self.create name:, breed:
        dog = Dog.new name: name, breed: breed
        dog.save
        dog
    end
    def self.new_from_db row
        Dog.new name: row[1], breed: row[2], id: row[0]
    end
    def self.find_by_id id
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql, id).map{|dog| new_from_db dog}.first
    end
    def self.find_or_create_by name:, breed:
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            AND breed = ?
        SQL
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new name: dog_data[1], breed: dog_data[2], id: dog_data[0]
        else
            dog = self.create name: name, breed: breed
        end
        dog
    end
    def self.find_by_name name
        sql = "SELECT * FROM dogs
            WHERE name = ?"
        DB[:conn].execute(sql, name).map{|dog| new_from_db dog}.first
    end
    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end