-- 6. Инструкция SELECT, использующая предикат сравнения с квантором. 
-- самые опытные сотрудники из первых 40 отделов

SELECT first_name, second_name, experience, department_id 
FROM workers 
WHERE experience >= ALL ( SELECT experience 
 FROM workers
 WHERE department_id <= 40) 
 and department_id <= 40