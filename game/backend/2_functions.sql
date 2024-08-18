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

