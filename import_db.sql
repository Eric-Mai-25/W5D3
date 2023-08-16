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
    SELECT *
    FROM users
    JOIN questions
    ON users(id) = questions(user_id)
)

CREATE TABLE replies (
    id INTEGER  PRIMARY KEY,
    reply TEXT NOT NULL,
    question_id INTEGER NOT NULL,
    parent_id INTEGER NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (parent_id) REFERENCES replies(id)

)