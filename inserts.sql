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