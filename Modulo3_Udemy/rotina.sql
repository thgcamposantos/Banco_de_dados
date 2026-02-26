--☀️ 08:30 – Conferir total de clientes ativos
select count(id_conta) from Contas
WHERE status_conta LIKE 'Ativa';

--☀️ 09:00 – Ver clientes com saldo acima de 30 mil
CREATE VIEW nome_saldo AS
	SELECT cl.nome , co.saldo , co.status_conta FROM Contas co
	JOIN clientes cl
	ON cl.id_cliente = co.id_cliente
	--WHERE co.saldo > 30000
	ORDER BY co.saldo DESC;

--☀️ 10:00 – Calcular patrimônio total por cliente
select nome , sum(saldo) AS Patrimonio from nome_saldo
WHERE status_conta LIKE 'Ativa'
GROUP BY nome
ORDER BY sum(saldo) DESC;

--☀️ 11:00 – Identificar clientes com perfil incompatível com o risco do produto
--(Regra: Conservador não pode investir em risco Alto)

SELECT cl.nome ,  cl.perfil_risco , pr.risco FROM Produtos pr
JOIN Investimentos inv
ON inv.id_produto = pr.id_produto
JOIN Contas co
ON co.id_conta = inv.id_conta
JOIN Clientes cl
ON cl.id_cliente = co.id_cliente
WHERE perfil_risco LIKE 'Conservador' AND risco = 'Alta';

--🍽 13:30 – Atualizar perfil de cliente para Arrojado com saldo alto (valor = 100000)
UPDATE clientes 
SET perfil_risco = 'Arrojado' 
WHERE id_cliente in ( SELECT id_cliente FROM Contas
WHERE saldo > 10000)
;

--📊 📉 15:30 – Ver volume de transações do mês
select case when extract(month from data_transacao) = 2 then 'Fevereiro'
			 when extract(month from data_transacao) = 3 then 'Março'
			 when extract(month from data_transacao) = 4 then 'Abril'
		end as data_transacao , sum(valor) as total
from transacoes
group by extract(month from data_transacao)
order by sum(valor) desc;

select * from transacoes;

--🚨 16:30 – Detectar contas bloqueadas (Bloqueada) com saldo alto (valor > 10000)
select nome from clientes
where id_cliente = (select id_cliente from contas
where saldo > 10000 and status_conta like 'Bloqueada'
);