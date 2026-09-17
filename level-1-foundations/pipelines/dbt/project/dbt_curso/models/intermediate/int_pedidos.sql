SELECT 
    -- Dimensional attributes at the order level
    id_pedido, 
    id_cliente, 
    data_pedido, 
    status,

    -- Aggregated financial metrics calculated from line items
    SUM(valor_bruto) AS valor_bruto_total,
    SUM(valor_liquido) AS valor_liquido_total

-- Reference to the intermediate model that contains item-level metrics
FROM {{ ref('int_pedidos_itens_pedido') }}

-- Group by all non-aggregated dimensional columns to compute order totals
GROUP BY 
    id_pedido, 
    id_cliente, 
    data_pedido, 
    status