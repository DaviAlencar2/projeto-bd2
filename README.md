# Instituto Federal da Paraíba - IFPB  
**Unidade Acadêmica de Informação e Comunicação**  
**CST em Sistemas para Internet**  
**Disciplina:** Banco de Dados II – 2025.1  
**Professores:** Damires e Thiago  

## Roteiro para Projeto de Banco de Dados Relacional

> **Instruções Gerais**  
> - Crie um documento Google e inclua todos os códigos e enunciados/explicações pedidos.  
> - Os comandos devem também ser entregues via um único script (apenas **UM** anexado à tarefa).

---

### 1. Diagramas Entidade-Relacionamento
- Nível conceitual e lógico atualizados  
**(10,0 pontos)**

---

### 2. Implementação do projeto de BDR no SGBD PostgreSQL  
> **Observações:**  
> - Todas as operações devem apresentar seu enunciado e sua solução.  
> - Os comandos devem fazer sentido à aplicação e seus requisitos.

#### a. Criação e uso de objetos básicos **(15,0 pontos)**  
i. Tabelas e constraints (PK, FK, UNIQUE, NOT NULL, CHECKs) conforme regras de negócio.  
ii. 10 consultas variadas com justificativa semântica:  
- 1 consulta com operadores de filtro: `IN`, `BETWEEN`, `IS NULL`, etc.  
- 3 consultas com `INNER JOIN` (inclusive `SELF JOIN` se fizer sentido).  
- 1 consulta com `LEFT`, `RIGHT` ou `FULL OUTER JOIN`.  
- 2 consultas com `GROUP BY` (e possivelmente `HAVING`).  
- 1 consulta com operação de conjunto: `UNION`, `EXCEPT` ou `INTERSECT`.  
- 2 consultas com subqueries.

#### b. Visões (Views) **(14,0 pontos)**  
- 1 visão que permita inserção.  
- 2 visões robustas (com múltiplos joins) com justificativa semântica.

#### c. Índices **(12,0 pontos)**  
- Criar 3 índices com justificativa, relacionados às consultas da seção 2.a.

#### d. Reescrita de Consultas **(6,0 pontos)**  
- Identificar 2 consultas que possam ser otimizadas.  
- Reescrevê-las e justificar a reescrita.

#### e. Funções e Procedures Armazenadas **(16,0 pontos)**  
- 1 função com uso de `SUM`, `MAX`, `MIN`, `AVG` ou `COUNT`.  
- 2 outras funções com justificativa semântica.  
- 1 procedure com justificativa semântica.  
> **Pelo menos uma função ou procedure deve conter tratamento de exceção.**  
> **Não são as mesmas funções das triggers.**

#### f. Triggers **(12,0 pontos)**  
- Criar 3 triggers diferentes com justificativa semântica, conforme requisitos.

---

### 3. Entrega de Todo o Projeto

---

### 4. Apresentação e Avaliação em Laboratório **(10,0 pontos)**  
- 10 minutos de apresentação por grupo.  
- Avaliação posterior no laboratório.

> **Na apresentação:**  
> - Todos os integrantes devem participar.  
> - Pode usar PowerPoint ou equivalente.  
> - Mostrar e explicar o DER conceitual.  
> - Apresentar exemplo com justificativa e execução para:  
>   - Uma visão  
>   - Uma função  
>   - Uma trigger (a mais interessante)
