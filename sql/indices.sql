-- 2.c) 3 índices para campos indicados com justificativa dentro do contexto das consultas formuladas na questão 3a.


-- indice para achar o id de usuarios a partir de conteudos na 
CREATE INDEX idx_conteudo_usuario_id ON conteudo(usuario_id);

CREATE INDEX idx_avaliacao_conteudo_id ON avaliacao(conteudo_id);