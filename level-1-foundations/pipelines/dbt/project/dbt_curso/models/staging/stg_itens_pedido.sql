-- CTE: Clean raw string data, convert types to NUMERIC, and handle negative quantities
WITH select_itens_pedidos AS (
    SELECT
        -- Primary key for the order item
        id_item_pedido, 

        -- Foreign key referencing the order
        id_pedido, 

        -- Foreign key referencing the product
        id_produto, 

        -- Standardize negative or zero quantities to 0
        CASE 
            WHEN quantidade <= 0 THEN 0
            ELSE quantidade
        END AS quantidade, 

        -- Remove non-numeric characters (except decimal points), cast to NUMERIC, and replace NULLs with 0
        COALESCE(CAST(REGEXP_REPLACE(preco_unitario, '[^0-9.]', '', 'g') AS NUMERIC), 0) AS preco_unitario,

        -- Clean discount string format, cast to NUMERIC, and replace NULLs with 0
        COALESCE(CAST(REGEXP_REPLACE(desconto, '[^0-9.]', '', 'g') AS NUMERIC), 0) AS desconto 

    FROM raw.itens_pedido
)

-- Final SELECT: Add data validation flags on top of the cleaned dataset
SELECT
    *,

    -- Flag 1: Identifies invalid or missing quantities
    CASE 
        WHEN quantidade IS NULL OR quantidade <= 0 THEN 1
        ELSE 0
    END AS fl_quantidade_invalida, 

    -- Flag 2: Identifies invalid or missing unit prices
    CASE 
        WHEN preco_unitario IS NULL OR preco_unitario <= 0 THEN 1
        ELSE 0
    END AS fl_preco_invalido,  

    -- Flag 3: Identifies negative or missing discount values
    CASE 
        WHEN desconto IS NULL OR desconto < 0 THEN 1
        ELSE 0
    END AS fl_desconto_invalido

FROM select_itens_pedidos