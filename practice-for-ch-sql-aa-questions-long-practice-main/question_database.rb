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

class User
    def self.all
        data = QuestionDatabase.instance.execute("SELECT * FROM users")
        data.map { |datum| User.new(datum)}
    end

    attr_accessor :fname, :lname

    def self.find_by_name(first, last)
        data = QuestionDatabase.instance.execute(<<-SQL, first, last)
            SELECT *
            FROM users
            WHERE fname = ? AND lname = ?
        SQL
        data_array =data.map { |datum| User.new(datum)}
        raise "No user with this name" if data_array.empty?
        data_array
    end

    def authored_questions(user_id)
        Question.find_by_author_id(user_id)
    end

    def authored_replies(user_id)
        Reply.find_by_user_id(user_id)
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def followed_questions
        QuestionFollow.followed_questions_for_user_id(@id)
    end

    def liked_questions
        QuestionLike.liked_questions_for_user_id(@id)
    end

    def average_karma
        data = QuestionDatabase.instance.execute(<<-SQL, @id)
           SELECT *
           FROM questions
           LEFT JOIN question_likes ON questions.id = question_likes.question_id
           WHERE questions.user_id = ?

        SQL
        data.map { |datum| User.new(datum) }
    end
end

class Question
    def self.all
        data = QuestionDatabase.instance.execute("SELECT * FROM questions")
        data.map { |datum| Question.new(datum)}
    end

    attr_accessor :title, :body, :user_id

    def self.find_by_id(id)
        data = QuestionDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM questions
            WHERE id = ?
        SQL
        data_array = data.map { |datum| Question.new(datum)}
        raise "No questions with this id" if data_array.empty?
        data_array
    end

    def self.find_by_author_id(author_id)
        data = QuestionDatabase.instance.execute(<<-SQL, author_id)
        SELECT *
        FROM questions
        WHERE user_id = ?
        SQL
        data_array = data.map { |datum| Question.new(datum)}
        raise "No questions by author" if data_array.empty?
        data_array
    end

    def self.most_liked(n)
        QuestionLike.most_liked_questions(n)
    end

    def initialize(options)
        @id = options['id']
        @body = options['body']
        @title = options['title']
        @user_id = options['user_id']
    end

    def author
        data = QuestionDatabase.instance.execute(<<-SQL, @user_id)
            SELECT *
            FROM users
            WHERE id = ?
        SQL

        data.map { |datum| User.new(datum) }
    end

    def replies
        data = QuestionDatabase.instance.execute(<<-SQL, @id)
            SELECT *
            FROM replies
            WHERE question_id = ?
        SQL

        data.map { |datum| Reply.new(datum) }
    end

    def followers
        QuestionFollow.followers_for_question_id(@id)
    end

    def likers
        QuestionLike.likers_for_question_id(@id)
    end

    def num_likes
        QuestionLike.num_likes_for_question_id(@id)
    end
end

class QuestionFollow
    def self.all
        data = QuestionDatabase.instance.execute("SELECT * FROM question_follows")
        data.map { |datum| QuestionFollow.new(datum)}
    end

    attr_accessor :question_id, :user_id

    def self.find_by_id(id)
        data = QuestionDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM questions_follows
            WHERE id = ?
        SQL
        data.map { |datum| QuestionFollow.new(datum)}
    end

    def self.followers_for_question_id(question_id)
        data = QuestionDatabase.instance.execute(<<-SQL, question_id)
            SELECT *
            FROM question_follows
            JOIN users
            ON question_follows.user_id = users.id
            WHERE question_follows.question_id = ?
        SQL
        data.map { |datum| User.new(datum)}
    end

    def self.followed_questions_for_user_id(user_id)
        data = QuestionDatabase.instance.execute(<<-SQL, user_id)
            SELECT *
            FROM question_follows
            JOIN questions
            ON question_follows.question_id = questions.id
            WHERE question_follows.user_id = ?
        SQL
        data.map { |datum| Question.new(datum)}
    end

    def self.most_followed_question(n)
        data = QuestionDatabase.instance.execute(<<-SQL, n)
            SELECT *, COUNT(question_follows.question_id) AS followers
            FROM question_follows
            JOIN questions
            ON question_follows.question_id = questions.id
            GROUP BY question_follows.question_id
            ORDER BY followers DESC
            LIMIT ?
        SQL

        data.map { |datum| Question.new(datum)}
    end

    def self.most_followed
        QuestionFollow.most_followed_question(1)
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
end


class Reply
    def self.all
        data = QuestionDatabase.instance.execute("SELECT * FROM replies")
        data.map { |datum| Reply.new(datum)}
    end

    attr_accessor :body, :question_id, :parent_id, :user_id

    def self.find_by_id(id)
        data = QuestionDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM replies
            WHERE id = ?
        SQL
        data_array =data.map { |datum| Reply.new(datum)}
        raise "No replies with id" if data_array.empty?
        data_array
    end

    def self.find_by_user_id(user_id)
        data = QuestionDatabase.instance.execute(<<-SQL, user_id)
            SELECT *
            FROM replies
            WHERE user_id = ?
        SQL
        data_array =data.map { |datum| Reply.new(datum)}
        raise "No replies from user" if data_array.empty?
        data_array

    end

    def self.find_by_question_id(question_id)
        data = QuestionDatabase.instance.execute(<<-SQL, question_id)
            SELECT *
            FROM replies
            WHERE question_id = ?
        SQL
        data_array =data.map { |datum| Reply.new(datum)}
        raise "This question has no replies" if data_array.empty?
        data_array

    end

    def initialize(options)
        @id = options['id']
        @body = options['body']
        @question_id = options['question_id']
        @parent_id = options['parent_id']
        @user_id = options['user_id']
    end

    def author
        data = QuestionDatabase.instance.execute(<<-SQL, @user_id)
            SELECT *
            FROM users
            WHERE id = ?
        SQL

        data.map { |datum| User.new(datum) }
    end

    def question
        data = QuestionDatabase.instance.execute(<<-SQL, @question_id)
            SELECT *
            FROM questions
            WHERE id = ?
        SQL

        data.map { |datum| Question.new(datum) }
    end

    def parent_reply
        data = QuestionDatabase.instance.execute(<<-SQL, @parent_id)
            SELECT *
            FROM replies
            WHERE id = ?
        SQL

        data_arr = data.map { |datum| Reply.new(datum) }
        raise "This reply is the first one." if data_arr.empty?
    end

    def child_replies
        data = QuestionDatabase.instance.execute(<<-SQL, @id)
            SELECT *
            FROM replies
            WHERE parent_id = ?
        SQL

        data_arr = data.map { |datum| Reply.new(datum) }
        raise "This reply has no replies." if data_arr.empty?
    end
end

class QuestionLike
    def self.all
        data = QuestionDatabase.instance.execute("SELECT * FROM question_likes")
        data.map { |datum| QuestionLike.new(datum)}
    end

    attr_accessor :question_id, :user_id

    def self.find_by_id(id)
        data = QuestionDatabase.instance.execute(<<-SQL, id)
            SELECT *
            FROM question_likes
            WHERE id = ?
        SQL
        data.map { |datum| QuestionLike.new(datum)}
    end

    def self.likers_for_question_id(question_id)
        data = QuestionDatabase.instance.execute(<<-SQL, question_id)
            SELECT *
            FROM question_likes
            JOIN users
            ON question_likes.user_id = users.id
            WHERE question_id = ?
        SQL
        data.map { |datum| User.new(datum)}
    end

    def self.num_likes_for_question_id(question_id)
        data = QuestionDatabase.instance.execute(<<-SQL, question_id)
            SELECT COUNT(user_id) as likes
            FROM question_likes
            WHERE question_id = ?
        SQL
        data
    end

    def self.most_liked_questions(n)
        data = QuestionDatabase.instance.execute(<<-SQL, n)
            SELECT *, COUNT(*) AS num_likes
            FROM question_likes
            JOIN questions
            ON question_likes.question_id = questions.id
            GROUP BY question_likes.question_id
            ORDER BY num_likes DESC
            LIMIT ?
        SQL

        data.map { |datum| Question.new(datum)}
    end

    def self.liked_questions_for_user_id(user_id)
        data = QuestionDatabase.instance.execute(<<-SQL, user_id)
            SELECT *
            FROM question_likes
            JOIN questions
            ON question_likes.question_id = questions.id
            WHERE question_likes.user_id = ?
        SQL
        data.map { |datum| Question.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
end
