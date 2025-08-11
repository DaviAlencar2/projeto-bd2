-- Todos os códigos da pasta SQL estão escritos nesse arquivo, como foi pedido nos requisitos do projeto.
-- =========================
-- 2.a.i) Tabelas e constraints
-- =========================

CREATE TYPE tipo_usuario AS ENUM ('comum', 'admin');
CREATE TYPE tipo_conteudo AS ENUM ('video', 'playlist', 'podcast', 'artigo', 'site', 'curso');

CREATE TABLE usuario (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL,
    hash_senha      VARCHAR(255) NOT NULL,
    tipo            tipo_usuario NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE conteudo (
    id              SERIAL PRIMARY KEY,
    titulo          VARCHAR(100) NOT NULL,
    tipo            tipo_conteudo NOT NULL,
    link_externo    VARCHAR(255) NOT NULL,
    descricao       TEXT,
    pago            BOOLEAN NOT NULL,
    criado_em       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id      INT NOT NULL REFERENCES usuario(id)
);

CREATE TABLE tag (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE roteiro (
    id              SERIAL PRIMARY KEY,
    titulo          VARCHAR(100) NOT NULL,
    descricao       TEXT,
    publico         BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id      INT NOT NULL REFERENCES usuario(id),
    atualizado_em   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE conteudo_tag (
    conteudo_id     INT REFERENCES conteudo(id) ON DELETE CASCADE,
    tag_id          INT REFERENCES tag(id) ON DELETE CASCADE,
    PRIMARY KEY (conteudo_id, tag_id)
);

CREATE TABLE roteiro_conteudo (
    roteiro_id      INT REFERENCES roteiro(id) ON DELETE CASCADE,
    conteudo_id     INT REFERENCES conteudo(id) ON DELETE CASCADE,
    ordem           INT NOT NULL,
    PRIMARY KEY (roteiro_id, conteudo_id)
);

CREATE TABLE avaliacao (
    usuario_id      INT REFERENCES usuario(id) ON DELETE CASCADE,
    conteudo_id     INT REFERENCES conteudo(id) ON DELETE CASCADE,
    nota            INT CHECK (nota BETWEEN 0 AND 10),
    comentario      TEXT NOT NULL,
    criado_em       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, conteudo_id)
);

CREATE TABLE auditoria (
    id              SERIAL PRIMARY KEY,
    operacao        VARCHAR(50) NOT NULL,
    tabela          VARCHAR(50) NOT NULL,
    data            TIMESTAMP NOT NULL
);

-- =========================
-- Inserts de exemplo
-- =========================

-- Usuários
INSERT INTO usuario (nome, hash_senha, tipo, email) VALUES
('Alice', 'hash1', 'comum', 'alice@email.com'),
('Bruno', 'hash2', 'admin', 'bruno@email.com'),
('Carla', 'hash3', 'comum', 'carla@email.com'),
('Daniel', 'hash4', 'comum', 'daniel@email.com'),
('Eva', 'hash5', 'admin', 'eva@email.com');

-- Conteúdos
INSERT INTO conteudo (titulo, tipo, link_externo, descricao, pago, usuario_id) VALUES
('Introdução ao SQL', 'video', 'https://exemplo.com/sql', 'Curso básico de SQL', false, 1),
('PostgreSQL Avançado', 'curso', 'https://exemplo.com/pg', 'Tópicos avançados', true, 2),
('HTML para Iniciantes', 'artigo', 'https://exemplo.com/html', NULL, false, 3),
('Python Essencial', 'playlist', 'https://exemplo.com/python', 'Playlist de Python', false, 1),
('Banco de Dados Relacional', 'podcast', 'https://exemplo.com/bd', 'Podcast sobre BD', false, 4);

-- Tags
INSERT INTO tag (nome) VALUES
('SQL'),
('Banco de Dados'),
('Python'),
('Web'),
('PostgreSQL');

-- Roteiros
INSERT INTO roteiro (titulo, descricao, publico, usuario_id) VALUES
('Roteiro SQL', 'Aprenda SQL do zero', true, 1),
('Roteiro Python', 'Do básico ao avançado', false, 3);

-- Conteúdo-Tag (N:N)
INSERT INTO conteudo_tag (conteudo_id, tag_id) VALUES
(1, 1), -- Introdução ao SQL - SQL
(1, 2), -- Introdução ao SQL - Banco de Dados
(2, 1), -- PostgreSQL Avançado - SQL
(2, 5), -- PostgreSQL Avançado - PostgreSQL
(3, 4), -- HTML para Iniciantes - Web
(4, 3), -- Python Essencial - Python
(5, 2); -- Banco de Dados Relacional - Banco de Dados

-- Roteiro-Conteúdo (N:N)
INSERT INTO roteiro_conteudo (roteiro_id, conteudo_id, ordem) VALUES
(1, 1, 1),
(1, 2, 2),
(1, 5, 3),
(2, 4, 1),
(2, 3, 2);

-- Avaliações
INSERT INTO avaliacao (usuario_id, conteudo_id, nota, comentario) VALUES
(1, 1, 9, 'Muito bom!'),
(2, 1, 8, 'Gostei do conteúdo'),
(3, 2, 10, 'Excelente curso'),
(4, 3, 7, 'Bom artigo'),
(5, 4, 6, 'Poderia ser mais detalhado'),
(1, 5, 8, 'Podcast interessante');

-- =========================
-- 2.a.ii) 10 Consultas variadas
-- =========================

-- 1 consulta com filtro IS NULL
SELECT * from conteudo WHERE descricao IS Null;

-- 3 consultas com INNER JOIN
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

-- 1 consulta com LEFT JOIN
SELECT c.id, c.titulo, c.tipo, a.nota, a.comentario
from conteudo c
left join avaliacao a
on c.id = a.conteudo_id
order by c.id;

-- 2 consultas com GROUP BY
SELECT usuario_id, COUNT(*) as total_conteudos
from conteudo
group by usuario_id;

SELECT c.tipo, AVG(a.nota)
from conteudo c
inner join avaliacao a
on a.conteudo_id = c.id
group by c.tipo
having AVG(a.nota) > 5;

-- 1 consulta com EXCEPT
SELECT titulo from conteudo
except
SELECT c.titulo from conteudo c
inner join avaliacao a
on a.conteudo_id = c.id;

-- 2 consultas com subqueries
SELECT c.id as conteudo_id, c.titulo as titulo_conteudo, c.usuario_id
from conteudo c
where c.usuario_id in (select id from usuario where usuario.tipo = 'admin');

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

-- =========================
-- 2.b) Visões (Views)
-- =========================

-- 1 visão que permite inserção
CREATE OR REPLACE VIEW criar_avaliacao AS
SELECT usuario_id, conteudo_id, nota, comentario
from avaliacao;

-- 2 visões robustas
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

-- =========================
-- 2.c) Índices
-- =========================

CREATE INDEX idx_conteudo_usuario_id ON conteudo(usuario_id);
CREATE INDEX idx_avaliacao_conteudo_id ON avaliacao(conteudo_id);
CREATE INDEX idx_conteudo_pago ON conteudo(pago);

-- =========================
-- 2.d) Reescrita de Consultas
-- =========================

-- Consulta original: roteiros com conteúdo pago
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

-- Consulta reescrita
SELECT DISTINCT r.id, r.titulo, r.usuario_id 
FROM roteiro r
INNER JOIN roteiro_conteudo rc ON r.id = rc.roteiro_id
INNER JOIN conteudo c ON rc.conteudo_id = c.id
WHERE c.pago = TRUE;

-- Consulta original: conteúdos com estatísticas de avaliação
SELECT c.id, c.titulo, c.tipo, a.nota, a.comentario
from conteudo c
left join avaliacao a
on c.id = a.conteudo_id
order by c.id;

-- Consulta reescrita
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

-- =========================
-- 2.e) Funções e Procedures Armazenadas
-- =========================

-- Função com uso de agregação
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

-- Função: buscar conteúdos por tag
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

-- Função: buscar conteúdos com tags em comum
CREATE OR REPLACE FUNCTION verificar_roteiro_completo(
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
    c.id, c.titulo, c.tipo, c.link_externo, c.descricao, COUNT(*) as tags_em_comum
FROM conteudo c
JOIN conteudo_tag ct ON ct.conteudo_id = c.id
WHERE ct.tag_id IN (
    SELECT tag_id FROM conteudo_tag WHERE conteudo_id = verificar_roteiro_completo.conteudo_id
)
AND c.id <> verificar_roteiro_completo.conteudo_id
GROUP BY c.id, c.titulo, c.tipo, c.link_externo, c.descricao
ORDER BY tags_em_comum DESC
LIMIT limite;
END;
$$ LANGUAGE plpgsql;

-- Procedure: adiciona conteúdo e relaciona a roteiro
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
    
    IF p_roteiro_id NOT IN (SELECT id FROM roteiro) THEN
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

-- =========================
-- 2.f) Triggers
-- =========================

-- Atualizar roteiro após insert em roteiro_conteudo
CREATE OR REPLACE FUNCTION atualiza_roteiro()
RETURNS TRIGGER AS $$
BEGIN 
    UPDATE roteiro SET atualizado_em = now()
    WHERE id = NEW.roteiro_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER roteiro_conteudo_insert
AFTER INSERT ON roteiro_conteudo
FOR EACH ROW
EXECUTE FUNCTION atualiza_roteiro();

-- Auditoria usuario
CREATE OR REPLACE FUNCTION auditoria_usuario()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria (operacao, tabela, data)
    VALUES (TG_OP,'usuario',now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auditoria_usuario_trigger
AFTER INSERT OR UPDATE OR DELETE ON usuario
FOR EACH ROW
EXECUTE FUNCTION auditoria_usuario();

-- Auditoria Conteudo
CREATE OR REPLACE FUNCTION auditoria_conteudo()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria (operacao, tabela, data)
    VALUES (TG_OP,'conteudo',now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auditoria_conteudo_trigger
AFTER INSERT OR UPDATE OR DELETE ON conteudo
FOR EACH ROW
EXECUTE FUNCTION auditoria_conteudo();
