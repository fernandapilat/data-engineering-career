{{ config(
    materialized='table'
) }}

SELECT * FROM raw.clientes