CREATE TABLE users (
    id          UUID PRIMARY KEY,
    nome        VARCHAR(255) NOT NULL,
    apelido     VARCHAR(255) NOT NULL,
    nascimento  DATE,
    stack       VARCHAR(255)[]
);
ALTER TABLE users OWNER TO postgres;
CREATE UNIQUE INDEX users_nome_index ON users (nome);
