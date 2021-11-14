-- 1. Из таблиц базы данных, созданной в первой
-- лабораторной работе, извлечь данные в JSON.

-- Функция row_to_json - Возвращает кортеж в виде объекта JSON.
SELECT row_to_json(w) result FROM workers w;
SELECT row_to_json(d) result FROM departments d;
SELECT row_to_json(o) result FROM office_supplies o;
SELECT row_to_json(r) result FROM requests r;



-- 2. Выполнить загрузку и сохранение JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

-- Создаем новую таблицу, чтобы сравнить ее со старой.
drop table if exists workers_copy;
create table if not exists workers_copy(
	Worker_ID serial not null PRIMARY KEY,
	Department_ID integer,
	foreign key (Department_ID) REFERENCES departments(department_id),
	First_Name varchar(15) not null,
	Second_Name varchar(20) not null,
	Experience integer not null check (experience >= 0 AND experience <= 80)
);

-- Копируем данные из таблицы workers в файл workers.json
\COPY (SELECT row_to_json(w) result FROM workers w) TO 'C:/Users/alena/Desktop/BMSTU_5sem_databases/lab5/workers.json';

drop table if exists workers_import;
-- Создаем таблицу, которая будет содержать json кортежи.
CREATE TABLE IF NOT EXISTS workers_import(doc json);

-- Теперь копируем данные в созданную таблицу.
\COPY workers_import FROM 'C:/Users/alena/Desktop/BMSTU_5sem_databases/lab5/workers.json';

SELECT * FROM workers_import;

-- Данный запрос преобразует данные из строки в формате json В табличное предстваление. 
-- SELECT * FROM workers_import, json_populate_record(null::workers_copy, doc);
-- Преобразование одного типа в другой null::workers_copy
-- SELECT * FROM workers_import, json_populate_record(CAST(null AS workers_copy ), doc);

-- Загружаем в таблицу сконвертированные данные из формата json из таблицы users_import.
INSERT INTO workers_copy
SELECT worker_id, department_id, first_name, second_name, experience
FROM workers_import, json_populate_record(null::workers_copy, doc);

SELECT * FROM workers_copy;



-- 3. Создать таблицу, в которой будет атрибут(-ы) с типом JSON, или
-- добавить атрибут с типом JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT или UPDATE

drop table if exists workers_copy;
SELECT * INTO workers_copy
FROM workers;

ALTER TABLE workers_copy ADD column Status json;


UPDATE workers_copy
SET status = CASE 
 WHEN Experience < 10 THEN json_object('{value}', '{"Junior"}')
 WHEN Experience < 20 THEN json_object('{value}', '{"Middle"}')
 WHEN Experience < 50 THEN json_object('{value}', '{"Senior"}')
 ELSE json_object('{value}', '{"GOD"}')
 END;
 
select * from workers_copy;

-- 4. Выполнить следующие действия:
-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа

-- CREATE TABLE IF NOT EXISTS workers_fi
-- (
--     worker_id INT,
-- 	First_Name varchar(15) not null,
-- 	Second_Name varchar(20) not null
-- );

-- SELECT *
-- FROM workers_import, json_populate_record(null::workers, doc)
-- WHERE experience > 75;

-- Оператор -> возвращает поле объекта JSON как JSON, поле объекта JSON по ключу.
SELECT doc->'worker_id' AS worker_id, 
		doc->'first_name' AS First_Name,
		doc->'second_name' AS Second_Name
FROM workers_import;

	
-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа


SELECT worker_id, First_Name, Second_Name
FROM workers_import, json_populate_record(null::workers_fi, doc)
where First_Name like 'Dr.%';



-- 3. Выполнить проверку существования узла или атрибута
drop table if exists workers_import;
CREATE TABLE IF NOT EXISTS workers_import(doc json);
\COPY workers_import FROM 'C:/Users/alena/Desktop/BMSTU_5sem_databases/lab5/workers.json';
SELECT * FROM workers_import;

CREATE OR REPLACE PROCEDURE check_attribute_existence()  
    LANGUAGE PLPGSQL
AS 
$$
DECLARE
    object_tmp TEXT;
BEGIN 
    object_tmp = '';
	-- оператор #>> выдача объекта JSON в типе text
    SELECT doc #>> '{worker_id}' --worker_id
    INTO object_tmp
    FROM workers_import;

    IF object_tmp IS NULL THEN raise notice 'Does not exist';
    ELSE raise notice 'Attribute exists - %', object_tmp;
    END IF;
END;
$$;

CALL check_attribute_existence()

-- 4. Изменить XML/JSON документ

drop table if exists wd;
CREATE TABLE wd(doc jsonb);
-- Отдел с сотрудниками
INSERT INTO wd VALUES ('{"department_id":0, "department_size":2, "worker": {"worker_id":0, "fisrt_name":"Bob"}}');
INSERT INTO wd VALUES ('{"department_id":0, "department_size":2, "worker": {"worker_id":1, "fisrt_name":"kok"}}');
INSERT INTO wd VALUES ('{"department_id":1, "department_size":1, "worker": {"worker_id":2, "fisrt_name":"Mary"}}');

SELECT * FROM wd;

-- Особенность конкатенации json заключается в перезаписывании.
SELECT doc || '{"department_id": 33}'::jsonb
FROM wd;

-- Перезаписываем значение json поля.
UPDATE wd
SET doc = doc || '{"department_size": 10}'::jsonb
WHERE (doc->'worker'->'worker_id')::INT = 0;

SELECT * FROM wd;

-- 5. Разделить XML/JSON документ на несколько строк по узлам
CREATE OR REPLACE PROCEDURE split_json_file()  
    LANGUAGE PLPGSQL
AS 
$$
DECLARE 
    object_tmp TEXT;
BEGIN 
    SELECT jsonb_pretty(doc)
    INTO object_tmp
    FROM wd;

    raise notice '%', object_tmp;
END
$$;

CALL split_json_file()