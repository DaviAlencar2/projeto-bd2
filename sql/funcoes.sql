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
