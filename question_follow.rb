require 'byebug'

class QuestionFollow

  attr_accessor :question_id, :user_id, :id

  def self.followers_for_question_id(question_id)
    # debugger
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        user_id
      FROM
        users
      JOIN
        question_follows
        ON question_follows.user_id = users.id
      WHERE
        question_follows.question_id = (?)
    SQL

    results.map do |result|
      # debugger
      User.find_by_id(result.values)
    end
  end


  def self.followed_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        question_id
      FROM
        questions
      JOIN
        question_follows
        ON question_follows.question_id = questions.id
      WHERE
        question_follows.user_id = (?)
    SQL

    results.map do |result|
      # debugger
      Question.find_by_id(result.values)
    end
  end

  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        question_id
      FROM
        question_follows
      GROUP BY
        question_id
      ORDER BY
        COUNT(user_id) DESC
      LIMIT
        (?)
    SQL

    results.map { |result| Question.find_by_id(result.values) }
  end


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

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = (?)
    SQL
    return nil if result.empty?
    QuestionFollow.new(result.first)
  end



end
