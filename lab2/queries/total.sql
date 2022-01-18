drop table if exists table1;
drop table if exists table2;

create table if not exists table1
(
    id integer,
    var1 varchar(20) not null,
    valid_from_dttm date not null,
    valid_to_dttm date not null
);

INSERT INTO table1
VALUES (1, 'A', '2018-09-01', '2018-09-15');

INSERT INTO table1
VALUES (1, 'B', '2018-09-16', '5999-12-31');


create table if not exists table2
(
    id integer,
    var2 varchar(20) not null,
    valid_from_dttm date not null,
    valid_to_dttm date not null
);

INSERT INTO table2
VALUES (1, 'A', '2018-09-01', '2018-09-18');

INSERT INTO table2
VALUES (1, 'B', '2018-09-19', '5999-12-31');

select * from (
    select table1.id, var1, var2,
           greatest(table1.valid_from_dttm, table2.valid_from_dttm) as valid_from_dttm,
                --case
                --    when table1.valid_from_dttm > table2.valid_from_dttm 
                --    then table1.valid_from_dttm
                --    else table2.valid_from_dttm
                --end as valid_from_dttm,
           least(table1.valid_to_dttm, table2.valid_to_dttm) as valid_to_dttm
                --case
                --    when table1.valid_to_dttm < table2.valid_to_dttm then table1.valid_to_dttm
                --    else table2.valid_to_dttm
                --    end as valid_to_dttm
        from table1 full outer join table2 on table1.id = table2.id) as result
where valid_from_dttm <= valid_to_dttm 
order by id, valid_from_dttm;
-- 1. Инструкция SELECT, использующая предикат сравнения. 
-- id запросы и количество грузчиков для: еще не выполненных запросов, для которых хватит 3 грузчиков
SELECT request_id, movers_amount
FROM requests
WHERE NOT completed AND movers_amount <= 3
ORDER BY movers_amount, request_id ASC -- 10. Инструкция SELECT, использующая поисковое выражение CASE.


SELECT worker_id, experience,
 CASE 
 WHEN experience < 10 THEN 'junior' 
 WHEN experience < 30 THEN 'middle' 
 WHEN experience < 70 THEN 'senior' 
 ELSE 'GOD' 
 END AS status 
FROM workers--11. Создание новой временной локальной таблицы из результирующего набора 

drop table if exists mix;

select office_supply_name, amount, pack_size,
	CASE (amount % pack_size)
    WHEN 0 THEN 'perfect'
    ELSE CAST((pack_size - (amount % pack_size)) AS varchar(10)) || ' left'
	END AS lefts
into mix
FROM requests JOIN office_supplies ON requests.office_supply_id = office_supplies.office_supply_id
order by lefts asc-- 12. Инструкция SELECT, использующая вложенные коррелированные
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
WHERE experience > 10-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3. 
-- большие заказы дорогих товаров от сотрудников из богатых отделов

SELECT income, amount, price
FROM ((
        SELECT office_supply_id, department_id, income, amount
        FROM (( 
                SELECT workers.worker_id, workers.department_id, departments.income
                FROM (workers JOIN departments ON workers.department_id = departments.department_id) 
                WHERE income > 10000000
        ) AS  from_rich_department
        JOIN requests ON requests.worker_id = from_rich_department.worker_id)
        WHERE requests.amount > 200
    ) AS from_rich_and_a_lot
    join office_supplies ON office_supplies.office_supply_id = from_rich_and_a_lot.office_supply_id)
    WHERE price > 10000--14. Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY, но без предложения HAVING. 
-- для каждого товара получить суммарное количество заказанных единиц, количество заказов


SELECT office_supplies.office_supply_name,
sum(requests.amount) as sum_amount,
count(office_supplies.office_supply_name) as amount_of_orders,
avg(requests.amount) as counted_avg
FROM requests LEFT OUTER JOIN office_supplies ON office_supplies.office_supply_id = requests.office_supply_id 
GROUP BY requests.office_supply_id, office_supplies.office_supply_name
-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY и предложения HAVING. 
-- Получить список товаров, среднее количество заказываемых единиц которых больше 
-- общего среднего количества заказываемых единиц

SELECT office_supply_id, AVG(amount) AS average_amount
FROM requests
GROUP BY office_supply_id 
HAVING AVG(amount) > ( SELECT AVG(amount) AS common_avg_amount 
 FROM requests) 

 ( SELECT AVG(amount) AS common_avg_amount 
 FROM requests) 
 
--16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной
-- строки значений. 

INSERT INTO departments (department_name, department_size, city, income) 
VALUES ('BEST', 0, 'DreamTown', 0) ;

SELECT *
from departments-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу
-- результирующего набора данных вложенного подзапроса.
-- вставится много строк

INSERT INTO requests (worker_id, office_supply_id, amount, completed, movers_amount) 
SELECT ( SELECT MAX(worker_id) 
 FROM workers 
 WHERE experience = 0), 
 office_supply_id, 1, false, 1
FROM office_supplies
WHERE office_supply_name like '%pen'


SELECT *
from requests-- 18. Простая инструкция UPDATE. 
UPDATE requests 
SET amount = 1 
WHERE completed;

SELECT *
from requests
where completed and amount != 1--19. Инструкция UPDATE со скалярным подзапросом в предложении SET. 
UPDATE requests 
SET amount = ( SELECT AVG(amount) 
 FROM requests 
 WHERE office_supply_id between 1 and 1000) 
WHERE office_supply_id = 1000;

SELECT *
from requests
where office_supply_id = 1000-- 2. Инструкция SELECT, использующая предикат BETWEEN.  
-- название и численность отделов для: отделов, у которых доход между 1.000.000 и 100.000.000
SELECT department_name, department_size
FROM departments
WHERE income BETWEEN 1000000 AND 100000000
ORDER BY department_size ASC -- 20. Простая инструкция DELETE. 

DELETE from requests 
WHERE completed and office_supply_id = 13;


SELECT *
from requests
where completed and office_supply_id = 13;-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в
-- предложении WHERE. 

select * FROM requests
WHERE worker_id IN ( SELECT requests.worker_id 
 FROM workers LEFT OUTER JOIN requests 
 ON workers.worker_id = requests.worker_id 
 WHERE experience = 0
 AND amount > 10);
 
 
DELETE FROM requests
WHERE worker_id IN ( SELECT requests.worker_id 
 FROM workers LEFT OUTER JOIN requests 
 ON workers.worker_id = requests.worker_id 
 WHERE experience = 0
 AND amount > 10);
 
 
select * FROM requests
WHERE worker_id IN ( SELECT requests.worker_id 
 FROM workers LEFT OUTER JOIN requests 
 ON workers.worker_id = requests.worker_id 
 WHERE experience = 0
 AND amount > 10);-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение
-- канцтовары, которых заказывают больше всего
WITH office_supplies_amounts AS (
    SELECT office_supply_id, SUM(amount) AS total_amount
    FROM requests
    GROUP BY office_supply_id 
   ), top_office_supplies AS (
    SELECT office_supply_id 
    FROM office_supplies_amounts
    WHERE total_amount >= (SELECT 0.9 * max(total_amount) FROM office_supplies_amounts)
   )
SELECT office_supply_id, office_supply_name
FROM office_supplies
WHERE office_supply_id IN (SELECT office_supply_id FROM top_office_supplies);

-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.

-- Определение ОТВ
with recursive orders(office_supply_id, n) as (
 -- Определение закрепленного элемента
SELECT office_supply_id, 1 as prev_amount
 FROM office_supplies
 where office_supply_id < 10
  -- Определение рекурсивного элемента
union all 
select office_supply_id, n+1 
from orders 
where n < 5
)
-- Инструкция, использующая ОТВ
select * 
from orders-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER() 

select department_name, department_size, income, avg(income) over (partition by department_size) as avg_income
from departments
--25. Оконные фнкции для устранения дублей
--Придумать запрос, в результате которого в данных появляются полные дубли. 
--Устранить дублирующиеся строки с использованием функции ROW_NUMBER()

with duplicated as (
select * 
from workers
where experience between 10 and 30
union all
select * 
from workers
where experience between 20 and 40)
select *
from (select worker_id, second_name, experience, row_number() over (partition by worker_id) as rn 
from duplicated) dpl
where dpl.rn=1
order by experience-- 3. Инструкция SELECT, использующая предикат LIKE.
-- названия ручек и карандашей 
SELECT office_supply_name
FROM office_supplies
WHERE LOWER(office_supply_name) LIKE '%pen' OR LOWER(office_supply_name) LIKE '%pencil' -- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом. 
-- id запроса и его завершенность для: 
-- запросов, сделанных сотрудниками c опытом более 10 лет
SELECT request_id, completed
FROM requests
WHERE worker_id IN (SELECT worker_id 
 FROM workers 
 WHERE experience > 10) 
ORDER BY completed --5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом. 
-- id невыполненных заказов товаров, у которых цена меньше 1000
SELECT 
    request_id, completed
FROM 
    requests
WHERE 
    EXISTS( SELECT 
                1 
            FROM 
                office_supplies
            WHERE 
                requests.office_supply_id = office_supplies.office_supply_id and price < 1000)
     and not completed -- 6. Инструкция SELECT, использующая предикат сравнения с квантором. 
-- самые опытные сотрудники из первых 40 отделов

SELECT first_name, second_name, experience, department_id 
FROM workers 
WHERE experience >= ALL ( SELECT experience 
 FROM workers
 WHERE department_id <= 40) 
 and department_id <= 40-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов. 
-- Проверка вычисления среднего

SELECT 
AVG(total_amount) AS Automatic_AVG,
SUM(total_amount) / COUNT(office_supply_id) AS Calculated_AVG 
FROM ( 
SELECT office_supply_id, SUM(amount) AS total_amount 
 FROM requests 
 GROUP BY office_supply_id 
) as gba-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
-- тест min/max

SELECT MAX(experience) counted_max, MIN(experience) counted_min, 
 ( SELECT experience 
 FROM workers 
 WHERE experience >= ALL ( SELECT experience  FROM workers) LIMIT 1 ) AS my_max, 
 ( SELECT experience 
 FROM workers 
 WHERE experience <= ALL ( SELECT experience  FROM workers) LIMIT 1 ) AS my_min
FROM workers-- 9. Инструкция SELECT, использующая простое выражение CASE. 
-- сколько останется лишних

SELECT office_supply_name, amount, pack_size,
	CASE (amount % pack_size)
    WHEN 0 THEN 'perfect'
    ELSE CAST((pack_size - (amount % pack_size)) AS varchar(10)) || ' left'
	END AS lefts
FROM requests JOIN office_supplies ON requests.office_supply_id = office_supplies.office_supply_id
order by lefts desc -- \i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/run_all.sql

\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q1.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q2.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q3.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q4.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q5.sql

\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q6.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q7.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q8.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q9.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q10.sql

\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q11.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q12.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q13.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q14.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q15.sql

\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q16.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q17.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q18.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q19.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q20.sql

\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q21.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q22.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q23.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q24.sql
\i C:/Users/alena/Desktop/BMSTU_5sem_databases/lab2/q25.sql
