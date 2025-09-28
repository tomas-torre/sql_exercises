SELECT ROUND(CAST("Vendas" AS numeric), 2) AS sales
FROM sales_portfolio.f_sales 
ORDER BY "Vendas" desc

WITH limites AS (
    SELECT
        PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY "Vendas") AS p10,
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY "Vendas") AS p90
    FROM sales_portfolio.f_sales
)
SELECT ROUND(AVG("Vendas")::numeric, 2) AS trimmed_mean
FROM sales_portfolio.f_sales f
JOIN limites l
  ON f."Vendas" >= l.p10
 AND f."Vendas" <= l.p90;


SELECT ROUND(AVG("Vendas")::numeric, 2) AS trimmed_mean
FROM (
    SELECT "Vendas",
           percent_rank() OVER (ORDER BY "Vendas") AS pr
    FROM sales_portfolio.f_sales
) t
WHERE pr >= 0.10
  AND pr <= 0.90;


WITH limites AS (
    SELECT
        PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY "Vendas") AS p10,
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY "Vendas") AS p90
    FROM sales_portfolio.f_sales
)
SELECT
    ROUND(AVG("Vendas")::numeric, 2) AS media_aparada
FROM sales_portfolio.f_sales
JOIN limites l
  ON "Vendas" > l.p10
 AND "Vendas" < l.p90;


SELECT
    ROUND(AVG("Vendas")::numeric, 2) AS media_aparada
FROM sales_portfolio.f_sales
WHERE "Vendas" > (
        SELECT PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY "Vendas")
        FROM sales_portfolio.f_sales
    )
  AND "Vendas" < (
        SELECT PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY "Vendas")
        FROM sales_portfolio.f_sales
    );

CREATE TABLE sales_portfolio.numbers AS
SELECT generate_series(1, 100) AS num;

select * from sales_portfolio.numbers 

SELECT
    ROUND(AVG(num), 2) AS media_aparada
FROM sales_portfolio.numbers 
WHERE num > (
        SELECT PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY num)
        FROM sales_portfolio.numbers 
    )
  AND num < (
        SELECT PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY num)
        FROM sales_portfolio.numbers 
    );


-- Calcula média aparada usando PERCENTILE_CONT para definir limites
WITH 
-- 1 Calcula o valor do percentil 10%
p10 AS (
    SELECT 
        PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY num) AS val_p10
    FROM sales_portfolio.numbers),
-- 2 Calcula o valor do percentil 90%
p90 AS (
    SELECT 
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY num) AS val_p90
    FROM sales_portfolio.numbers)
-- 3️ Filtra os valores entre P10 e P90 e calcula a média
SELECT 
    ROUND(AVG(num), 2) AS media_aparada
FROM sales_portfolio.numbers
WHERE num > (SELECT val_p10 FROM p10)   -- Maior que o limite inferior (P10)
  AND num < (SELECT val_p90 FROM p90);  -- Menor que o limite superior (P90)




WITH ordenados AS (
    SELECT
        num,
        ROW_NUMBER() OVER (ORDER BY num) AS posicao,
        COUNT(*) OVER () AS total
    FROM sales_portfolio.numbers
),
limites AS (
    SELECT
        -- posição correspondente ao percentil 10%
        0.10 * total::int AS pos_min,
        -- posição correspondente ao percentil 90%
        0.90 * total::int AS pos_max
    FROM ordenados
    LIMIT 1
)
SELECT
    ROUND(AVG(num), 2) AS media_aparada
FROM ordenados, limites
WHERE posicao > pos_min
  AND posicao < pos_max;  





-- Calcula a média aparada (trimmed mean) sem usar PERCENTILE_CONT
WITH 
-- 1️ Conta o total de linhas na tabela
stats AS (
    SELECT COUNT(*) AS total 
    FROM sales_portfolio.numbers
),
-- 2️ Ordena os números e atribui posição sequencial
ordenados AS (
    SELECT 
        num, 
        ROW_NUMBER() OVER (ORDER BY num) AS pos
    FROM sales_portfolio.numbers
),
-- 3️ Prepara dados para o cálculo do percentil 10%
p10 AS (
    SELECT
        num AS num_low,                                           -- Valor na posição atual
        LEAD(num) OVER (ORDER BY pos) AS num_high,                -- Valor da próxima posição (para interpolar)
        (0.10 * (s.total - 1) + 1) AS pos_exata,                   -- Posição real do percentil 10%
        pos                                                        -- Posição inteira atual
    FROM ordenados o
    CROSS JOIN stats s                                             -- Junta o total de linhas a cada registro
),
-- 4️ Prepara dados para o cálculo do percentil 90%
p90 AS (
    SELECT
        num AS num_low,                                           -- Valor na posição atual
        LEAD(num) OVER (ORDER BY pos) AS num_high,                -- Valor da próxima posição
        (0.90 * (s.total - 1) + 1) AS pos_exata,                   -- Posição real do percentil 90%
        pos
    FROM ordenados o
    CROSS JOIN stats s
),
-- 5️Calcula o valor exato do percentil 10% usando interpolação linear
limite10 AS (
    SELECT 
        num_low + (pos_exata - pos) * (num_high - num_low) AS val -- Fórmula de interpolação
    FROM p10
    WHERE pos <= pos_exata AND pos+1 >= pos_exata -- Seleciona linha onde o corte ocorre
),
-- 6️ Calcula o valor exato do percentil 90% usando interpolação linear
limite90 AS (
    SELECT 
        num_low + (pos_exata - pos) * (num_high - num_low) AS val
    FROM p90
    WHERE pos <= pos_exata AND pos+1 >= pos_exata
)
-- 7️ Filtra os valores entre P10 e P90 e calcula a média
SELECT 
    ROUND(AVG(num), 2) AS media_aparada
FROM sales_portfolio.numbers
WHERE num > 
(SELECT val FROM limite10)
  AND num < (SELECT val FROM limite90)