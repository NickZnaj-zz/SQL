
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
    return nil if result.empty?
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
    return nil if result.empty?
    User.new(result.first)
  end

  def authored_questions
    Question.find_by_user_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

  def average_karma
    result = QuestionsDatabase.instance.execute(<<-SQL,  self.id)
      SELECT
        COALESCE(CAST(COUNT(DISTINCT(question_likes.user_id)) / COUNT(DISTINCT(question_likes.question_id)) AS FLOAT), 0)
      FROM
        questions
      LEFT OUTER JOIN
        question_likes
      ON
        questions.id = question_likes.question_id
      WHERE
        questions.user_id = (?)
    SQL

    result.first.values.first
  end

end
