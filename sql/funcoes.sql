-- 2.e. Funções e Procedures Armazenadas

-- 1 função com uso de `SUM`, `MAX`, `MIN`, `AVG` ou `COUNT`.
    -- Retorna estatísticas relacionas ao conteudo de um usuário específico.

   CREATE OR REPLACE FUNCTION calcular_estatisticas_usuario (
    usuario_id INTEGER
    ) RETURNS TABLE (
        total_conteudos BIGINT,
        total_avaliacoes_recebidas BIGINT,
        media_avaliacoes_recebidas NUMERIC
    ) AS $$
    BEGIN
        RETURN QUERY
        SELECT 
            COUNT(DISTINCT c.id) AS total_conteudos,
            COUNT(a.usuario_id) AS total_avaliacoes_recebidas,
            AVG(a.nota) AS media_avaliacoes_recebidas
        FROM 
            conteudo c
        LEFT JOIN 
            avaliacao a ON c.id = a.conteudo_id
        WHERE 
            c.usuario_id = calcular_estatisticas_usuario.usuario_id;
    END;
    $$ LANGUAGE plpgsql;


-- 2 outras funções com justificativa semântica.

    -- Busca conteúdos relacionados a uma tag específica.

    CREATE OR REPLACE FUNCTION buscar_conteudos_por_tag(
        nome_tag VARCHAR(100)
    ) RETURNS SETOF conteudo AS $$
    BEGIN
    RETURN QUERY
    SELECT c.* from conteudo c
        JOIN conteudo_tag ct
        on ct.conteudo_id = c.id
        JOIN tag t
        on t.id = ct.tag_id
    where t.nome = nome_tag;
    END;
    $$ LANGUAGE plpgsql;


    -- 2 outras funções com justificativa semântica.
    -- Função que verifica se um roteiro contém algum conteúdo pago
    -- Retorna TRUE se o roteiro contém pelo menos um conteúdo pago, FALSE caso contrário
    CREATE OR REPLACE FUNCTION roteiro_contem_conteudo_pago(
        p_roteiro_id INTEGER
    ) RETURNS BOOLEAN AS $$
    DECLARE
        contem_pago BOOLEAN;
    BEGIN
        -- Verifica se o roteiro existe
        IF NOT EXISTS (SELECT 1 FROM roteiro WHERE id = p_roteiro_id) THEN
            RAISE EXCEPTION 'Roteiro ID % não existe', p_roteiro_id;
        END IF;
        
        -- Verifica se o roteiro contém algum conteúdo pago
        SELECT EXISTS (
            SELECT 1
            FROM roteiro_conteudo rc
            JOIN conteudo c ON c.id = rc.conteudo_id
            WHERE rc.roteiro_id = p_roteiro_id AND c.pago = TRUE
        ) INTO contem_pago;
        
        RETURN contem_pago;
    END;
    $$ LANGUAGE plpgsql;




    -- 1 procedure com justificativa semântica( e tratamento de exceções).

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
    DECLARE
        conteudo_novo_id INTEGER;
    BEGIN

        IF p_usuario_id NOT IN (SELECT id FROM usuario) THEN    
            RAISE EXCEPTION 'Usuário ID inválido';
        END IF;
        
        if p_roteiro_id NOT IN (SELECT id FROM roteiro) THEN
            RAISE EXCEPTION 'Roteiro ID inválido';
        END IF;

        INSERT INTO conteudo (titulo, tipo, link_externo, descricao, pago, usuario_id) 
        VALUES (p_titulo, p_tipo, p_link_externo, p_descricao, p_pago, p_usuario_id)
        RETURNING id INTO conteudo_novo_id;

        INSERT INTO roteiro_conteudo (roteiro_id, conteudo_id, ordem)
        VALUES (p_roteiro_id, conteudo_novo_id, p_ordem);  

        EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'Erro ao adicionar conteúdo e relacionar ao roteiro: %', SQLERRM;  
    END;
    $$;
