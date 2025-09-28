-- =========================================
-- EXEMPLO DE TABELA: employees
-- =========================================

-- Criação da tabela com as colunas necessárias
CREATE TABLE public.employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary NUMERIC(10,2)
);

-- Inserindo dados de exemplo
INSERT INTO public.employees (first_name, last_name, department, salary) VALUES
('Alice', 'Smith', 'IT', 60000),
('Bob', 'Johnson', 'IT', 45000),
('Carol', 'Davis', 'HR', 55000),
('David', 'Miller', 'HR', 70000),
('Eva', 'Brown', 'Finance', 80000),
('Frank', 'Wilson', 'Finance', 30000),
('Grace', 'Lee', 'Marketing', 52000),
('Henry', 'Taylor', 'Marketing', 48000);


select * from public.employees e order by salary desc

-- =========================================
-- WHERE clause
-- =========================================
/*
- Filtra as linhas antes de qualquer agregação.
- Ex.: Filtra salários maiores que 50000 antes de agrupar ou agregar os dados.
*/
SELECT department, AVG(salary) AS avg_salary
FROM public.employees
WHERE salary > 50000
GROUP BY department;

-- =========================================
-- HAVING clause
-- =========================================
/*
- Filtra os grupos após a aplicação de agregações.
- Ex.: Filtra grupos de departamentos onde a média de salário é maior que 50000. 
*/
SELECT department, AVG(salary) AS avg_salary
FROM public.employees
GROUP BY department
HAVING AVG(salary) > 50000;

-- =========================================
-- MIX DE WHERE E HAVING
-- =========================================
/*
- Retorna departamentos cujo total de salários (somados para cada departamento) 
  é maior que 20.000, considerando apenas funcionários que ganham mais de 50.000.
*/
SELECT department, SUM(salary) AS total_salary
FROM public.employees
WHERE salary > 50000  -- 1º Executa: Filtra linhas individuais
GROUP BY department    -- 2º Executa: Agrupa as linhas filtradas
HAVING SUM(salary) > 20000;  -- 3º Executa: Filtra os grupos após a agregação
