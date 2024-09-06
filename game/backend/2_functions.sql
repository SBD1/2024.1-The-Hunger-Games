CREATE OR REPLACE FUNCTION criar_inventario()
RETURNS TRIGGER AS $$
BEGIN
    -- Insere um novo inventário para o personagem recém-criado
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

    -- Atualiza a capacidade atual do inventário
    UPDATE inventario
    SET capAtual = capAtual + 1
    WHERE idInventario = v_idInventario;

    RETURN 'Item adicionado com sucesso ao inventário.';
END;
$$ LANGUAGE plpgsql;
