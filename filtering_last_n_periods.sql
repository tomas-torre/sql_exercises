-- =========================================
-- CRIAÇÃO DE TABELA DE EXEMPLO
-- =========================================

CREATE TABLE public.database_example (
    id SERIAL PRIMARY KEY,
    column_a VARCHAR(50),
    column_b VARCHAR(50),
    column_c VARCHAR(50),
    column_d NUMERIC(10,2),
    data_competencia DATE
);

-- Inserindo dados de exemplo
INSERT INTO public.database_example (column_a, column_b, column_c, column_d, data_competencia) VALUES
('A1', 'B1', 'C1', 100, '2025-08-15'),
('A1', 'B1', 'C1', 200, '2025-07-15'),
('A1', 'B1', 'C1', 150, '2024-08-15'),
('A2', 'B2', 'C2', 300, '2025-08-15'),
('A2', 'B2', 'C2', 400, '2025-07-15'),
('A2', 'B2', 'C2', 350, '2024-08-15'),
-- datas não contidas no intervalo filtrado no código a seguir
('A1', 'B1', 'C1', 100, '2025-06-15'),
('A1', 'B1', 'C1', 200, '2025-06-15'),
('A1', 'B1', 'C1', 150, '2024-05-15'),
('A2', 'B2', 'C2', 300, '2025-05-15'),
('A2', 'B2', 'C2', 400, '2025-04-15'),
('A2', 'B2', 'C2', 350, '2024-04-15');

-- =========================================
-- SELECT COM AGRUPAMENTO E FILTRO POR DATAS
-- =========================================
-- SEM CTE 
select
	column_a,
	column_b,
	column_c,
	SUM(column_d) as sum,
	TO_CHAR(data_competencia, 'YYYYMM') as anomes
	-- Formata a data como AAAAMM 
from public.database_example
where 1=1
and 
	data_competencia in (
	(select MAX(data_competencia) from public.database_example),
	(select MAX(data_competencia) - interval '1 month' from public.database_example),
	(select MAX(data_competencia) - interval '12 month' from public.database_example) 
	)
group by column_a, column_b, column_c, anomes
order by column_a, column_b, column_c,anomes

-- CTE para calcular a data máxima
WITH max_dates AS (
    SELECT 
        MAX(data_competencia) AS max_data
    FROM public.database_example
)
SELECT 
    column_a,
    column_b,
    column_c,
    SUM(column_d) AS sum,
    TO_CHAR(data_competencia, 'YYYYMM') AS anomes  -- Formata a data como AAAAMM
FROM public.database_example, max_dates
WHERE data_competencia IN (
        max_data, 
        max_data - INTERVAL '1 month', 
        max_data - INTERVAL '12 month'
)
GROUP BY column_a, column_b, column_c, anomes
ORDER BY column_a, column_b, column_c, anomes

