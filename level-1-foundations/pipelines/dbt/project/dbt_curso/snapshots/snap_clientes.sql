{% snapshot snap_clientes %}

    {{
        config(
            target_schema='snapshots',
            unique_key='id_cliente',
            strategy='check',
            check_cols=['nombre', 'cidade', 'estado'],
        )
    }}

    select * from {{ ref('stg_clientes') }}

{% endsnapshot %}