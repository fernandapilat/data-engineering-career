{{config(materialized='table')}}

SELECT DISTINCT
    sm.status AS status,
    sm.descricao AS descricao
FROM {{ref('fct_pedidos')}} p
LEFT JOIN {{ref('status_mapeamento')}} sm
ON p.status = sm.status