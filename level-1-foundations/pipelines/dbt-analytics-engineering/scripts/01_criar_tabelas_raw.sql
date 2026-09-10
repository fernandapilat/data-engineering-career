-- 5854 - Engenharia de dados Dbt - Transformações modernas de dados
-- Script 01: criação do schema e tabelas RAW no PostgreSQL
-- Versão com nomes de tabelas e campos em português

DROP SCHEMA IF EXISTS raw CASCADE;
CREATE SCHEMA raw;

CREATE TABLE raw.clientes (
    id_cliente INTEGER,
    nome_completo VARCHAR(120),
    email VARCHAR(160),
    data_cadastro VARCHAR(30),
    cidade VARCHAR(80),
    estado VARCHAR(30)
);

CREATE TABLE raw.produtos (
    id_produto INTEGER,
    nome_produto VARCHAR(160),
    categoria VARCHAR(80),
    preco_unitario VARCHAR(30),
    ativo VARCHAR(10)
);

CREATE TABLE raw.pedidos (
    id_pedido INTEGER,
    id_cliente INTEGER,
    data_pedido VARCHAR(30),
    status VARCHAR(30),
    forma_pagamento VARCHAR(30)
);

CREATE TABLE raw.itens_pedido (
    id_item_pedido INTEGER,
    id_pedido INTEGER,
    id_produto INTEGER,
    quantidade INTEGER,
    preco_unitario VARCHAR(30),
    desconto VARCHAR(30)
);
