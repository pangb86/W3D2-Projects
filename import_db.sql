DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Bo', 'Pang'),
  ('Cynthia', 'Ma'),
  ('Andres', 'Don''t know');

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

INSERT INTO
  questions (title, body, author_id)
SELECT
  'Bo SQL Question', 'Self Join WTH', users.id
FROM
  users
WHERE
  users.fname = 'Bo' AND users.lname = 'Pang';

INSERT INTO
  questions (title, body, author_id)
SELECT
  'Ma Question Today''s date?', 'I can''t read a calendar', users.id
FROM
  users
WHERE
  users.fname = "Cynthia" AND users.lname = "Ma";

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE users.fname = 'Andres' AND users.lname = 'Don''t know'),
  (SELECT id FROM questions WHERE title = 'Bo SQL Question')),

  ((SELECT id FROM users WHERE users.fname = 'Cynthia' AND users.lname ='Ma'),
  (SELECT id FROM questions WHERE title = 'Bo SQL Question')
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title IN ('Bo SQL Question')),
  NULL,
  (SELECT id FROM users WHERE users.fname = 'Andres'),
  'Some text goes here'
);


INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title IN ('Bo SQL Question')),
  (SELECT id FROM replies WHERE id = 1),
  (SELECT id FROM users WHERE users.fname = 'Cynthia'),
  'Some different text goes here for the reply'
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE users.fname = 'Cynthia'),
  (SELECT id FROM questions WHERE title = 'Bo SQL Question')),

  ((SELECT id FROM users WHERE users.fname = 'Bo'),
  (SELECT id FROM questions WHERE title = 'Ma Question Today''s date?')
);
