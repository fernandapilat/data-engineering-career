SELECT
    -- Order level attributes from stg_pedidos
    p.id_pedido,
    p.id_cliente,
    p.data_pedido,
    p.status,

    -- Item level attributes from stg_itens_pedido
    i.id_produto,
    i.quantidade,
    i.preco_unitario,
    i.desconto,

    -- Calculate the total value of the item (quantity * unit price)
    {{ calculo_dois_valores('i.quantidade', 'i.preco_unitario') }} AS valor_bruto,
    {{ calculo_dois_valores('i.quantidade', 'i.preco_unitario') }} - i.desconto AS valor_liquido


-- Reference the staging orders model (dbt ref macro builds the DAG dependency)
FROM {{ ref('stg_pedidos') }} p

-- Join with the staging order items model on the primary/foreign key relation
INNER JOIN {{ ref('stg_itens_pedido') }} i
    ON p.id_pedido = i.id_pedido

-- Filter out invalid data flagged during staging transformations
WHERE i.fl_quantidade_invalida = 0
  AND i.fl_preco_invalido = 0