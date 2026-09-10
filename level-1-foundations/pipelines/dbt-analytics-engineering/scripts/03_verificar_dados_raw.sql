-- Script 03: consultas iniciais para demonstrar problemas nos dados brutos
-- Estas consultas apenas identificam problemas. A correção será feita depois com dbt.

SELECT 'clientes' AS tabela, COUNT(*) AS total_registros FROM raw.clientes
UNION ALL SELECT 'produtos', COUNT(*) FROM raw.produtos
UNION ALL SELECT 'pedidos', COUNT(*) FROM raw.pedidos
UNION ALL SELECT 'itens_pedido', COUNT(*) FROM raw.itens_pedido;

SELECT email, COUNT(*) AS total
FROM raw.clientes
GROUP BY email
HAVING COUNT(*) > 1 OR email IS NULL OR email = '';

SELECT 'clientes' AS tabela, id_cliente AS id_registro, data_cadastro AS data_original
FROM raw.clientes
WHERE data_cadastro NOT LIKE '____-__-__'
UNION ALL
SELECT 'pedidos', id_pedido, data_pedido
FROM raw.pedidos
WHERE data_pedido NOT LIKE '____-__-__';

SELECT status, COUNT(*) AS total
FROM raw.pedidos
GROUP BY status
ORDER BY status;

SELECT id_produto, nome_produto, preco_unitario
FROM raw.produtos
WHERE preco_unitario LIKE 'R$%' OR preco_unitario IS NULL OR preco_unitario = '';

SELECT id_item_pedido, id_pedido, id_produto, preco_unitario, desconto
FROM raw.itens_pedido
WHERE preco_unitario LIKE 'R$%'
   OR preco_unitario IS NULL
   OR preco_unitario = ''
   OR desconto LIKE '-%';

SELECT p.*
FROM raw.pedidos p
LEFT JOIN raw.clientes c ON p.id_cliente = c.id_cliente
WHERE c.id_cliente IS NULL;

SELECT ip.*
FROM raw.itens_pedido ip
LEFT JOIN raw.produtos pr ON ip.id_produto = pr.id_produto
WHERE pr.id_produto IS NULL;

SELECT ip.*
FROM raw.itens_pedido ip
LEFT JOIN raw.pedidos p ON ip.id_pedido = p.id_pedido
WHERE p.id_pedido IS NULL;

SELECT 'pedidos' AS tabela, id_pedido AS id_duplicado, COUNT(*) AS total
FROM raw.pedidos
GROUP BY id_pedido
HAVING COUNT(*) > 1
UNION ALL
SELECT 'itens_pedido', id_item_pedido, COUNT(*)
FROM raw.itens_pedido
GROUP BY id_item_pedido
HAVING COUNT(*) > 1;

SELECT *
FROM raw.itens_pedido
WHERE quantidade IS NULL OR quantidade <= 0;
