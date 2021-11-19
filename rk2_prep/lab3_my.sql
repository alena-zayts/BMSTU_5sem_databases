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
FROM generate_orders(5, 3);-----------------------------------Функции--------------------------------
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
-- 1. Хранимая процедура без параметров или с параметрами
-- Перевести сотрудника in_w_id из отдела in_prev_d_id в отдел in_new_d_id
drop table workers_copy;
drop table departments_copy;
SELECT * INTO TEMP workers_copy
FROM workers
where department_id between 1 and 5;

SELECT * INTO TEMP departments_copy
FROM departments
where department_id between 1 and 5;

CREATE OR REPLACE PROCEDURE move_worker
(
    in_w_id INT,
    in_prev_d_id INT,
	in_new_d_id INT
)
AS '
BEGIN
    UPDATE workers_copy
    SET department_id = in_new_d_id
    WHERE worker_id=in_w_id;
	
	UPDATE departments_copy
    SET department_size = department_size - 1
    WHERE department_id=in_prev_d_id;
	
	UPDATE departments_copy
    SET department_size = department_size + 1
    WHERE department_id=in_new_d_id;
END;
' LANGUAGE plpgsql;

select workers_copy.worker_id, workers_copy.department_id, 
	departments_copy.department_size, departments_copy.department_name
from workers_copy inner join departments_copy 
	on workers_copy.department_id = departments_copy.department_id
order by workers_copy.worker_id;


-- Вызов процедуры.
CALL move_worker(96, 4, 2);

select workers_copy.worker_id, workers_copy.department_id, 
	departments_copy.department_size, departments_copy.department_name
from workers_copy inner join departments_copy 
	on workers_copy.department_id = departments_copy.department_id
order by workers_copy.worker_id;




-- 2. Рекурсивная хранимая процедура или хранимая процедура с рекурсивным ОТВ.
-- Прошел год, надо увеличить опыт сотрудников
drop table workers_copy;
SELECT worker_id, experience
INTO TEMP workers_copy
FROM workers
where experience between 10 and 20;

CREATE OR REPLACE PROCEDURE year_of_experience
(
	cur_exp int
)
AS '
BEGIN
    IF cur_exp >= 0 THEN
	
    update workers_copy
	set experience = experience + 1
	where experience = cur_exp;
	
	call year_of_experience(cur_exp - 1);
		
	END IF;
END;
' LANGUAGE plpgsql;

select *
from workers_copy
order by worker_id;

CALL year_of_experience(15);
select *
from workers_copy
order by worker_id;


-- 3. Хранимая процедура с курсором
drop table workers_copy;
drop table departments_copy;

SELECT worker_id, department_id, experience
INTO TEMP workers_copy
FROM workers
where department_id between 1 and 5;

SELECT department_id, income
INTO TEMP departments_copy
FROM departments
where department_id between 1 and 5;

-- отдел заработал больше prize_for? накинем сотрудникам год опыта (до 80 макс)
CREATE OR REPLACE PROCEDURE prize
(
    prize_for INT
)
AS '
DECLARE
    myCursor CURSOR FOR
        SELECT department_id
        FROM departments_copy
        WHERE income >= prize_for;
    tmp departments_copy;
	
BEGIN
    OPEN myCursor;
	
    LOOP
        FETCH myCursor INTO tmp;
        EXIT WHEN NOT FOUND;
		
        UPDATE workers_copy
        SET experience = experience + 1
        WHERE experience < 80 and workers_copy.department_id = tmp.department_id;

    END LOOP;
    CLOSE myCursor;
END;
'LANGUAGE  plpgsql;

select * 
from workers_copy inner join departments_copy
	on workers_copy.department_id = departments_copy.department_id
order by worker_id;

CALL prize(1048097);

select * 
from workers_copy inner join departments_copy
	on workers_copy.department_id = departments_copy.department_id
order by worker_id;




-- B.4. Хранимая процедура доступа к метаданным.
-- Информация о столбцах
CREATE OR REPLACE PROCEDURE get_table_meta(
	my_table_name VARCHAR
)
AS '
DECLARE
    info RECORD;
BEGIN
    FOR info IN
        SELECT column_name, data_type, interval_type, domain_name
        FROM information_schema.columns
        WHERE table_name = my_table_name
    LOOP
        RAISE INFO ''info = % '', info;
    END LOOP;
END;
' LANGUAGE plpgsql;

CALL get_table_meta('workers');
CALL get_table_meta('departments');


-- Информация о размерах

CREATE OR REPLACE PROCEDURE get_table_size(
	my_table_name VARCHAR
)
AS '
DECLARE
    s RECORD;
BEGIN
FOR s IN
	select my_table_name, 
	pg_relation_size(my_table_name) as size 
	from information_schema.tables
	where table_name = my_table_name
LOOP
    RAISE INFO ''size = % '', s;
END LOOP;
END;
' LANGUAGE plpgsql;

CALL get_table_size('workers');
CALL get_table_size('departments');
-- 1. Триггер AFTER.
-- Когда сотрудника переводят в другой отдел, надо в старом отделе
-- уменьшить численность, а в новом - увеличить 
drop table workers_copy;
drop table departments_copy;

SELECT worker_id, department_id, experience
INTO TEMP workers_copy
FROM workers
where department_id between 1 and 5;

SELECT department_id, department_size
INTO TEMP departments_copy
FROM departments
where department_id between 1 and 5;

CREATE OR REPLACE FUNCTION transfer_trigger()
RETURNS TRIGGER
AS '
BEGIN
    RAISE INFO ''Old =  %'', old; 
	RAISE INFO ''New =  %'', new;
	
    UPDATE departments_copy
    SET department_size = department_size - 1
    WHERE department_id = old.department_id;
	
	UPDATE departments_copy
    SET department_size = department_size + 1
    WHERE department_id = new.department_id;
    
    RETURN new;
END;
' LANGUAGE plpgsql;


CREATE TRIGGER transfer
AFTER UPDATE ON workers_copy
FOR EACH ROW
EXECUTE PROCEDURE transfer_trigger();

select * 
from workers_copy inner join departments_copy
	on workers_copy.department_id = departments_copy.department_id
order by worker_id;

UPDATE workers_copy
SET department_id = 2
WHERE department_id = 1 and worker_id <> 203;

select * 
from workers_copy inner join departments_copy
	on workers_copy.department_id = departments_copy.department_id
order by worker_id;


-- 2. Триггер INSTEAD OF.
-- Заменяем увольнение на обнуление стажа

drop VIEW workers_new;

CREATE VIEW workers_new AS
SELECT * 
FROM workers
WHERE worker_id < 1000;

CREATE OR REPLACE FUNCTION soft_dismissal()
RETURNS TRIGGER
AS '
BEGIN
    RAISE INFO ''New =  %'', new;
	RAISE INFO ''Old =  %'', old;
	
    UPDATE workers_new
    SET experience = 0
    WHERE worker_id = old.worker_id;
	
    RETURN new;
END;
' LANGUAGE plpgsql;

CREATE TRIGGER soft_dismissal_trigger
INSTEAD OF DELETE ON workers_new
FOR EACH ROW
EXECUTE PROCEDURE soft_dismissal();

SELECT * 
FROM workers_new
order by first_name;

DELETE FROM workers_new
WHERE first_name = 'Aaron';

SELECT * 
FROM workers_new
order by first_name;









-- 1. Защита
-- названия функций с 5 и более параметрами
--drop function boss_func;
CREATE OR REPLACE FUNCTION boss_func(
	department_num int,
	arg2 int,
	arg3 int,
	arg4 int,
	arg5 int
)
RETURNS INT AS '
    SELECT  MAX(experience)
    FROM workers
	Where department_id=department_num;
' 
LANGUAGE sql;
SELECT boss_func(10, 10, 10, 10, 10) AS max_experience;



CREATE OR REPLACE PROCEDURE get_big_funcs()
AS '
DECLARE
    info RECORD;
BEGIN
    FOR info IN
        SELECT specific_name, count(*) as num_of_params
        FROM information_schema.parameters
		where parameter_mode=''IN''
		group by specific_name
		having count(*) > 4
		ORDER BY specific_name
		
		
    LOOP
        RAISE INFO ''info = % '', info;
    END LOOP;
END;
' LANGUAGE plpgsql;

CALL get_big_funcs();

