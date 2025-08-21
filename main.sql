-- Instituto Federal da Paraíba - IFPB
-- Unidade Acadêmica de Informação e Comunicação
-- CST em Sistemas para Internet
-- Disciplina: Banco de Dados II – 2025.1
-- Projeto: Plataforma de Curadoria de Conteúdo

-- ============================================================================
-- 2.a.i) TABELAS E CONSTRAINTS
-- ============================================================================

-- Tipos enumerados
CREATE TYPE tipo_usuario AS ENUM ('comum', 'admin');
CREATE TYPE tipo_conteudo AS ENUM ('video', 'playlist', 'podcast', 'artigo', 'site', 'curso');

-- Tabela de usuários
CREATE TABLE usuario (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL,
    hash_senha      VARCHAR(255) NOT NULL,
    tipo            tipo_usuario NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL
);

-- Tabela de conteúdos
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

-- Tabela de tags
CREATE TABLE tag (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL UNIQUE
);

-- Tabela de roteiros
CREATE TABLE roteiro (
    id              SERIAL PRIMARY KEY,
    titulo          VARCHAR(100) NOT NULL,
    descricao       TEXT,
    publico         BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id      INT NOT NULL REFERENCES usuario(id),
    atualizado_em   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de relacionamento N:N conteúdo-tag
CREATE TABLE conteudo_tag (
    conteudo_id     INT REFERENCES conteudo(id) ON DELETE CASCADE,
    tag_id          INT REFERENCES tag(id) ON DELETE CASCADE,
    PRIMARY KEY (conteudo_id, tag_id)
);

-- Tabela de relacionamento N:N roteiro-conteúdo
CREATE TABLE roteiro_conteudo (
    roteiro_id      INT REFERENCES roteiro(id) ON DELETE CASCADE,
    conteudo_id     INT REFERENCES conteudo(id) ON DELETE CASCADE,
    ordem           INT NOT NULL,
    PRIMARY KEY (roteiro_id, conteudo_id)
);

-- Tabela de avaliações
CREATE TABLE avaliacao (
    usuario_id      INT REFERENCES usuario(id) ON DELETE CASCADE,
    conteudo_id     INT REFERENCES conteudo(id) ON DELETE CASCADE,
    nota            INT CHECK (nota BETWEEN 0 AND 10),
    comentario      TEXT NOT NULL,
    criado_em       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, conteudo_id)
);

-- ============================================================================
-- INSERÇÃO DE DADOS
-- ============================================================================

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

-- ============================================================================
-- 2.b) VISÕES (VIEWS)
-- ============================================================================

-- 1 visão que permita inserção 
-- Facilita o registro assumindo que a maioria dos novos usuários será do tipo 'comum'
CREATE OR REPLACE VIEW usuario_comum AS
SELECT id, nome, email, hash_senha, tipo
FROM usuario
WHERE tipo = 'comum';

-- Função para automaticamente setar tipo como 'comum' ao inserir via view
CREATE OR REPLACE FUNCTION inserir_usuario_comum()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO usuario (nome, email, hash_senha, tipo)
    VALUES (NEW.nome, NEW.email, NEW.hash_senha, 'comum');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para automaticamente setar tipo como 'comum' ao inserir via view
CREATE OR REPLACE TRIGGER usuario_comum_insert
INSTEAD OF INSERT ON usuario_comum
FOR EACH ROW
EXECUTE FUNCTION inserir_usuario_comum();

-- 2 visões robustas (e.g., com vários joins) com justificativa semântica

-- Mostra informações sobre o usuário e quantidade de conteúdos, avaliações e roteiros ele já criou,
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

-- ============================================================================
-- 2.c) ÍNDICES
-- ============================================================================

-- Otimiza buscas de conteúdos por usuário, essencial para estatísticas e filtros de criador
CREATE INDEX idx_conteudo_usuario_id ON conteudo(usuario_id);

-- Acelera joins entre conteúdos e avaliações, usado em cálculos de média e contagens
CREATE INDEX idx_avaliacao_conteudo_id ON avaliacao(conteudo_id);

-- Melhora filtros de conteúdos pagos vs gratuitos em consultas e relatórios
CREATE INDEX idx_conteudo_pago ON conteudo(pago);

-- ============================================================================
-- 2.e) FUNÇÕES E PROCEDURES ARMAZENADAS
-- ============================================================================

-- 1 função com uso de SUM, MAX, MIN, AVG ou COUNT
-- Retorna estatísticas relacionadas ao conteúdo de um usuário específico
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

-- 2 outras funções com justificativa semântica
-- Busca conteúdos relacionados a uma tag específica
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

-- 1 procedure com justificativa semântica (e tratamento de exceções)
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

-- ============================================================================
-- 2.f) TRIGGERS
-- ============================================================================

-- Trigger 1: Atualiza a data do roteiro quando novos conteúdos são adicionados
-- Justificativa: Mantém o registro temporal preciso, permitindo que usuários saibam quando um roteiro 
-- foi modificado pela última vez, melhorando a experiência de descoberta de conteúdo atualizado
CREATE OR REPLACE FUNCTION atualiza_roteiro()
RETURNS TRIGGER AS $$
BEGIN 
    UPDATE roteiro SET atualizado_em = now()
    where id = NEW.roteiro_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER roteiro_conteudo_insert
AFTER INSERT ON roteiro_conteudo
FOR EACH ROW
EXECUTE FUNCTION atualiza_roteiro();

-- Trigger 2: Impede avaliações tendenciosas ao bloquear usuários de avaliarem seu próprio conteúdo
-- Justificativa: Garante a integridade e confiabilidade do sistema de avaliação, 
-- evitando conflitos de interesse que comprometeriam a curadoria de conteúdo de qualidade
CREATE OR REPLACE FUNCTION validar_avaliacao()
RETURNS TRIGGER AS $$
BEGIN
    -- Impedir que usuário avalie seu próprio conteúdo
    IF (SELECT usuario_id FROM conteudo WHERE id = NEW.conteudo_id) = NEW.usuario_id THEN
        RAISE EXCEPTION 'Usuários não podem avaliar seu próprio conteúdo';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER validar_avaliacao_trigger
BEFORE INSERT ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION validar_avaliacao();

-- Trigger 3: Restringe o número de tags por conteúdo para garantir categorização eficiente
-- Justificativa: Evita a sobrecategorização de conteúdos, mantendo a organização da plataforma 
-- e incentivando os usuários a selecionar apenas as tags mais relevantes para cada recurso
CREATE OR REPLACE FUNCTION limitar_tags_conteudo()
RETURNS TRIGGER AS $$
DECLARE
    contagem INTEGER;
BEGIN
    SELECT COUNT(*) INTO contagem 
    FROM conteudo_tag 
    WHERE conteudo_id = NEW.conteudo_id;
    
    IF contagem >= 5 THEN
        RAISE EXCEPTION 'Um conteúdo pode ter no máximo 5 tags';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER limitar_tags_trigger
BEFORE INSERT ON conteudo_tag
FOR EACH ROW
EXECUTE FUNCTION limitar_tags_conteudo();

-- ============================================================================
-- 2.a.ii) CONSULTAS VARIADAS
-- ============================================================================

-- 1 consulta com uma tabela usando operadores básicos de filtro
-- Identifica conteúdos sem descrição, útil para administradores localizarem 
-- materiais que precisam de complementação ou revisão.
SELECT * from conteudo WHERE descricao IS Null;

-- 3 consultas com inner JOIN na cláusula FROM

-- Busca usuários que publicaram conteúdos com a tag que remeta ao PostgreSQL,
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

-- 2 consultas que usem subqueries

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

-- ============================================================================
-- 2.d) REESCRITA DE CONSULTAS
-- ============================================================================

-- 1° Consulta que pode ser reescrita: "Identifica roteiros que contêm ao menos um conteúdo pago".
-- Consulta original (menos eficiente):
/*
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
*/

-- Reescrita melhorada: usando JOIN, retirando a subconsulta, deixando mais simples e 
-- possivelmente mais eficiente, e aplicando o DISTINCT que foi ignorado na primeira vez.
SELECT DISTINCT r.id, r.titulo, r.usuario_id 
FROM roteiro r
INNER JOIN roteiro_conteudo rc ON r.id = rc.roteiro_id
INNER JOIN conteudo c ON rc.conteudo_id = c.id
WHERE c.pago = TRUE;

-- 2° Consulta reescrita: Exibe conteúdos com estatísticas de avaliação (média e total), 
-- facilitando análise de engajamento.

-- Consulta original (menos informativa):
/*
SELECT c.id, c.titulo, c.tipo, a.nota, a.comentario
from conteudo c
left join avaliacao a
on c.id = a.conteudo_id
order by c.id;
*/

-- Reescrita melhorada: usando funções de agregação para obter estatísticas úteis 
-- em vez de linhas individuais por avaliação, tornando a consulta mais informativa 
-- e evitando duplicações de conteúdos.
SELECT 
    c.id, 
    c.titulo, 
    c.tipo, 
    COUNT(a.nota) AS total_avaliacoes,
    AVG(a.nota) AS media_nota
FROM conteudo c
LEFT JOIN avaliacao a ON c.id = a.conteudo_id
GROUP BY c.id, c.titulo, c.tipo