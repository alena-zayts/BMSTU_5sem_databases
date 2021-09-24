-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER() 

select department_name, department_size, income, avg(income) over (partition by department_size) as avg_income
from departments
