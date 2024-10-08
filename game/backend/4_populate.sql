-- Insere os mapas
INSERT INTO
    mapa(nomeM, descricao)
VALUES
    ('Centro de Treinamento', 'O Centro de Treinamento é um arranha-céu onde os tributos moram, treinam e se preparam para os Jogos Vorazes'),
    ('Arena', 'Aqui é onde os 24 tributos se enfrentarão até que reste apenas um vencedor');

-- Insere as regiões do mapa "Centro de Treinamento"
INSERT INTO
    regiao(idMapa, nomeR, tempR, descricao)
VALUES
    (1, 'Andar de Capacitação', 24, 'O Andar de Capacitação é o lugar onde os tributos podem treinar e ter aulas'),
    (1, 'Andar Moradia', 24, 'O Andar Moradia é onde os tributos e seus tutores comem e dormem'),
    (1, 'Andar Mídia', 24, 'O Andar Mídia é onde os tributos fazem as suas entrevistas para a TV');

-- Insere as salas do andar de capacitação
INSERT INTO
    sala(idRegiao, nomeS, descricao)
VALUES
    (1, 'Hall de Entrada', 'Aqui é onde você irá poder fazer aulas e praticar'),
    (1, 'Aula de Combate', 'Pratique combate corpo a corpo e aumente a sua pontuação de combate'),
    (1, 'Aula de Técnicas de Sobrevivência', 'Aprenda sobre componentes do mundo natural e aumente sua pontuação de sobrevivência'),
    (1, 'Aula de Mira', 'Pratique a sua mira e aumente a sua pontuação de precisão'),
    (1, 'Aula de Natação', 'Pratique natação e aumente a sua pontuação de nado'),
    (1, 'Aula de Camuflagem', 'Aprenda sobre camuflagem e aumente a sua pontuação de furtividade'),
    (1, 'Área de Socialização', 'Aproveite a Área de Socialização para tentar fazer aliados de outros distritos');

-- Insere as salas do andar moradia
INSERT INTO
    sala(idRegiao, nomeS, descricao)
VALUES
    (2, 'Sala de Jantar', 'Aqui é onde fará suas refeições, onde poderá pedir conselhos e conversar com seu colega de distrito'),
    (2, 'Dormitório', 'Aqui é onde você poderá recarregar suas energias para o próximo dia');

-- Insere as salas do andar mídia
INSERT INTO
    sala(idRegiao, nomeS, descricao)
VALUES
    (3, 'Sala de Entrevistas', 'É aqui onde você fará a sua entrevista que te apresentará para todo o povo de Panem.');

-- Insere um personagem jogável
BEGIN;
WITH personagem_inserido AS (
    INSERT INTO
        personagem (tipoP, nomeP, hpMax, hpAtual)
    VALUES ('Jogavel', 'Nome do Personagem', 150, 150) 
    RETURNING idPersonagem
)
INSERT INTO 
    personagem_jogavel (idPersonagem, idDistrito)
SELECT idPersonagem, 1 FROM personagem_inserido;

INSERT INTO vitalidade (idPersonagem)
SELECT idPersonagem FROM personagem_inserido;
COMMIT;

-- Insere os itens
INSERT INTO
    item (nome)
VALUES
    ('Uniforme'), ('Casaco'), ('Arco Artesanal'), ('Arco Profissional'), 
    ('Tridente'), ('Lança Profissional'), ('Lança Artesanal'), 
    ('Espada'), ('Faca'), ('Galho Seco'), ('Galho Longo'), 
    ('Flecha Artesanal'), ('Flecha Profissional'), ('Pedra'), 
    ('Pedra Lascada'), ('Corda'), ('Carne Crua'), ('Carne Assada'), 
    ('Sopa'), ('Amora'), ('Amora Cadeado'), ('Ração'), 
    ('Barra de Energia'), ('Água'), ('Armadilha Pequena'), 
    ('Armadilha Grande'), ('Fogueira Grande'), ('Fogueira Pequena'), 
    ('Bilhete'), ('Mochila Pequena'), ('Mochila Grande');

-- Insere vestimentas
INSERT INTO
    vestimenta(idVestimenta, descricao, adCalor)
VALUES 
    ((SELECT idItem FROM item WHERE nome = 'Uniforme' LIMIT 1), 'Vestimenta padrão de todos os tributos na Arena', 5),
    ((SELECT idItem FROM item WHERE nome = 'Casaco' LIMIT 1), 'Um casaco resistente que te protegerá contra o frio', 20);

-- Insere armas
INSERT INTO
    arma(idArma, descricao, adDano)
VALUES 
    ((SELECT idItem FROM item WHERE nome = 'Arco Artesanal' LIMIT 1), 'Arco feito de Galhos e corda', 5),
    ((SELECT idItem FROM item WHERE nome = 'Arco Profissional' LIMIT 1), 'Arco feito de metal', 10),
    ((SELECT idItem FROM item WHERE nome = 'Flecha Artesanal' LIMIT 1), 'Flecha feita de galho e pedra lascada', 5),
    ((SELECT idItem FROM item WHERE nome = 'Flecha Profissional' LIMIT 1), 'Flecha feita de metal', 10),
    ((SELECT idItem FROM item WHERE nome = 'Tridente' LIMIT 1), 'Tridente longo feito de metal', 20),
    ((SELECT idItem FROM item WHERE nome = 'Lança Profissional' LIMIT 1), 'Lança feita de metal', 15),
    ((SELECT idItem FROM item WHERE nome = 'Lança Artesanal' LIMIT 1), 'Flecha feita de galho e pedra lascada', 10),
    ((SELECT idItem FROM item WHERE nome = 'Espada' LIMIT 1), 'Espada grande feita de aço', 20),
    ((SELECT idItem FROM item WHERE nome = 'Faca' LIMIT 1), 'Faca pequena feita de aço', 5);

-- Insere itens consumíveis
INSERT INTO
    consumivel(idConsumivel, adHid, adNut, adSta, adHp, adCalor)
VALUES 
    ((SELECT idItem FROM item WHERE nome = 'Carne Crua' LIMIT 1), 10, 10, 10, 10, 5),
    ((SELECT idItem FROM item WHERE nome = 'Carne Assada' LIMIT 1), 20, 20, 15, 15, 10),
    ((SELECT idItem FROM item WHERE nome = 'Sopa' LIMIT 1), 15, 15, 10, 10, 5),
    ((SELECT idItem FROM item WHERE nome = 'Amora' LIMIT 1), 5, 10, 0, 5, 0),
    ((SELECT idItem FROM item WHERE nome = 'Amora Cadeado' LIMIT 1), 10, 10, 5, 10, 5),
    ((SELECT idItem FROM item WHERE nome = 'Ração' LIMIT 1), 25, 25, 20, 20, 15),
    ((SELECT idItem FROM item WHERE nome = 'Barra de Energia' LIMIT 1), 10, 5, 25, 10, 20),
    ((SELECT idItem FROM item WHERE nome = 'Água' LIMIT 1), 50, 0, 0, 0, 0);

-- Insere itens legíveis
INSERT INTO
    legivel(idLegivel, conteudo)
VALUES 
    ((SELECT idItem FROM item WHERE nome = 'Bilhete' LIMIT 1), 'Leia-me');

-- Insere compartimentos
INSERT INTO
    compartimento(idCompartimento, adCapMax)
VALUES 
    ((SELECT idItem FROM item WHERE nome = 'Mochila Pequena' LIMIT 1), 10),
    ((SELECT idItem FROM item WHERE nome = 'Mochila Grande' LIMIT 1), 15);

-- Funções para inventário
CREATE OR REPLACE FUNCTION criar_inventario()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO inventario (idPersonagem)
    VALUES (NEW.idPersonagem);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_criar_inventario
AFTER INSERT ON personagem_jogavel
FOR EACH ROW EXECUTE FUNCTION criar_inventario();

CREATE OR REPLACE FUNCTION adicionar_item_ao_inventario(p_idPersonagem INTEGER, p_idItem INTEGER)
RETURNS TEXT AS $$
DECLARE
    v_idInventario INTEGER;
    v_capAtual INTEGER;
    v_capMax INTEGER;
BEGIN
    -- Obtém o id do inventário do personagem
    SELECT idInventario INTO v_idInventario
    FROM inventario
    WHERE idPersonagem = p_idPersonagem;

    -- Verifica se o inventário foi encontrado
    IF v_idInventario IS NULL THEN
        RETURN 'Inventário não encontrado para o personagem.';
    END IF;

    -- Verifica a capacidade atual e máxima do inventário
    SELECT capAtual, capMax INTO v_capAtual, v_capMax
    FROM inventario
    WHERE idInventario = v_idInventario;

    -- Verifica se há espaço suficiente no inventário
    IF v_capAtual >= v_capMax THEN
        RETURN 'O inventário está cheio.';
    END IF;

    -- Adiciona o item ao inventário
    INSERT INTO item_inventario (idInventario, idItem)
    VALUES (v_idInventario, p_idItem);

    -- Atualiza a capacidade atual
    UPDATE inventario
    SET capAtual = capAtual + 1
    WHERE idInventario = v_idInventario;

    RETURN 'Item adicionado com sucesso ao inventário.';
END;
$$ LANGUAGE plpgsql;