--2.f) Trigger: 
-- Criar 3 triggers diferentes com justificativa semântica, conforme requisitos.

-- Atualizar roteiro após insert em roteiro conteudo.

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
EXECUTE FUNCTION atualiza_roteiro();


CREATE OR REPLACE FUNCTION validar_avaliacao()
RETURNS TRIGGER AS $$
BEGIN
    -- Impedir que usuário avalie seu próprio conteúdo
    IF (SELECT usuario_id FROM conteudo WHERE id = NEW.conteudo_id) = NEW.usuario_id THEN
        RAISE EXCEPTION 'Usuários não podem avaliar seu próprio conteúdo';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER validar_avaliacao_trigger
BEFORE INSERT ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION validar_avaliacao();


-- Auditoria Conteudo
CREATE OR REPLACE FUNCTION auditoria_conteudo()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria (operacao, tabela, data)
    VALUES (TG_OP,'conteudo',now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auditoria_conteudo_trigger
AFTER INSERT OR UPDATE OR DELETE ON conteudo
FOR EACH ROW
EXECUTE FUNCTION auditoria_conteudo();
