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
    hpMax INTEGER DEFAULT 100,
    hpAtual INTEGER DEFAULT 100
);

--adicionar
CREATE TABLE vitalidade(
    idVitalidade SERIAL,
    nutricao INTEGER DEFAULT 100,
    hidratacao INTEGER DEFAULT 100,
    stamina INTEGER DEFAULT 100,
    calor INTEGER DEFAULT 50,
    dano INTEGER DEFAULT 0,
    PRIMARY KEY (idVitalidade, idPersonagem),
    FOREIGN KEY (idPersonagem) REFERENCES personagem (idPersonagem)
    ON DELETE CASCADE
);

--corrigir
CREATE TABLE distrito (
    idDistrito SERIAL,
    idPersonagem INTEGER NOT NULL,
    popularidade INTEGER DEFAULT 0,
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

--corrigir
CREATE TABLE inventario (
    idInventario SERIAL PRIMARY KEY,
    idPersonagem INTEGER NOT NULL,
    capMax INTEGER DEFAULT 2,
    capAtual INTEGER DEFAULT 0,
    FOREIGN KEY (idPersonagem) REFERENCES personagem (idPersonagem)
    ON DELETE CASCADE
);

--corrigir
CREATE TABLE personagem_jogavel (
    idPersonagem INTEGER PRIMARY KEY,
    idDistrito INTEGER REFERENCES distrito(idDistrito)
);

--corrigir
CREATE TABLE personagem_nao_jogavel (
    idPersonagem SERIAL PRIMARY KEY,
    nomeNPC VARCHAR(50) NOT NULL,
    descricao TEXT DEFAULT ''
);

--corrigir
CREATE TABLE animal (
    idAnimal SERIAL PRIMARY KEY,
    nomeA VARCHAR(50) NOT NULL,
    idPersonagem INTEGER UNIQUE REFERENCES personagem (idPersonagem)
)

