--2.f) Trigger: 
-- Criar 3 triggers diferentes com justificativa semântica, conforme requisitos.

-- Trigger 1: Atualiza a data do roteiro quando novos conteúdos são adicionados
-- Justificativa: Mantém o registro temporal preciso, permitindo que usuários saibam quando um roteiro 
-- foi modificado pela última vez, melhorando a experiência de descoberta de conteúdo atualizado
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


-- Trigger 2: Impede avaliações tendenciosas ao bloquear usuários de avaliarem seu próprio conteúdo
-- Justificativa: Garante a integridade e confiabilidade do sistema de avaliação, 
-- evitando conflitos de interesse que comprometeriam a curadoria de conteúdo de qualidade
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


-- Trigger 3: Restringe o número de tags por conteúdo para garantir categorização eficiente
-- Justificativa: Evita a sobrecategorização de conteúdos, mantendo a organização da plataforma 
-- e incentivando os usuários a selecionar apenas as tags mais relevantes para cada recurso
CREATE OR REPLACE FUNCTION limitar_tags_conteudo()
RETURNS TRIGGER AS $$
DECLARE
    contagem INTEGER;
BEGIN
    SELECT COUNT(*) INTO contagem 
    FROM conteudo_tag 
    WHERE conteudo_id = NEW.conteudo_id;
    
    IF contagem >= 5 THEN
        RAISE EXCEPTION 'Um conteúdo pode ter no máximo 5 tags';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER limitar_tags_trigger
BEFORE INSERT ON conteudo_tag
FOR EACH ROW
EXECUTE FUNCTION limitar_tags_conteudo();