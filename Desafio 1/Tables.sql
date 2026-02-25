CREATE SCHEMA Desafios_Gemini;

USE Desafios_Gemini;

--Clientes: id_cliente (Chave Primária), nome, perfil_risco (Conservador, Moderado, Arrojado).
CREATE TABLE clientes (
	id_cliente SERIAL PRIMARY KEY ,
	nome VARCHAR(50) NOT NULL ,
	perfil_risco VARCHAR(30) NOT NULL
);

--Contas: id_conta (Chave Primária), id_cliente (Chave Estrangeira), saldo, status_conta (Ativa, Inativa).
CREATE TABLE Contas (
	id_conta SERIAL PRIMARY KEY ,
	saldo DECIMAL(10,2) NOT NULL ,
	status_conta VARCHAR(30) NOT NULL ,
	id_cliente INTEGER , 
	FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente)
);

--Transacoes: id_transacao (Chave Primária), id_conta (Chave Estrangeira), tipo_operacao (Depósito, Saque, Compra Ação, Venda Ação), valor, data_operacao.
CREATE TABLE Transacoes (
	id_transacao SERIAL PRIMARY KEY , 
	id_conta INTEGER , 
	tipo_operacao VARCHAR(30) NOT NULL ,
	valor DECIMAL(10,2) NOT NULL ,
	data_operacao DATE DEFAULT current_date  ,
	FOREIGN KEY (id_conta) REFERENCES Contas (id_conta)
);