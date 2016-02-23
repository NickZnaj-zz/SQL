
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
    return nil if result.empty?
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
    return nil if result.empty?
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
    return nil if results.empty?
    results.map { |result| Question.new(result) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def author
    User.find_by_id(self.user_id)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end

  def likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end



end
