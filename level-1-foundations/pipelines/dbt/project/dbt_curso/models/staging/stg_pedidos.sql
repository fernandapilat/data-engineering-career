SELECT
    -- Primary identifier for the order
    id_pedido, 

    -- Foreign key referencing the customer
    id_cliente, 

    -- Standardize inconsistent date string formats into DATE, falling back to a default value if invalid
    COALESCE(
        CASE
            -- Handles standard YYYY-MM-DD format
            WHEN data_pedido ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(data_pedido, 'YYYY-MM-DD')
            -- Handles non-standard DD-MM-YYYY format
            WHEN data_pedido ~ '^\d{4}-\d{2}-\d{4}$' THEN TO_DATE(data_pedido, 'DD-MM-YYYY')
            -- Returns NULL if format is unrecognizable
            ELSE NULL
        END, 
        DATE '1900-01-01'
    ) AS data_pedido, 

    -- Clean, normalize, and fill missing order statuses to maintain referential integrity
    CASE
        -- Handle missing or empty status values
        WHEN status IS NULL OR TRIM(status) = '' THEN 'undefined'
        -- Standardize spelling variations for canceled orders
        WHEN LOWER(TRIM(status)) IN ('cancelled', 'canceled') THEN 'canceled'
        -- Standardize spelling variations for completed orders
        WHEN LOWER(TRIM(status)) IN ('completed', 'complete') THEN 'completed'      
        -- Normalize remaining status values to lower case
        ELSE LOWER(TRIM(status))
    END AS status, 

    -- Clean, normalize, and fill missing payment method values
    CASE        
        -- Handle missing or empty payment method values
        WHEN forma_pagamento IS NULL OR TRIM(forma_pagamento) = '' THEN 'undefined'
        -- Normalize remaining payment method values to lower case
        ELSE LOWER(TRIM(forma_pagamento))
    END AS forma_pagamento

-- Source raw table in the staging pipeline (no trailing semicolon for dbt compilation)
FROM raw.pedidos