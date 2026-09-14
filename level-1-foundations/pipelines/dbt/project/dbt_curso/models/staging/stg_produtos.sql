WITH select_produtos AS(	
	SELECT    
	    id_produto,
	    TRIM(nome_produto) AS nome_produto, -- removing spaces from the product name
	    UPPER(TRIM(categoria)) AS categoria, -- converting category to uppercase and removing spaces
	    CAST(TRIM(REPLACE(LOWER(TRIM(preco_unitario)), 'r$', '')) AS NUMERIC) AS preco_unitario, -- converting to numeric format
	    CASE
	        WHEN LOWER(TRIM(ativo)) IN ('true', '1', 'yes', 's', 'sim') THEN TRUE -- converting to boolean
	        WHEN LOWER(TRIM(ativo)) IN ('false', '0', 'no', 'n', 'nao', 'não') THEN FALSE -- converting to boolean
	    ELSE FALSE -- defaulting to FALSE for any other values
	    END AS ativo
	FROM raw.produtos
)
SELECT id_produto, nome_produto, categoria,
CASE 
	WHEN preco_unitario IS NULL THEN 0
ELSE preco_unitario
END AS preco_unitario, ativo
FROM select_produtos