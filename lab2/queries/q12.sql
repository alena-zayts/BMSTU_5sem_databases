-- 12. Инструкция SELECT, использующая вложенные коррелированные
-- подзапросы в качестве производных таблиц в предложении FROM
--  rich and experienced 

SELECT second_name, experience, department_size, income
FROM workers JOIN 
    (
    SELECT department_id, department_size, income
    FROM departments 
    WHERE department_size < 3
    INTERSECT
    SELECT department_id, department_size, income
    FROM departments 
    WHERE income > 100000000
    ) AS rich_and_small_dep ON workers.department_id = rich_and_small_dep.department_id
WHERE experience > 10