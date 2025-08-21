-- 2.a.ii) 10 consultas variadas de acordo com requisitos da aplicação, com justificativa semântica e conforme critérios seguintes:

    -- 1 consulta com uma tabela usando operadores básicos de filtro (e.g., IN,between, is null, etc).

        -- Identifica conteúdos sem descrição, útil para administradores localizarem 
        -- materiais que precisam de complementação ou revisão.
        SELECT * from conteudo WHERE descricao IS Null;


    -- 3 consultas com inner JOIN na cláusula FROM (pode ser self join, caso odomínio indique esse uso).

        -- Busca usuários que publicaram conteúdos com a tag que remeta ao postgreSQL,
        -- facilitando a identificação de especialistas ou materiais relevantes sobre o tema.
        SELECT *
        FROM usuario u
        INNER JOIN conteudo c ON c.usuario_id = u.id
        INNER JOIN conteudo_tag ct ON ct.conteudo_id = c.id
        INNER JOIN tag t ON t.id = ct.tag_id
        WHERE LOWER(t.nome) LIKE '%postgres%';
                
        -- Busca todos os conteúdos marcados com a tag 'SQL', facilitando a organização de materiais
        -- para estudo específico desta linguagem e direcionamento para usuários interessados neste tópico.
        SELECT * from conteudo
        inner join conteudo_tag
        on conteudo.id = conteudo_tag.conteudo_id
        inner join tag
        on tag.id = conteudo_tag.tag_id
        where tag.nome = 'SQL';
    
        -- Identifica conteúdos com nota máxima (10), destacando os materiais de maior
        -- qualidade na plataforma para possível destaque ou recomendação aos usuários.
        SELECT * from conteudo
        inner join avaliacao
        on avaliacao.conteudo_id = conteudo.id
        where avaliacao.nota = 10;


    -- 1 consulta com left/right/full outer join na cláusula FROM 
        
        -- Exibe todos os conteúdos e suas avaliações (se existirem), permitindo analisar 
        -- quais conteúdos estão sem avaliação e precisam de mais engajamento.
        SELECT c.id, c.titulo, c.tipo, a.nota, a.comentario
        from conteudo c
        left join avaliacao a
        on c.id = a.conteudo_id
        order by c.id;


    -- 2 consultas usando Group By (e possivelmente o having)
    
        -- Contabiliza quantos conteúdos cada usuário publicou na plataforma,
        -- identificando os criadores mais ativos e produtivos para possíveis reconhecimentos.
        SELECT usuario_id, COUNT(*) as total_conteudos
        from conteudo
        group by usuario_id;
    
        -- Calcula a avaliação média por tipo de conteúdo, filtrando apenas os formatos com nota 
        -- média superior a 5, para identificar quais tipos são melhor avaliados pelos usuários
        -- e possivelmente priorizar esses formatos em futuras produções.
        SELECT c.tipo, AVG(a.nota)
        from conteudo c
        inner join avaliacao a
        on a.conteudo_id = c.id
        group by c.tipo
        having AVG(a.nota) > 5;


    -- 1 consulta usando alguma operação de conjunto (union, except ou intersect)
        
        -- Identifica conteúdos que ainda não receberam nenhuma avaliação, útil para encontrar
        -- materiais que precisam de mais engajamento ou promoção entre os usuários da plataforma.
        SELECT titulo from conteudo
        except
        SELECT c.titulo from conteudo c
        inner join avaliacao a
        on a.conteudo_id = c.id;


    -- 2 consultas que usem subqueries.
    
        -- Lista conteúdos publicados por administradores da plataforma, geralmente materiais
        -- oficiais ou com maior credibilidade, útil para destacar conteúdo.
        SELECT c.id as conteudo_id, c.titulo as titulo_conteudo, c.usuario_id
        from conteudo c
        where c.usuario_id in (select id from usuario where usuario.tipo = 'admin');


        -- Identifica roteiros que contêm ao menos um conteúdo pago, útil para informar
        -- aos usuários que determinadas trilhas de aprendizado requer algum investimento.
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