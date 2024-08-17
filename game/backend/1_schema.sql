CREATE TABLE mapa (
    idMapa SERIAL PRIMARY KEY,
    nomeM VARCHAR(50) NOT NULL
);

CREATE TABLE regiao (
    idRegiao SERIAL PRIMARY KEY,
    idMapa INTEGER REFERENCES mapa(idMapa),
    nomeR VARCHAR(50) NOT NULL,
    tempR REAL NOT NULL
);

CREATE TABLE sala (
    idSala SERIAL PRIMARY KEY,
    idRegiao INTEGER REFERENCES regiao(idRegiao),
    nomeS VARCHAR(50) NOT NULL,
    descricao TEXT DEFAULT ''
);

CREATE TABLE personagem (
    idPersonagem SERIAL PRIMARY KEY,
    idSala INTEGER REFERENCES sala(idSala) DEFAULT 1,
    nomeP VARCHAR(50) NOT NULL,
    hpMax INTEGER DEFAULT 100,
    hpAtual INTEGER DEFAULT 100,
    descricao TEXT DEFAULT ''
);

CREATE TABLE vitalidade(
    idVitalidade SERIAL PRIMARY KEY,
    idPersonagem INTEGER NOT NULL,
    nutricao INTEGER DEFAULT 100,
    hidratacao INTEGER DEFAULT 100,
    stamina INTEGER DEFAULT 100,
    calor INTEGER DEFAULT 50,
    dano INTEGER DEFAULT 0,
    FOREIGN KEY (idPersonagem) REFERENCES personagem(idPersonagem)
    ON DELETE CASCADE
);

CREATE TABLE distrito (
    idDistrito SERIAL PRIMARY KEY,
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
    descricao TEXT DEFAULT '',
    FOREIGN KEY (idPersonagem) REFERENCES personagem(idPersonagem)
    ON DELETE CASCADE
);

CREATE TABLE inventario (
    idInventario SERIAL PRIMARY KEY,
    idPersonagem INTEGER NOT NULL,
    capMax INTEGER DEFAULT 2,
    capAtual INTEGER DEFAULT 0,
    FOREIGN KEY (idPersonagem) REFERENCES personagem(idPersonagem)
    ON DELETE CASCADE
);

CREATE TABLE personagem_jogavel (
    idPersonagem INTEGER PRIMARY KEY,
    idDistrito INTEGER REFERENCES distrito(idDistrito)
);

CREATE TABLE animal (
    idAnimal SERIAL PRIMARY KEY,
    idPersonagem INTEGER NOT NULL,
    FOREIGN KEY (idPersonagem) REFERENCES personagem(idPersonagem)
    ON DELETE CASCADE
);

CREATE TABLE bestante (
    idBestante SERIAL PRIMARY KEY,
    idPersonagem INTEGER NOT NULL,
    agilidade INTEGER,
    nado INTEGER,
    voo INTEGER,
    FOREIGN KEY (idPersonagem) REFERENCES personagem(idPersonagem)
    ON DELETE CASCADE
);

CREATE TABLE tributo (
    idTributo SERIAL PRIMARY KEY,
    idPersonagem INTEGER NOT NULL,
    statusT BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (idPersonagem) REFERENCES personagem(idPersonagem)
    ON DELETE CASCADE
);

CREATE TABLE item (
    idItem SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE vestimenta (
    idVestimenta SERIAL PRIMARY KEY,
    idItem INTEGER NOT NULL,
    descricao TEXT DEFAULT '',
    adCalor INTEGER NOT NULL,
    FOREIGN KEY (idItem) REFERENCES item(idItem) ON DELETE CASCADE
);

CREATE TABLE arma (
    idArma SERIAL PRIMARY KEY,
    idItem INTEGER NOT NULL,
    descricao TEXT DEFAULT '',
    adDano INTEGER NOT NULL,
    FOREIGN KEY (idItem) REFERENCES item(idItem) ON DELETE CASCADE
);

CREATE TABLE consumivel (
    idConsumivel SERIAL PRIMARY KEY,
    idItem INTEGER NOT NULL,
    descricao TEXT DEFAULT '',
    adHid INTEGER,
    adNut INTEGER,
    adSta INTEGER,
    adHp INTEGER,
    adCalor INTEGER,
    FOREIGN KEY (idItem) REFERENCES item(idItem) ON DELETE CASCADE
);

CREATE TABLE legivel (
    idLegivel SERIAL PRIMARY KEY,
    idItem INTEGER NOT NULL,
    conteudo TEXT DEFAULT '',
    FOREIGN KEY (idItem) REFERENCES item(idItem) ON DELETE CASCADE
);

CREATE TABLE compartimento (
    idCompartimento SERIAL PRIMARY KEY,
    idItem INTEGER NOT NULL,
    descricao TEXT DEFAULT '',
    adCapMax INTEGER NOT NULL,
    FOREIGN KEY (idItem) REFERENCES item(idItem) ON DELETE CASCADE
);

CREATE TABLE utilidade (
    idUtilidade SERIAL PRIMARY KEY,
    idItem INTEGER NOT NULL,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT DEFAULT '',
    geraItem BOOLEAN DEFAULT FALSE,
    capturaInimigo BOOLEAN DEFAULT FALSE,
    geraCalor BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (idItem) REFERENCES item(idItem) ON DELETE CASCADE
);

CREATE TABLE construtor (
    idConstrutor SERIAL PRIMARY KEY,
    idItem INTEGER NOT NULL,
    descricao TEXT DEFAULT '',
    FOREIGN KEY (idItem) REFERENCES item(idItem) ON DELETE CASCADE
);

--tabela do companheiro
--tabelas sobre a história
