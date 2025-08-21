-- 2.b ) Visões

-- 1 visão que permita inserção 

	-- Facilita o registro assumindo que a maioria dos novos usuários será do tipo 'comum'
	CREATE OR REPLACE VIEW usuario_comum AS
    SELECT id, nome, email, hash_senha, tipo
    FROM usuario
    WHERE tipo = 'comum';

	-- Trigger para automaticamente setar tipo como 'comum' ao inserir via view
	CREATE OR REPLACE FUNCTION inserir_usuario_comum()
	RETURNS TRIGGER AS $$
	BEGIN
		INSERT INTO usuario (nome, email, hash_senha, tipo)
		VALUES (NEW.nome, NEW.email, NEW.hash_senha, 'comum');
		RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

	CREATE OR REPLACE TRIGGER usuario_comum_insert
	INSTEAD OF INSERT ON usuario_comum
	FOR EACH ROW
	EXECUTE FUNCTION inserir_usuario_comum();


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


	-- Visão robusta: informações detalhadas sobre cada conteúdo, incluindo estatísticas de avaliação e autor
	
	CREATE OR REPLACE VIEW informacoes_conteudo AS
	SELECT
		c.id,
		c.titulo,
		c.tipo,
		c.link_externo,
		c.descricao,
		c.pago,
		u.nome AS autor,
		COUNT(a.nota) AS total_avaliacoes,
		ROUND(AVG(a.nota), 2) AS media_nota,
		COUNT(DISTINCT rc.roteiro_id) AS total_roteiros
	FROM conteudo c
	JOIN usuario u ON c.usuario_id = u.id
	LEFT JOIN avaliacao a ON a.conteudo_id = c.id
	LEFT JOIN roteiro_conteudo rc ON rc.conteudo_id = c.id
	GROUP BY c.id, c.titulo, c.tipo, c.link_externo, c.descricao, c.pago, u.nome;

	
