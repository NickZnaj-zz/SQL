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
        question_likes (question_id, user_id)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id

  end

  def self.likers_for_question_id(question_id)
    # debugger
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        user_id
      FROM
        users
      JOIN
        question_likes
        ON question_likes.user_id = users.id
      WHERE
        question_likes.question_id = (?)
    SQL

    results.map do |result|
      User.find_by_id(result.values)
    end
  end

  def self.liked_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        question_id
      FROM
        question_likes
      WHERE
        user_id = (?)
    SQL

    results.map do |result|
      Question.find_by_id(result.values)
    end
  end

  def self.num_likes_for_question_id(question_id)
    total = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(user_id)
      FROM
        question_likes
      WHERE
        question_id = (?)
    SQL

    total.first.values.first
  end

  def self.most_liked_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        question_id
      FROM
        question_likes
      GROUP BY
        question_id
      ORDER BY
        COUNT(user_id) DESC
      LIMIT
        (?)
    SQL

    results.map { |result| Question.find_by_id(result.values) }

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
    return nil if result.empty?
    QuestionLike.new(result.first)
  end
end
