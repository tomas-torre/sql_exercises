-- =========================================
-- Cálculo de valores anteriores, próximos
-- e médias móveis em PostgreSQL
-- =========================================

-- Create table and test it
CREATE TABLE sales_portfolio.numbers AS
SELECT generate_series(1, 100) AS num;

select * from sales_portfolio.numbers 

-- Cria uma CTE para calcular os valores vizinhos
WITH numeros_cte AS (
    SELECT
        num,
        -- LAG: valor da linha anterior em relação à ordenação por 'num'
        LAG(num) OVER (ORDER BY num) AS num_anterior,
        -- LEAD: valor da próxima linha em relação à ordenação por 'num'
        LEAD(num) OVER (ORDER BY num) AS num_proximo
    FROM sales_portfolio.numbers
)
SELECT
    num,                       -- valor atual
    num_anterior,              -- valor da linha anterior
    num_proximo,               -- valor da próxima linha
    -- Média móvel centrada em 3 elementos: linha anterior, atual e próxima
    ROUND(
        AVG(num) OVER (
            ORDER BY num
            ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
        ), 2
    ) AS media_movel_3_1,
    -- Média móvel acumulada de 3 elementos: linha atual + 2 anteriores
    ROUND(
        AVG(num) OVER (
            ORDER BY num
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS media_movel_3_2
FROM numeros_cte
ORDER BY num;  -- ordena o resultado final
