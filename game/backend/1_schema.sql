CREATE TABLE mapa (
    idMapa SERIAL PRIMARY KEY,
    nomeM VARCHAR(50) NOT NULL --corrigir
);

CREATE TABLE regiao (
    idRegiao SERIAL PRIMARY KEY,
    idMapa INTEGER REFERENCES mapa(idMapa),
    nomeR VARCHAR(50) NOT NULL, --corrigir
    tempR REAL NOT NULL --corrigir
);

CREATE TABLE sala (
    idSala SERIAL PRIMARY KEY,
    idRegiao INTEGER REFERENCES regiao(idRegiao),
    nomeS VARCHAR(50) NOT NULL, --corrigir
    descricao TEXT DEFAULT '' --corrigir
);