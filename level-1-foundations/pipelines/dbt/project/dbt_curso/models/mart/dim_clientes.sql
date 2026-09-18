{{config(materialized = 'table')}}

SELECT
    id_cliente, 
    nome_completo, 
    email, 
    cidade, 
    estado
FROM {{ref('stg_clientes')}}