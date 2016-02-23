CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply INTEGER,
  user_id INTEGER NOT NULL,
  body VARCHAR(255),

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Kurt', 'Godel'),
  ('Luna', 'Blampo');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('Help!', 'I do not know what I am doing.', (SELECT id FROM users WHERE fname = 'Kurt')),
  ('Bacon', 'I can haz?', (SELECT id FROM users WHERE fname = 'Luna'));

INSERT INTO
  replies (question_id, parent_reply, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE questions.id = 2), NULL, 1, 'No bacon! Fish!!!!');
