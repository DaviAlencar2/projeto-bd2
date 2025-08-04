-- 2.b ) Visões

-- 1 visão que permita inserção 

	-- Não tenho um motivo muito bom para justificar a criação dessa view, apenas é um requisito obrigatório.
	CREATE OR REPLACE VIEW criar_avaliacao AS
	SELECT usuario_id, conteudo_id, nota, comentario
	from avaliacao;


-- 2 visões robustas (e.g., com vários joins) com justificativa semântica, de acordo com osrequisitos da aplicação.

	-- Mostra informações sobre o usuário e quantidade de conteúdos, avaliacoes e roteiros ele ja criou,
	-- muito útil para estatísticas relacionadas a usuários mais ativos.
	CREATE OR REPLACE VIEW criacoes_usuario AS
		SELECT u.id, u.nome, u.email,
		count(distinct c.id) as qntde_conteudos, 
		count(distinct a.usuario_id || '-' || a.conteudo_id) as qntde_avaliacoes, 
		count(distinct r.id) as qntde_roteiros
		from usuario u
		left join conteudo c
			on c.usuario_id = u.id
		left join avaliacao a
			on a.usuario_id = u.id
		left join roteiro r
			on r.usuario_id = u.id
		group by u.id;


	-- Para saber as top 3 tags que tem melhor média de avaliação em relação aos conteúdos.
	CREATE OR REPLACE VIEW top_tags AS
		SELECT t.nome, round(AVG(a.nota),2)
		from tag t
		inner join conteudo_tag ct
		on ct.tag_id = t.id
		inner join conteudo c
		on ct.conteudo_id = c.id
		inner join avaliacao a
		on a.conteudo_id = c.id
		group by t.nome
		order by avg(a.nota) desc
		LIMIT 3;
	
 					

	
