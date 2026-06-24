CREATE TABLE users (
    id              UUID PRIMARY KEY,
    name            VARCHAR (120)    NOT NULL,
    email           VARCHAR (180)    NOT NULL,
    cpf             VARCHAR (11)     NOT NULL,
    password_hash   VARCHAR (255)    NOT NULL,
    created_at      TIMESTAMP        NOT NULL
);

