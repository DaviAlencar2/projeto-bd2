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
    
    -- 2° Consulta reescrita: Exibe conteúdos com estatísticas de avaliação (média e total), facilitando análise de engajamento.

        -- Consulta original:
            SELECT c.id, c.titulo, c.tipo, a.nota, a.comentario
            from conteudo c
            left join avaliacao a
            on c.id = a.conteudo_id
            order by c.id;


        -- -- Podemos reescrever usando funções de agregação para obter estatísticas úteis em vez de linhas individuais por avaliação, tornando a consulta mais informativa e evitando duplicações de conteúdos.
        SELECT 
            c.id, 
            c.titulo, 
            c.tipo, 
            COUNT(a.nota) AS total_avaliacoes,
            AVG(a.nota) AS media_nota
        FROM conteudo c
        LEFT JOIN avaliacao a ON c.id = a.conteudo_id
        GROUP BY c.id, c.titulo, c.tipo
        ORDER BY c.id;