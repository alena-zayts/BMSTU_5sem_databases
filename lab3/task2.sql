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

