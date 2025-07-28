-- 2.d) Identificar 2 exemplos de consultas dentro do contexto da aplicação (questão 2.a) que possam e devam ser melhoradas. Reescrevê-las e justificar a reescrita.

    -- 1° Consulta que pode ser reescrita: "Identifica roteiros que contêm ao menos um conteúdo pago".
            SELECT r.id, r.titulo, r.usuario_id 
            from roteiro r
            where r.id in (
            select r.id 
            from roteiro r
            inner join roteiro_conteudo rc
            on rc.roteiro_id = r.id
            inner join conteudo c
            on c.id = rc.conteudo_id
            where c.pago = True
		);
        
        -- Podemos reescrever ela usando JOIN, retirando a subconsulta, deixando mais simples e possivelmente mais eficiente, e aplciando o DISTINCT que foi ignorado na primeira vez.
            SELECT DISTINCT r.id, r.titulo, r.usuario_id 
            FROM roteiro r
            INNER JOIN roteiro_conteudo rc ON r.id = rc.roteiro_id
            INNER JOIN conteudo c ON rc.conteudo_id = c.id
            WHERE c.pago = TRUE;