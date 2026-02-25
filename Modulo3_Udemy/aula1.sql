--Você mal abriu o e-mail e o time de Marketing pede uma lista urgente para uma campanha de reativação. 
--Eles querem enviar um e-mail oferecendo taxa zero na primeira operação para clientes que abriram a conta, mas não colocaram dinheiro.
--Sua Tarefa (SELECT): Escreva uma consulta que retorne o nome do cliente, o perfil_risco e o saldo da conta. 
--O filtro deve trazer apenas clientes que possuem a conta com o status_conta igual a 'Ativa', mas cujo saldo seja exatamente inferior a 10.000.
CREATE VIEW clientes_inferior_dez_mil as 
	SELECT cl.id_cliente , cl.nome , cl.perfil_risco , co.status_conta ,  co.saldo from Contas co 
	JOIN Clientes cl
	ON cl.id_cliente = co.id_cliente
	WHERE co.status_conta LIKE 'Inativa' AND co.saldo < 10000
	ORDER BY co.saldo DESC;

--Após o almoço, o time de Operações abre um chamado. 
--Eles perceberam que o sistema falhou ao inativar contas antigas e pedem que você faça essa correção via banco de dados para evitar inconsistências nos relatórios de amanhã.
--Sua Tarefa (UPDATE): Escreva um comando para atualizar o status_conta para 'Inativa'. Essa atualização deve ser aplicada em todas as contas que atualmente possuem o saldo inferior a 10.000.
UPDATE Contas
SET status_conta = 'Inativa'
WHERE id_cliente in (
	SELECT id_cliente FROM clientes_inferior_dez_mil
);

--16:30 - Preparação de Dados para o Dashboard Financeiro
--O analista sênior está montando um novo painel gerencial e pediu para você preparar a base de dados que vai alimentar os gráficos de fluxo de caixa (entradas e saídas simples). 
--Ele precisa de uma visão limpa e sumarizada.
--Sua Tarefa (Agregação + CASE WHEN): Escreva uma consulta que retorne o nome do cliente e crie duas novas colunas calculadas.
--A primeira coluna deve se chamar total_depositado, contendo a soma dos valores apenas onde o tipo de operação for 'Depósito'.
--A segunda coluna deve se chamar total_sacado, contendo a soma dos valores apenas onde o tipo de operação for 'Saque'.
--Agrupe o resultado pelo nome do cliente.
--(Dica de ouro para o dia a dia: você vai precisar combinar a função SUM com a estrutura CASE WHEN dentro do seu SELECT para criar essas colunas pivoteadas).
SELECT cl.nome, 
    SUM(CASE WHEN tr.tipo_operacao = 'Depósito' THEN tr.valor ELSE 0 END) AS total_depositado, 
    SUM(CASE WHEN tr.tipo_operacao = 'Saque' THEN tr.valor ELSE 0 END) AS total_sacado 
FROM Transacoes tr
JOIN Contas co 
ON co.id_conta = tr.id_conta 
JOIN Clientes cl 
ON cl.id_cliente = co.id_cliente
GROUP BY cl.nome;