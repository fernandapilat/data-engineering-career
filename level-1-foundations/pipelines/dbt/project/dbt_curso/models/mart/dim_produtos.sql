{{config(materialized = 'table')}}

SELECT
    id_produto, 
    nome_produto, 
    categoria, 
    preco_unitario,
    ativo   
FROM {{ref('stg_produtos')}}