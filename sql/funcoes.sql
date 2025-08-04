-- 2.e. Funções e Procedures Armazenadas

-- 1 função com uso de `SUM`, `MAX`, `MIN`, `AVG` ou `COUNT`.
    -- Retorna estatísticas relacionas ao conteudo de um usuário específico.

    CREATE OR REPLACE FUNCTION calcular_estatisticas_usuario (
        usuario_id INTEGER
    ) RETURNS TABLE (
        total_conteudos INTEGER,
        total_avaliacoes_recebidas INTEGER,
        media_avaliacoes_recebidas NUMERIC
    ) AS $$
    BEGIN
        RETURN QUERY
        SELECT 
            COUNT(c.id) AS total_conteudos,
            COUNT(a.id) AS total_avaliacoes_recebidas,
            AVG(a.nota) AS media_avaliacoes_recebidas
        FROM 
            conteudo c
        LEFT JOIN 
            avaliacao a ON c.id = a.conteudo_id
        WHERE 
            c.usuario_id = usuario_id;
    END;
    $$ LANGUAGE plpgsql;


-- 2 outras funções com justificativa semântica.

    -- Busca conteúdos relacionados a uma tag específica.

    CREATE OR REPLACE FUNCTION buscar_conteudos_por_tag(
        nome_tag VARCHAR(100)
    ) RETURNS SETOF conteudo AS $$
    BEGIN
    RETURN QUERY
    SELECT * from conteudo c
        JOIN conteudo_tag ct
        on ct.conteudo_id = c.id
        JOIN tag t
        on t.id = ct.tag_id
    where t.nome = nome_tag;
    END;
    $$ LANGUAGE plpgsql;

    -- Busca conteudos relacionados com as tags de um outro conteudo, por exemplo, 
    -- a funçao recebe o id de um conteudo que tem varias tags e busca conteudos que
    -- partilham de tags parecidas, limitando o resultado ao valor do segundo parametro da funcao

    CREATE OR REPLACE function verificar_roteiro_completo(
        conteudo_id INTEGER,
        limite INTEGER
    ) RETURNS TABLE(
        id INTEGER,
        titulo VARCHAR(100),
        tipo tipo_conteudo,
        link_externo VARCHAR(255),
        descricao TEXT,
        tags_em_comum INTEGER
    ) AS $$
    BEGIN
    RETURN QUERY
    SELECT 
        id, titulo, tipo, link_externo, descricao, count(id) as tags_em_comum
    END;
    $$ LANGUAGE plpgsql;

    -- 1 procedure com justificativa semântica.  

    CREATE OR REPLACE PROCEDURE adiciona_conteudo_e_relaciona_roteiro(
        p_titulo VARCHAR(100),
        p_tipo tipo_conteudo,
        p_link_externo VARCHAR(255),
        p_descricao TEXT,
        p_pago BOOLEAN,
        p_usuario_id INTEGER,
        p_roteiro_id INTEGER,
        p_ordem INTEGER
    ) LANGUAGE plpgsql AS $$
    BEGIN

        IF p_usuario_id NOT IN (SELECT id FROM usuario) THEN
            RAISE EXCEPTION 'Usuário ID inválido';
        END IF;
        
        if p_roteiro_id NOT IN (SELECT id FROM roteiro) THEN
            RAISE EXCEPTION 'Roteiro ID inválido';
        END IF;

        INSERT INTO conteudo (titulo, tipo, link_externo, descricao, pago, usuario_id)
        VALUES (p_titulo, p_tipo, p_link_externo, p_descricao, p_pago, p_usuario_id);

        INSERT INTO roteiro_conteudo (roteiro_id, conteudo_id, ordem)
        VALUES (p_roteiro_id, currval('conteudo_id_seq'), p_ordem);    

        EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'Erro ao adicionar conteúdo e relacionar ao roteiro: %', SQLERRM;  
    END;
