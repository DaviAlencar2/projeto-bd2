-- 2.c) 3 índices para campos indicados com justificativa dentro do contexto das consultas formuladas na questão 3a.

-- Otimiza buscas de conteúdos por usuário, essencial para estatísticas e filtros de criador
CREATE INDEX idx_conteudo_usuario_id ON conteudo(usuario_id);

-- Acelera joins entre conteúdos e avaliações, usado em cálculos de média e contagens
CREATE INDEX idx_avaliacao_conteudo_id ON avaliacao(conteudo_id);

-- Melhora filtros de conteúdos pagos vs gratuitos em consultas e relatórios
CREATE INDEX idx_conteudo_pago ON conteudo(pago);