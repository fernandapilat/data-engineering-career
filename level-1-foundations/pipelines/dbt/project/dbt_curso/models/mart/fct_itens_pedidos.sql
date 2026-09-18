{{config(materialized = 'table')}}


SELECT
    id_pedido, 
    id_cliente, 
    data_pedido, 
    id_produto,
    quantidade,
    preco_unitario,
    desconto,
    valor_bruto,
    valor_liquido
FROM {{ref('int_pedidos_itens_pedido')}}