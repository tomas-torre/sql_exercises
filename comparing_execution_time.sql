-- =========================================
-- SCRIPT DE COMPARAÇÃO DE TEMPO DE EXECUÇÃO
-- POSTGRESQL
-- Este script compara duas formas de medir performance de uma query:
-- •  EXPLAIN + ANALYZE (retorna plano detalhado e Execution Time)
-- •  clock_timestamp() (mede tempo total de execução da query)
-- =========================================

-- =========================================
-- 1️) EXPLAIN + ANALYZE
-- • Documentação: https://www.postgresql.org/docs/current/sql-explain.html
-- • Esta abordagem mostra o plano de execução completo e os tempos de cada etapa.
-- • Boa para identificar gargalos e otimizações.
-- =========================================
EXPLAIN (ANALYZE, TIMING ON, SUMMARY ON, FORMAT TEXT)
-- ====== QUERY START ====== 
SELECT
    pessoa,
    ROUND(SUM(minutes_played)::numeric, 2) AS total
FROM spotify.hist_streaming hs
WHERE pessoa = 'tomas'
GROUP BY pessoa
ORDER BY total DESC;
-- ====== QUERY END ====== 

-- =========================================
-- 2️) MEDIÇÃO COM CLOCK_TIMESTAMP()
-- • Esta abordagem mede o tempo total de execução da query usando timestamps antes e depois.
-- • Ideal para benchmarks rápidos ou comparação de tempo entre queries.
-- • Não fornece detalhes de plano de execução.
-- =========================================
DO $$
DECLARE
 t_start TIMESTAMP;
 t_end TIMESTAMP;
BEGIN
 t_start := clock_timestamp();
 -- -- ====== QUERY START ====== 
 PERFORM ROUND(SUM(minutes_played)::numeric,2)
 FROM spotify.hist_streaming
 WHERE pessoa='tomas'
 GROUP BY pessoa;
-- ====== QUERY END ====== 
 t_end := clock_timestamp();
 RAISE NOTICE 'Execution time: % ms', EXTRACT(EPOCH FROM (t_end - t_start)) * 1000;
END;
$$;


-- =========================================
-- ANÁLISE COMPARATIVA
-- Resultados observados:
-- • EXPLAIN + ANALYZE: Execution Time ~118.134 ms
-- • clock_timestamp(): Execution time ~116.245 ms
--
-- VANTAGENS X DESVANTAGENS
-- • Diferença de tempo, nesse caso, é normal e aceitável.
-- • EXPLAIN + ANALYZE inclui o custo real de cada etapa do plano (scan, agregação, sort, paralelismo), portanto tende a ser ligeiramente maior.
-- • clock_timestamp() mede apenas o tempo total decorrido, sem detalhar etapas internas.
-- • Para análise detalhada e otimização, EXPLAIN + ANALYZE é preferível.
-- • Para benchmarks rápidos ou comparações entre queries, clock_timestamp() é mais simples e rápido.
-- =========================================
