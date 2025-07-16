-- 2.a.ii) 10 consultas variadas de acordo com requisitos da aplicação, com justificativa semântica e conforme critérios seguintes:

	-- 1 consulta com uma tabela usando operadores básicos de filtro (e.g., IN,between, is null, etc).

		-- Para essa consulta a ideia é selecionar os conteúdos onde a descrição é Null
		SELECT * from conteudo WHERE descricao IS Null;

	-- 3 consultas com inner JOIN na cláusula FROM (pode ser self join, caso odomínio indique esse uso).

		SELECT * from usuario
		inner join conteudo
		on conteudo.usuario_id = usuario.id
		where conteudo.titulo like '%postgres%';
		
		SELECT * from conteudo
		inner join conteudo_tag
		on conteudo.id = conteudo_tag.conteudo_id
		inner join tag
		on tag.id = conteudo_tag.tag_id
		where tag.nome = 'SQL';
	
		SELECT * from conteudo
		inner join avaliacao
		on avaliacao.conteudo_id = conteudo.id
		where avaliacao.nota = 10;


	-- 1 consulta com left/right/full outer join na cláusula FROM

	-- 2 consultas usando Group By (e possivelmente o having)
	
		SELECT usuario_id, COUNT(*) as total_conteudos
		from conteudo
		group by usuario_id;
	
		SELECT c.tipo, AVG(a.nota)
		from conteudo c
		inner join avaliacao a
		on a.conteudo_id = c.id
		group by c.tipo
		having AVG(a.nota) > 5;

	-- 1 consulta usando alguma operação de conjunto (union, except ou intersect)
		-- Conteudos que nao tem nenhuma avaliacao
	SELECT titulo from conteudo
	except
	SELECT c.titulo from conteudo c
	inner join avaliacao a
	on a.conteudo_id = c.id;

	-- 2 consultas que usem subqueries.
	
		-- conteudos que foram criados por admins
	SELECT c.id as conteudo_id, c.titulo as titulo_conteudo, c.usuario_id
	from conteudo c
	where c.usuario_id in (select id from usuario where usuario.tipo = 'admin');

		-- roteiros que possuem pelo menos 1 conteudo pago
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
	