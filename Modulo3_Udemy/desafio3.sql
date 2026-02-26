--08:40 – Auditoria rápida do sistema
--📌 O gestor pede:
--Quantas contas estão:
--Ativas / Bloqueadas
--Mostrar o percentual de cada uma sobre o total.
SELECT status_conta , count(status_conta) , round(cast(count(status_conta) as decimal) / (Select count(status_conta) from Contas) * 100 , 2) from Contas
GROUP BY status_conta;

--☀️ 09:15 – Relatório de captação
--📌 O time financeiro quer:
--Valor total depositado
--Valor total sacado
--Saldo líquido movimentado (depósitos – saques)
select 
	sum(case when tipo_transacao = 'Deposito' then valor else 0 end) as Deposito ,  
	sum(case when tipo_transacao = 'Saque' then valor else 0 end) as Saque  , 
	(sum(case when tipo_transacao = 'Deposito' then valor else 0 end))  - (sum(case when tipo_transacao = 'Saque' then valor else 0 end)) as Saldo_líquido
from Transacoes;

select tipo_transacao , sum(valor) as total from transacoes
where tipo_transacao LIKE 'Deposito'
GROUP BY tipo_transacao;

--☀️ 10:00 – Clientes inativos financeiramente
--📌 A área de CRM quer:
--Clientes que NÃO fizeram nenhuma transação
--Mostrar nome, cidade e saldo atual
--(Desafio: usar NOT EXISTS ou LEFT JOIN corretamente)
Select cl.id_cliente , cl.nome , sum(tr.valor) as investido from Transacoes tr
JOIN Contas co
ON co.id_conta = tr.id_conta
RIGHT JOIN Clientes cl
ON cl.id_cliente = co.id_cliente
GROUP BY cl.id_cliente , cl.nome
HAVING sum(tr.valor) is null
ORDER BY cl.id_cliente;

--☀️ 11:00 – Ticket médio por investimento
--📌 O gestor de produtos quer saber:
--Qual o valor médio investido por produto
--Ordenar do maior para o menor
select pr.nome_produto , count(pr.nome_produto) as quantidade , sum(inv.valor_investido) as total , round(avg(inv.valor_investido), 2) as media from investimentos inv
join produtos pr
on pr.id_produto = inv.id_produto
group by pr.nome_produto
order by avg(inv.valor_investido) desc;

--📊 14:30 – Ranking de clientes
--📌 O CEO quer:
--Top 3 clientes com maior patrimônio total
--Patrimônio = saldo + investimentos
select cl.nome , sum(inv.valor_investido) as investido , sum(co.saldo) as saldo_bancario , (sum(inv.valor_investido) + sum(co.saldo)) as patrimonio from investimentos inv
join contas co
on co.id_conta = inv.id_conta
join clientes cl
on cl.id_cliente = co.id_cliente
group by cl.nome
order by patrimonio desc
limit 3;

--🔄 17:30 – Preparação para BI
--📌 Criar uma VIEW consolidada contendo:
--Nome do cliente
--Cidade
--Perfil de risco
--Saldo
--Total investido
--Patrimônio total
--Quantidade de investimentos
CREATE VIEW relatorio_cliente as 
	select cl.nome , cl.cidade , cl.perfil_risco , sum(co.saldo) as saldo_bancario , sum(inv.valor_investido) as investido , (sum(inv.valor_investido) + sum(co.saldo)) as patrimonio , count(inv.id_investimento) as quantidade from investimentos inv
	join contas co
	on co.id_conta = inv.id_conta
	join clientes cl
	on cl.id_cliente = co.id_cliente
	group by cl.nome , cl.cidade , cl.perfil_risco
	order by patrimonio desc;

select * from relatorio_cliente

--🚨 16:30 – Análise de inconsistência
--📌 A auditoria detectou possível erro:
--Encontrar contas onde:
--O total investido é maior que o saldo disponível
--Mostrar:
--Nome
--Saldo
--Total investido
select nome , (sum(saldo_bancario)) - (sum(investido)) as diferenca from relatorio_cliente
group by nome
having (sum(saldo_bancario)) - (sum(investido)) < 0;