-- 2. Инструкция SELECT, использующая предикат BETWEEN.  
-- название и численность отделов для: отделов, у которых доход между 1.000.000 и 100.000.000
SELECT department_name, department_size
FROM departments
WHERE income BETWEEN 1000000 AND 100000000
ORDER BY department_size ASC 