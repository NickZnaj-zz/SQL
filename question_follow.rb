class QuestionFollow

  attr_accessor :question_id, :user_id, :id

  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        user_id
      FROM
        users
      JOIN
        question_follows
        ON question_follows.user_id = user.id
      WHERE
        question_follows.question_id = (?)
    SQL

    results.map { |result| User.find_by_id(result) }
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
