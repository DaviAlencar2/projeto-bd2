-- 2.a.i) Tabelas e constraints (PK, FK, UNIQUE, campos que não podem ter valores nulos, checks de validação) de acordo com as regras de negócio do projeto.

CREATE TYPE tipo_usuario AS ENUM ('comum', 'admin');
CREATE TYPE tipo_conteudo AS ENUM ('video', 'playlist', 'podcast', 'artigo', 'site', 'curso');

CREATE TABLE usuario (
    id         	SERIAL PRIMARY KEY,
    nome       	VARCHAR(100) NOT NULL,
    hash_senha	VARCHAR(255) NOT NULL,
    tipo       	tipo_usuario NOT NULL,
    email      	VARCHAR(100) UNIQUE NOT NULL
);


CREATE TABLE conteudo (
    id 				SERIAL PRIMARY KEY,
    titulo			VARCHAR(100) NOT NULL,
    tipo			tipo_conteudo NOT NULL,
    link_externo	VARCHAR(255) NOT NULL,
    descricao		TEXT,
    pago			BOOLEAN NOT NULL,
    criado_em		TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id 		INT NOT NULL REFERENCES usuario(id)
);


CREATE TABLE tag (
    id		SERIAL PRIMARY KEY,
    nome	VARCHAR(100) NOT NULL UNIQUE
);


CREATE TABLE roteiro (
    id			SERIAL PRIMARY KEY,
    titulo		VARCHAR(100) NOT NULL,
    descricao	TEXT,
    publico 	BOOLEAN NOT NULL DEFAULT TRUE,
	criado_em	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id	INT NOT NULL REFERENCES usuario(id),
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- N:N 
CREATE TABLE conteudo_tag (
    conteudo_id 		INT REFERENCES conteudo(id) ON DELETE CASCADE,
    tag_id 				INT REFERENCES tag(id) ON DELETE CASCADE,
    PRIMARY KEY (conteudo_id, tag_id)
);


-- N:N
CREATE TABLE roteiro_conteudo (
    roteiro_id 			INT REFERENCES roteiro(id) ON DELETE CASCADE,
    conteudo_id 		INT REFERENCES conteudo(id) ON DELETE CASCADE,
	ordem 				INT NOT NULL,
    PRIMARY KEY (roteiro_id, conteudo_id)
);


CREATE TABLE avaliacao (
    usuario_id 			INT REFERENCES usuario(id) ON DELETE CASCADE,
    conteudo_id 		INT REFERENCES conteudo(id) ON DELETE CASCADE,
    nota 				INT CHECK (nota BETWEEN 0 AND 10),
    comentario 			TEXT NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, conteudo_id)
);

CREATE TABLE auditoria (
    id          SERIAL PRIMARY KEY,
    operacao    VARCHAR(50) NOT NULL,
    tabela      VARCHAR(50) NOT NULL,
    data        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);