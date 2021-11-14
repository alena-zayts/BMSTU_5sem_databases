-----------------------------------Функции--------------------------------
-- 1. Скалярная функция.
-- Возвращает максимальный опыт в отделе 
-- c department_id=department_num(=10 по умолчанию)
CREATE OR REPLACE FUNCTION get_max_experience_in_department(
	department_num int = 10)
RETURNS INT AS '
    SELECT  MAX(experience)
    FROM workers
	Where department_id=department_num;
' 
LANGUAGE sql;

SELECT get_max_experience_in_department(10) AS max_experience;

-- проверка
SELECT  department_id, MAX(experience)
FROM workers
Group by department_id
Order by department_id




-- 2. Подставляемая табличная функция.
-- Возвращает все заказы пользователя с worker_id = user_num
CREATE OR REPLACE FUNCTION get_users_requests(user_num INT = 1) 
RETURNS table (request_id int, worker_id int, 
							movers_amount int) 
							AS '
    SELECT request_id, worker_id, movers_amount
    FROM requests
    WHERE worker_id = user_num;
' LANGUAGE  sql;


-- Мы можем селект запросом вывести этот кортеж как таблицу.
SELECT *
FROM get_users_requests(7791);

-- а так будет скаляр
--SELECT get_users_requests(7791) AS users_requests;

-- проверка
-- найдем, что поинтересней - 7791
select worker_id, count(request_id) as cnt
from requests
group by worker_id
order by cnt desc;

select *
from requests
where worker_id=7791

DROP FUNCTION get_users_requests(integer)





-- 3. Многооператорная табличная функция.
-- Сравнение опыта сотрудников с опытом в заданном интервале
CREATE OR REPLACE FUNCTION get_experience_info(lb INT = 0, rb INT = 80) 
	RETURNS TABLE (worker_id INTEGER, 
				   experience_diff INTEGER, 
				   experience_min INTEGER, 
				   experience_max INTEGER)
	LANGUAGE plpgsql
AS 
$$
DECLARE
   experience_avg INTEGER;
   experience_min INTEGER;
   experience_max INTEGER;
BEGIN 
		
    SELECT AVG(experience::INTEGER)
    INTO experience_avg
    FROM workers
	WHERE workers.experience between lb and rb; 

    SELECT MIN(experience::INTEGER)
    INTO experience_min
    FROM workers
	WHERE workers.experience between lb and rb; 

    SELECT MAX(experience::INTEGER)
    INTO experience_max
    FROM workers
	WHERE workers.experience between lb and rb; 

    RETURN query 
		SELECT workers.worker_id, 
			   workers.experience::INTEGER - experience_avg AS experience_diff, 
			   experience_min, 
			   experience_max
		FROM workers
		WHERE workers.experience between lb and rb; 
END;
$$;
select *
from get_experience_info(1, 20)




-- A.4. Рекурсивная функция или функция с рекурсивным ОТВ
-- генерация заявок на товары с id до n_supplies в количестве до up_to
CREATE OR REPLACE FUNCTION generate_orders(n_supplies INT, up_to int)
RETURNS TABLE
(
    out_os_id INT,
    out_amount INT
)
AS '
-- Определение ОТВ
		with recursive orders(office_supply_id, n) as (
-- Определение закрепленного элемента
			SELECT office_supply_id, 1 as prev_amount
 			FROM office_supplies
 			where office_supply_id < n_supplies
-- Определение рекурсивного элемента
			union all 
			select office_supply_id, n+1 
			from orders 
			where n < up_to
			)
			
-- Инструкция, использующая ОТВ			
	select * 
	from orders;
' LANGUAGE sql;


SELECT *
FROM generate_orders(5, 3);