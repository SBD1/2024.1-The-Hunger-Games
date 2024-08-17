CREATE TABLE mapa (
    idmapa SERIAL PRIMARY KEY,
    nomeM VARCHAR(50) NOT NULL
);

CREATE TABLE regiao (
    idRegiao SERIAL PRIMARY KEY,
    idmapa SERIAL REFERENCES mapa(idmapa),

);