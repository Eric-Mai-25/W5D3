require 'sqlite3'
require 'singleton'

class QuestionDatabase < SQLite3::Database
    include Singleton
    def initialize 
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end

end

class Users
    def self.all
        data = QuestionDatabase.instance.execute("SELECT * FROM users")
        data.map { |datum| Users.new(datum)}
    end

    def self.find_by_name(first, last)
        data = QuestionDatabase.instance.execute("SELECT * FROM users WHERE fname = '#{first}' AND lname = '#{last}' ")
        data.map { |datum| Users.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    

end