SELECT
    id_cliente,
    TRIM(nome_completo) AS nome_completo, -- removing spaces from the name
    CASE
        WHEN TRIM(email) = '' THEN NULL -- if email is empty, set it to NULL
        ELSE LOWER(TRIM(email)) -- convert email to lowercase and remove spaces
    END AS email,
    CAST(data_cadastro AS DATE) AS data_cadastro, -- converting to date format
    TRIM(cidade) AS cidade, -- removing spaces from the city
    UPPER(TRIM(estado)) AS estado, -- converting state to uppercase and removing spaces
    CASE
        WHEN(email IS NULL OR email = '') THEN 1
        ELSE 0
    END AS fl_email_nulo -- flagging invalid emails
FROM
   raw.clientes