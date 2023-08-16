PRAGMA foreign_keys = ON;
DROP TABLE question_likes;
DROP TABLE replies;
DROP TABLE question_follows;
DROP TABLE questions;
DROP TABLE users;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL

);

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
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
    body TEXT NOT NULL,
    question_id INTEGER NOT NULL,
    parent_id INTEGER,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (parent_id) REFERENCES replies(id),
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
    users(fname, lname)
VALUES
    ('Eric', 'Mai'),
    ('Julia', 'Kahn'),
    ('David', 'Pollack');

INSERT INTO
    questions(title, body, user_id)
VALUES
    ('HALP', 'How to SQL', (SELECT id FROM users WHERE fname = 'Eric' AND lname = 'Mai')),
    ('I am hungry', 'Can we extend lunch', (SELECT id FROM users WHERE fname = 'Julia' AND lname = 'Kahn')),
    ('Eat speed', 'Looking for tips', (SELECT id FROM users WHERE fname = 'David' AND lname = 'Pollack'));

INSERT INTO
    replies(body, question_id, parent_id, user_id)
VALUES
    ('Use a spoon',
        (SELECT id
        FROM questions
        WHERE id = 3),
        NULL,
        (SELECT id
        FROM users
        WHERE id = 1)),
    ('Use your hands',
        (SELECT id
        FROM questions
        WHERE id = 3),
        (SELECT id
        FROM replies
        WHERE id = 1),
        (SELECT id
        FROM users
        WHERE id = 2)),
    ('No',
        (SELECT id
        FROM questions
        WHERE id = 2),
        NULL,
        (SELECT id
        FROM users
        WHERE id = 3));

INSERT INTO
    question_likes(question_id, user_id)
VALUES
    ((SELECT id FROM questions WHERE id = 2),
        (SELECT id FROM users WHERE id = 1)),
    ((SELECT id FROM questions WHERE id = 2),
        (SELECT id FROM users WHERE id = 3));

INSERT INTO
    question_follows(question_id, user_id)
VALUES
    ((SELECT id FROM questions WHERE id = 1) , (SELECT id FROM users WHERE id = 2)),
    ((SELECT id FROM questions WHERE id = 1) , (SELECT id FROM users WHERE id = 3)),
    ((SELECT id FROM questions WHERE id = 1) , (SELECT id FROM users WHERE id = 1)),
    ((SELECT id FROM questions WHERE id = 3) , (SELECT id FROM users WHERE id = 1)),
    ((SELECT id FROM questions WHERE id = 3) , (SELECT id FROM users WHERE id = 2)),
    ((SELECT id FROM questions WHERE id = 2) , (SELECT id FROM users WHERE id = 1));
