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
