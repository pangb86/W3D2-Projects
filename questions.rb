require 'sqlite3'
require 'singleton'


class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class User
  attr_accessor :fname, :lname

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if data.empty?

    User.new(data.first)
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil if data.empty?

    User.new(data.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

#   User#followed_questions
# One-liner calling QuestionFollow method.

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

end

class Question
  attr_accessor :title, :body, :author_id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil if data.empty?

    Question.new(data.first)
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    return nil if data.empty?

    data.map {|datum| Question.new(datum)}
  end

  def self.most_followed
    QuestionFollow.most_followed_questions(1)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, @author_id)
      SELECT
        fname, lname
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if data.empty?

    User.new(data.first)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

end

class QuestionFollow
  attr_accessor :user_id, :question_id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      question_follows
    WHERE
      id = ?
    SQL
    return nil if data.empty?
    QuestionFollow.new(data.first)
  end

  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.fname, users.lname
    FROM
      question_follows
    JOIN users
    ON question_follows.user_id = users.id
    WHERE
      question_id = ?
    SQL
    return nil if data.empty?
    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.title, questions.body, questions.author_id
    FROM
      question_follows
    JOIN questions
    ON question_follows.question_id = questions.id
    WHERE
      question_follows.user_id = ?
    SQL
    return nil if data.empty?
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      questions.title, questions.body, questions.author_id
    FROM
      question_follows
    JOIN questions
    ON question_follows.question_id = questions.id
    GROUP BY question_follows.question_id
    ORDER BY COUNT(*) DESC
    LIMIT ?
    SQL
    return nil if data.empty?
    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  # QuestionFollow::most_followed_questions(n)
  # Fetches the n most followed questions.


end

class Reply
  attr_accessor :question_id, :parent_id, :user_id, :body

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
    SQL
    return nil if data.empty?
    Reply.new(data.first)
  end

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      replies
    WHERE
      user_id = ?
    SQL
    return nil if data.empty?
    data.map {|datum| Reply.new(datum)}
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      replies
    WHERE
      question_id = ?
    SQL
    return nil if data.empty?
    data.map {|datum| Reply.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @body = options['body']
  end



  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
      SELECT
        fname, lname
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if data.empty?
    User.new(data.first)
  end

  def question
    data = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil if data.empty?
    Question.new(data.first)
  end

  def parent_reply
    data = QuestionsDatabase.instance.execute(<<-SQL, @parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if data.empty?
    Reply.new(data.first)
  end

  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    return nil if data.empty?
    data.map { |datum| Reply.new(datum) }
  end
end

class QuestionLike
  attr_accessor :user_id, :question_id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      question_likes
    WHERE
      id = ?
    SQL
    return nil if data.empty?
    QuestionLike.new(data.first)
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
