-- QUERY PRINCIPAL DO EXERCÍCIO
-- USA CTE + LAG + WINDOW FUNCTION + TRANSFORMAÇÃO DE TIPO DE DADO
WITH vendas_cte AS (
    SELECT 
        data_venda,
        valor_venda,
        LAG(valor_venda) OVER (ORDER BY data_venda) AS venda_dia_anterior
    FROM exercises.sales_estoque
)
SELECT
    data_venda,
    valor_venda,
    venda_dia_anterior,
    valor_venda - venda_dia_anterior AS diferenca_com_dia_anterior,
    CASE
        WHEN venda_dia_anterior IS NULL THEN NULL
        ELSE ((valor_venda::NUMERIC - venda_dia_anterior::NUMERIC) 
               / venda_dia_anterior::NUMERIC)
    END AS variacao_percentual
FROM vendas_cte
ORDER BY data_venda