require 'singleton'
require 'sqlite3'


class QuestionsDatabase < SQLite3::Database

  include Singleton

  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end


class User
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM users')
    results.map { |result| User.new(result) }
  end

  attr_accessor :fname, :lname, :id

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create

    raise 'already saved!' unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id

  end

  def self.find_by_id(id)

    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = (?)
    SQL

    User.new(result.first)
  end


  def self.find_by_name(fname, lname)
    result = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = (?) AND lname = (?)
    SQL

    User.new(result.first)
  end
end


class Question
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM questions')
    results.map { |result| Question.new(result) }
  end

  attr_accessor :title, :body, :user_id, :id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def create

    raise 'already saved!' unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, title, body, user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id

  end

  def self.find_by_id(id)

    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = (?)
    SQL

    Question.new(result.first)
  end

  def self.find_by_title(title)
    result = QuestionsDatabase.instance.execute(<<-SQL, title)
      SELECT
        *
      FROM
        questions
      WHERE
        title = (?)
    SQL

    Question.new(result.first)
  end

  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = (?)
    SQL

    results.map { |result| Question.new(result) }
  end
end

class QuestionFollow

  attr_accessor :question_id, :user_id, :id

  def initialize(options = {})
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def create

    raise 'already saved!' unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, question_id, user_id)
      INSERT INTO
        question_follows (question_id, user_id)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id

  end

  def self.find_by_id
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = (?)
    SQL

    QuestionFollow.new(result.first)
  end
end

class Reply
  attr_accessor :question_id, :parent_reply, :user_id, :body, :id

  def initialize(options = {})
    @question_id = options['question_id']
    @parent_reply = options['parent_reply']
    @user_id = options['user_id']
    @body = options['body']
    @id = options['id']
  end

  def create

    raise 'already saved!' unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, question_id, parent_reply, user_id, body)
      INSERT INTO
        replies (question_id, parent_reply, user_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id

  end

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = (?)
    SQL

    Reply.new(result.first)
  end

  def self.find_by_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = (?)
    SQL

    Reply.new(result.first)
  end


end


class QuestionLike
  attr_accessor :user_id, :question_id, :id

  def initialize(options={})
    @question_id = options['question_id']
    @user_id = options['user_id']
    @id = options['id']
  end

  def create

    raise 'already saved!' unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, question_id, user_id)
      INSERT INTO
        replies (question_id, user_id)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id

  end


  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = (?)
    SQL

    QuestionLike.new(result.first)
  end
end
