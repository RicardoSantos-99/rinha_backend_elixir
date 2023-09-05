CREATE TABLE users (
    id          UUID,
    nome        VARCHAR(255) NOT NULL,
    apelido     VARCHAR(255) NOT NULL,
    nascimento  DATE,
    stack       TEXT
);
ALTER TABLE users OWNER TO postgres;

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX users_trgm ON users USING GIST ((apelido || ' ' || nome || ' ' || stack) gist_trgm_ops);