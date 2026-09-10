-- Script 02: carga dos CSVs na camada RAW
-- Ajuste o caminho abaixo conforme a pasta onde você salvou os arquivos CSV.
-- Exemplo Windows usado no curso: C:/curso_dbt/dados/clientes.csv

TRUNCATE TABLE raw.itens_pedido, raw.pedidos, raw.produtos, raw.clientes;

COPY raw.clientes(id_cliente, nome_completo, email, data_cadastro, cidade, estado)
FROM 'D:\dbt\dados/clientes.csv'
DELIMITER ',' CSV HEADER;

COPY raw.produtos(id_produto, nome_produto, categoria, preco_unitario, ativo)
FROM 'D:\dbt\dados/produtos.csv'
DELIMITER ',' CSV HEADER;

COPY raw.pedidos(id_pedido, id_cliente, data_pedido, status, forma_pagamento)
FROM 'D:\dbt\dados/pedidos.csv'
DELIMITER ',' CSV HEADER;

COPY raw.itens_pedido(id_item_pedido, id_pedido, id_produto, quantidade, preco_unitario, desconto)
FROM 'D:\dbt\dados/itens_pedido.csv'
DELIMITER ',' CSV HEADER;
