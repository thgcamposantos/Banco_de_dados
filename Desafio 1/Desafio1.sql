--3. Consultas Simples (Nível Médio/Intermediário)

--Selecione o id_conta e o saldo de todas as contas que estão 'Ativas' e possuem saldo superior a 10.000.
SELECT * FROM contas
WHERE status_conta like 'Ativa' and saldo > 10000;
--Traga todas as transações do tipo 'Compra Ação' ou 'Venda Ação' que ocorreram entre os dias '2025-10-01' e '2025-10-15'.
SELECT * FROM Transacoes
WHERE tipo_operacao IN ('Compra Ação' , 'Venda Ação')AND data_operacao BETWEEN '2026-01-20' AND '2026-01-25';

--4. Update e Delete

--Update: O cliente "Lucas Pere" decidiu mudar sua estratégia de investimentos. Atualize o perfil_risco dele para 'Moderado'.
UPDATE Clientes
SET perfil_risco = 'Moderado'
WHERE nome LIKE 'Carlos Silva';

SELECT * FROM Clientes;
--Delete: A transação 1007 foi identificada como uma fraude e estornada. Escreva o comando para excluí-la do banco de dados.

--Consulta Simples 1: A equipe de marketing quer enviar um e-mail para investidores com maior apetite a risco. 
--Escreva um SELECT que retorne o nome e o perfil_risco de todos os clientes cujo perfil seja 'Arrojado'.
SELECT nome , perfil_risco FROM clientes
WHERE perfil_risco LIKE 'Arrojado';
--Consulta Simples 2: O setor de compliance precisa auditar operações de alto valor. 
--Crie uma consulta que retorne todas as colunas da tabela Transacoes onde o valor da operação seja maior ou igual a 10.000.00.
SELECT * FROM Transacoes
WHERE valor > 10000
ORDER BY valor DESC;
--Update: Houve um erro de digitação no sistema. O cliente de id_cliente = 5 (Eduardo Silva) na verdade tem o perfil 'Moderado'. Escreva o comando para atualizar essa informação.
SELECT * FROM clientes
WHERE id_cliente = 5; --Conservador

UPDATE clientes
SET perfil_risco = 'Moderado'
WHERE id_cliente = 5
--Delete: A transação de id_transacao = 19 foi cancelada antes de ser processada. Escreva o comando para excluí-la permanentemente do banco.
SELECT * FROM Transacoes
WHERE id_transacao = 19;

DELETE FROM Transacoes
WHERE id_transacao = 19;

--Relacionamento (JOIN): A área de atendimento precisa de um relatório rápido. 
--Escreva uma consulta 
--que junte as tabelas clientes e Contas para retornar o nome do cliente, o perfil_risco e o saldo atual de suas contas, mas apenas para as contas que estão com status_conta igual a 'Ativa'.

SELECT cl.nome , cl.perfil_risco , co.saldo FROM Contas co
JOIN Clientes cl
ON cl.id_cliente = co.id_cliente
WHERE status_conta = 'Ativa'
ORDER BY saldo DESC;

--Agregação e Ordenação: A diretoria financeira quer entender o volume de dinheiro entrando e saindo. 
--Escreva uma consulta na tabela Transacoes que calcule a soma total do valor (SUM) para cada tipo_operacao (Depósito, Saque, etc.). 
--Ordene o resultado para mostrar primeiro o tipo de operação com o maior volume financeiro.
SELECT tipo_operacao , sum(valor) as total FROM Transacoes
GROUP BY tipo_operacao
ORDER BY sum(valor) DESC;

--Nível 3: Avançado (Análise Complexa e Preparação de Dados)


--Subconsulta: A corretora quer identificar transações fora do padrão. 
--Escreva uma consulta que retorne o id_transacao, o tipo_operacao e o valor das transações que possuam um valor estritamente maior que a média de todas as transações cadastradas no banco. 
--(Dica: você usará um SELECT dentro da cláusula WHERE de outro SELECT).
SELECT * FROM Transacoes
WHERE valor > 
	(SELECT avg(valor) as media FROM Transacoes)
ORDER BY valor DESC;

--View (Preparação para BI): Você precisa preparar uma base consolidada que será conectada diretamente a um dashboard no Power BI para a diretoria acompanhar a carteira. 
--Crie uma VIEW chamada vw_analise_clientes que una informações das três tabelas e retorne:
--O nome do cliente.
--O perfil_risco.
--A soma total do saldo (saldo) de todas as contas desse cliente (use o SUM).
--Atenção: O agrupamento (GROUP BY) deve ser feito corretamente pelos dados do cliente para que a soma dos saldos funcione.
CREATE VIEW vw_analise_clientes AS 
	SELECT cl.nome , cl.perfil_risco , sum(co.saldo) as valor_investido FROM Contas co
	JOIN Clientes cl
	ON cl.id_cliente = co.id_cliente
	GROUP BY cl.nome , cl.perfil_risco
	ORDER BY sum(co.saldo) DESC;

SELECT * FROM vw_analise_clientes;

--Nível 4: Desafio Analista de Dados (Pleno/Sênior)
--Cenário: O time de Inteligência de Mercado e a diretoria de Risco precisam de um levantamento profundo sobre o comportamento dos investidores 
--"baleia" (grandes movimentadores) e uma nova base consolidada para os painéis executivos.

--1. Update com Subconsulta (Regra de Negócio de Risco)
--O comitê de risco definiu uma nova regra automática: qualquer cliente que possua pelo menos uma conta com saldo estritamente superior a R$ 50.000,00 deve ter seu perfil_risco atualizado para 
--'Arrojado', independentemente de qual seja o seu perfil atual.

--A Tarefa: Escreva um comando UPDATE na tabela clientes que utilize uma subconsulta (como IN ou EXISTS) buscando os dados na tabela Contas para aplicar essa alteração.
UPDATE Clientes
SET perfil_risco = 'Arrojado'
WHERE id_cliente in (
	SELECT cl.id_cliente FROM Contas co
	JOIN Clientes cl
	ON cl.id_cliente = co.id_cliente
	WHERE co.saldo > 40000
);


--2. Consulta Analítica de Alto Impacto (JOINs + Agregação + Subconsulta)
-- corretora quer entender quem são os clientes que estão comprando ações de forma agressiva, mas usando um parâmetro dinâmico.

--A Tarefa: Escreva um SELECT que retorne o nome do cliente e a soma total do valor de suas transações (SUM), mas filtrando apenas as transações do tipo 'Compra Ação'.
SELECT cl.nome , sum(tr.valor) as total, tr.tipo_operacao FROM Transacoes tr
JOIN Contas co
ON co.id_conta = tr.id_conta
JOIN Clientes cl
ON cl.id_cliente = co.id_cliente
GROUP BY cl.nome , tr.tipo_operacao
HAVING tr.tipo_operacao LIKE 'Compra Ação' and sum(tr.valor) > (SELECT avg(valor) from transacoes)
ORDER BY sum(tr.valor) DESC;
--A Pegadinha: O resultado final (após o agrupamento) deve mostrar apenas os clientes cuja soma em 'Compra Ação' 
--seja maior do que a média geral do valor de todas as transações registradas no banco (de qualquer tipo). 
SELECT avg(valor) from transacoes
--Você precisará usar JOINs entre clientes, Contas e Transacoes, além da cláusula HAVING com uma subconsulta.


--3. View Executiva Completa (Modelagem para Dashboard)
--A diretoria precisa de uma tabela fato consolidada, pronta para ser conectada a uma ferramenta de visualização, mostrando a "temperatura" da carteira.
--A Tarefa: Crie uma VIEW chamada vw_comportamento_investidor que una as três tabelas (clientes, Contas, Transacoes) e retorne:

--O nome do cliente.
--O perfil_risco.
--A quantidade total de operações que esse cliente já realizou (use COUNT).
--O valor da maior transação isolada que ele já fez (use MAX(valor)).
--Ordene a View (se o banco permitir) ou descreva como ordenaria o SELECT da View para mostrar no topo os clientes com o maior número de operações.
CREATE VIEW vw_comportamento_investidor AS 
SELECT cl.nome , cl.perfil_risco , count(cl.nome) as quantidade, max(tr.valor) as maior_valor FROM Transacoes tr
JOIN Contas co
ON co.id_conta = tr.id_conta
JOIN Clientes cl
ON cl.id_cliente = co.id_cliente
GROUP BY cl.nome , cl.perfil_risco

SELECT * FROM vw_comportamento_investidor
ORDER BY maior_valor DESC;

