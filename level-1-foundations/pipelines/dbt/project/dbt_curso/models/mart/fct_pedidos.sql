{{config(materialized = 'table')}}

SELECT
    id_pedido, 
    id_cliente, 
    data_pedido, 
    status,
    valor_bruto_total,
    valor_liquido_total
FROM {{ref('int_pedidos')}} 