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

--corrigir
CREATE TABLE personagem (
    idPersonagem SERIAL PRIMARY KEY,
    idSala INTEGER REFERENCES sala(idSala) DEFAULT 1,
    nomeP VARCHAR(50) NOT NULL,
    nutricao INTEGER DEFAULT 100,
    hidratacao INTEGER DEFAULT 100,
    stamina INTEGER DEFAULT 100,
    calor INTEGER DEFAULT 50,
    hpMax INTEGER DEFAULT 100,
    hpAtual INTEGER DEFAULT 100,
    dano INTEGER DEFAULT 0
);

--corrigir
CREATE TABLE distrito (
    idDistrito SERIAL,
    idPersonagem INTEGER NOT NULL,
    agilidade INTEGER,
    forca INTEGER,
    nado INTEGER,
    carisma INTEGER,
    combate INTEGER,
    pespicacia INTEGER,
    furtividade INTEGER,
    sobrevivencia INTEGER,
    precisao INTEGER,
    PRIMARY KEY (idDistrito, idPersonagem),
    FOREIGN KEY (idPersonagem) REFERENCES personagem (idPersonagem)
    ON DELETE CASCADE
);