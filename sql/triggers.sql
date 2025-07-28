--2.f) Trigger: 
-- Criar 3 triggers diferentes com justificativa semântica, conforme requisitos.

-- Atualizar roteiro apois insert em roteiro conteudo

CREATE OR REPLACE FUNCTION atualiza_roteiro()
RETURNS TRIGGER AS $$
BEGIN 
	UPDATE roteiro SET atualizado_em = now()
	where id = NEW.roteiro_id;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER roteiro_conteudo_insert
AFTER INSERT ON roteiro_conteudo
FOR EACH ROW
EXECUTE function atualiza_roteiro();


-- Auditoria usuario
CREATE OR REPLACE FUNCTION auditoria_usuario()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria (operaco, tabela, data)
    VALUES (TG_OP,'usuario',now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auditoria_usuario_trigger
AFTER INSERT OR UPDATE OR DELETE ON usuario
FOR EACH ROW
EXECUTE FUNCTION auditoria_usuario();


-- Auditoria Conteudo
CREATE OR REPLACE FUNCTION auditoria_conteudo()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria (operaco, tabela, data)
    VALUES (TG_OP,'conteudo',now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auditoria_conteudo_trigger
AFTER INSERT OR UPDATE OR DELETE ON conteudo
FOR EACH ROW
EXECUTE FUNCTION auditoria_conteudo();
