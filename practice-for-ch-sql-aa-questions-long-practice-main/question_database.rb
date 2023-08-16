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

    attr_accessor :fname, :lname

    def self.find_by_name(first, last)
        data = QuestionDatabase.instance.execute(<<-SQL, first, last)
            SELECT *
            FROM users
            WHERE fname = ? AND lname = ?
        SQL
        data.map { |datum| Users.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end
end

class Questions
    def self.all
        data = QuestionDatabase.instance.execute("SELECT * FROM questions")
        data.map { |datum| Questions.new(datum)}
    end

    attr_accessor :title, :body, :user_id

    def self.find_by_id(id)
        data = QuestionDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM questions
            WHERE id = ?
        SQL
        data.map { |datum| Questions.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @body = options['body']
        @title = options['title']
        @user_id = options['user_id']
    end
end

class QuestionFollows
    def self.all
        data = QuestionDatabase.instance.execute("SELECT * FROM question_follows")
        data.map { |datum| QuestionFollows.new(datum)}
    end

    attr_accessor :question_id, :user_id

    def self.find_by_id(id)
        data = QuestionDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM questions_follows
            WHERE id = ?
        SQL
        data.map { |datum| QuestionFollows.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
end

class Replies
    def self.all
        data = QuestionDatabase.instance.execute("SELECT * FROM replies")
        data.map { |datum| Replies.new(datum)}
    end

    attr_accessor :body, :question_id, :parent_id, :user_id

    def self.find_by_id(id)
        data = QuestionDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM replies
            WHERE id = ?
        SQL
        data.map { |datum| Replies.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @body = options['body']
        @question_id = options['question_id']
        @parent_id = options['parent_id']
        @user_id = options['user_id']
    end
end

class QuestionLikes
    def self.all
        data = QuestionDatabase.instance.execute("SELECT * FROM question_likes")
        data.map { |datum| QuestionLikes.new(datum)}
    end

    attr_accessor :question_id, :user_id

    def self.find_by_id(id)
        data = QuestionDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM question_likes
            WHERE id = ?
        SQL
        data.map { |datum| QuestionLikes.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
end
