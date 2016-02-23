require 'byebug'

class Reply
  attr_accessor :question_id, :parent_reply, :user_id, :body, :id

  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM replies')
    results.map { |result| Reply.new(result) }
  end

  def initialize(options = {})
    @question_id = options['question_id']
    @parent_reply = options['parent_reply']
    @user_id = options['user_id']
    @body = options['body']
    @id = options['id']
  end

  def ==(other_reply)
    self.id == other_reply.id
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
    return nil if result.empty?
    Reply.new(result.first)
  end

  def self.find_by_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = (?)
    SQL
    return nil if result.empty?
    Reply.new(result.first)
  end

  def self.find_by_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = (?)
    SQL
    return nil if result.empty?
    Reply.new(result.first)
  end

  def author
    User.find_by_id(self.user_id)
  end

  def question
    Question.find_by_id(self.question_id)
  end

  def find_parent_reply
    return nil if @parent_reply.nil?
    Reply.find_by_id(@parent_reply)
  end

  def child_replies
    # debugger
    Reply.all.select { |result| result.find_parent_reply == self }
  end



















end
