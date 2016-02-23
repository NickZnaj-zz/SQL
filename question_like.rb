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
    return nil if result.empty?
    QuestionLike.new(result.first)
  end
end
