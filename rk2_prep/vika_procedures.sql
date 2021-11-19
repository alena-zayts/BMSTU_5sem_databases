----------------------------------------------------
--Вывести имя функции и типы принимаемых значений
----------------------------------------------------
create or replace procedure show_functions() as
$$
declare 
	cur cursor
	for select proname, proargtypes
	from (
		select proname, pronargs, prorettype, proargtypes
		from pg_proc
		where pronargs > 0
	) AS tmp;
	row record;
begin
	open cur;
	loop
		fetch cur into row;
		exit when not found;
		raise notice '{func_name : %} {args : %}', row.proname, row.proargtypes;
	end loop;
	close cur;
end
$$ language plpgsql;

call show_functions();


----------------------------------------------------
--Создать хранимую процедуру с выходным параметром, которая выводит
--список имен и параметров всех скалярных SQL функций пользователя
--(функции типа 'FN') в текущей базе данных. Имена функций без параметров
--не выводить. Имена и список параметров должны выводиться в одну строку.
--Выходной параметр возвращает количество найденных функций.
--Созданную хранимую процедуру протестировать.
----------------------------------------------------
CREATE PROCEDURE MyTables13 
@cnt int OUTPUT
AS  
BEGIN  
SELECT * FROM sys.all_objects
where type = 'FN'
SELECT @cnt = COUNT(*) FROM sys.all_objects
where type = 'FN'
END
GO

DECLARE @cnt int 
EXEC MyTables13 @cnt output
GO

PRINT 'Êîëè÷åñòâî ôóíêöèé: ' + CONVERT(VARCHAR, @cnt)


----------------------------------------------------
-- Создать хранимую процедуру с входным параметром – имя базы данных,
-- которая выводит имена ограничений CHECK и выражения SQL, которыми
-- определяются эти ограничения CHECK, в тексте которых на языке SQL
-- встречается предикат 'LIKE'. Созданную хранимую процедуру
-- протестировать.
----------------------------------------------------
create extension dblink;
create or replace procedure get_like_constraints(in data_base_name text)
    language plpgsql
as
$$
declare
    constraint_rec record;
begin
    for constraint_rec in select *
                          from dblink(concat('dbname=', data_base_name, ' options=-csearch_path='),
                                      'select conname, consrc
                                      from pg_constraint
                                      where contype = ''c''
                                          and (lower(consrc) like ''% like %'' or consrc like ''% ~~ %'')')
                                   as t1(con_name varchar, con_src varchar)
        loop
            raise info 'Name: %, src: %', constraint_rec.con_name, constraint_rec.con_src;
        end loop;
end
$$;

-- Тестируем
-- Добавили ограничение с like
alter table customers
    add constraint a_in_name check ( name like '%a%');
-- Вызвали процедуру
DO
$$
    begin
        call get_like_constraints('rk2');
    end;
$$;


----------------------------------------------------
-- Создать хранимую процедуру с входным параметром – "имя таблицы",
-- которая удаляет дубликаты записей из указанной таблицы в текущей
-- базе данных. Созданную процедуру протестировать.
----------------------------------------------------
create or replace procedure rem_duplicates(in t_name text)
    language plpgsql
as
$$
declare
    query text;
    col text;
    column_names text[];
begin
    query = 'delete from ' || t_name || ' where id in (' ||
                'select ' || t_name || '.id ' ||
                'from ' || t_name ||
                ' join (select id, row_number() over (partition by ';
    for col in select column_name from information_schema.columns where information_schema.columns.table_name=t_name loop
        query = query || col || ',';
    end loop;
    query = trim(trailing ',' from query);
    query = query || ') as rn from ' || t_name || ') as t on t.id = ' || t_name || '.id' ||
            ' where rn > 1)';
    raise notice '%', query;
    execute query;
end
$$;

-- Тестируем
-- Добавили дубликаты
insert into teacher(id, dep_id, name, grade, job)
select *
    from teacher
    where id < 5;

-- Вызвали процедуру
DO
$$
    begin
        call rem_duplicates('teacher');
    end;
$$;


----------------------------------------------------
﻿--Создать хранимую процедуру с входным параметром – имя таблицы,
--которая выводит сведения об индексах указанной таблицы в текущей базе
--данных. Созданную хранимую процедуру протестировать.
----------------------------------------------------
DROP PROCEDURE IF EXISTS getIdx;
CREATE PROCEDURE getIdx(n VARCHAR(30))
AS $$
DECLARE
	a INT;
	curRow RECORD;
	tblCurs REFCURSOR;
		
BEGIN
	OPEN tblCurs FOR
		EXECUTE 'SELECT indexname FROM pg_indexes WHERE tablename =' || n;
	LOOP
		FETCH tblCurs INTO curRow;
		EXIT WHEN NOT FOUND;

		RAISE NOTICE '%', curRow.indexname;
				
	END LOOP;
	CLOSE tblCurs;
END;
$$ LANGUAGE PLpgSQL;


CALL getIdx('Teacher');



- Создать хранимую процедуру, которая не уничтожая базу данных, уничтожает все те таблицы текущей базы данных в схеме 'dbo' (но я делаю 'public', потому что у меня postgres), имена которых начинаются с фразы 'TableName'. Созданную хранимую процедуру протестировать
	

	CREATE TABLE IF NOT EXISTS TableName1 (
	 a int
	);
	

	CREATE TABLE IF NOT EXISTS TableName2 (
	 a int
	);
	

	CREATE TABLE IF NOT EXISTS TableName3 (
	    a int
	);
	

	CREATE TABLE IF NOT EXISTS TableName4 (
	    a int
	);
	

	CREATE OR REPLACE PROCEDURE rm_all_like(tablename varchar)
	AS $$
	DECLARE
	    elem varchar = '';
	BEGIN
	    FOR elem IN
	        EXECUTE 'SELECT table_name FROM information_schema.tables
	        WHERE table_type=''BASE TABLE'' AND table_name LIKE ''' || tablename || '%'''
	    LOOP
	        EXECUTE 'DROP TABLE ' || elem;
	    END LOOP;
	END;
	$$ LANGUAGE PLPGSQL;
	

	-- Вызываем функцию командой `call rm_all_like('tablename')` и удалятся все созданные выше таблицы (TableName...)
	-- PS: tablename, возможно, нужно было захардкодить, но лучше сделать больше, чем меньше
	-- PS2: примечательно, что в постгресе все приводится к нижнему регистру, поэтому удалять надо именно 'tablename', а не 'TableName'

------------------------------------------
-создать хранимую процедуру с выходными парметром, которая уничтожает все sql ddl триггеры(триггер типа tr)
-в текущей базе данных. выходной параметр возвращает количетсво уничтоженных триггеров.
----------------------------------------------
CREATE OR REPLACE PROCEDURE DeleteTriggers IS
	    ttype VARCHAR2(128);
	    ttname VARCHAR2(128);
	    count_ INTEGER;
	BEGIN
	    count_ := 0;
	    DBMS_OUTPUT.enable(1000000);
	    FOR trigger IN (
	        SELECT trigger_name, trigger_type
	        FROM all_triggers
	    ) LOOP
	        ttype := trigger.trigger_type;
	        ttname := trigger.trigger_name;
	        IF ttype = 'CREATE' OR ttype = 'ALTER' OR ttype = 'DROP' THEN
	            EXECUTE IMMEDIATE 'DROP TRIGGER $ttname';
	            count_ := count_ + 1;
	        END IF;
	    END LOOP;
	    DBMS_OUTPUT.put_line(count_);
	END;
	/
	

	BEGIN
	    DeleteTriggers();
	END;
	/


-- Удаляем триггеры из всех таблиц.
CREATE OR REPLACE FUNCTION strip_all_triggers() RETURNS text AS $$ DECLARE
    triggNameRecord RECORD;
    triggTableRecord RECORD;
   my_count int;
BEGIN
    FOR triggNameRecord IN select distinct(trigger_name) from information_schema.triggers where trigger_schema = 'public' LOOP
        FOR triggTableRecord IN SELECT distinct(event_object_table) from information_schema.triggers where trigger_name = triggNameRecord.trigger_name LOOP
            RAISE NOTICE 'Dropping trigger: % on table: %', triggNameRecord.trigger_name, triggTableRecord.event_object_table;
            EXECUTE 'DROP TRIGGER ' || triggNameRecord.trigger_name || ' ON ' || triggTableRecord.event_object_table || ';';
        END LOOP;
    END LOOP;

    RETURN my_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

select strip_all_triggers();

-- Создать хранимую процедуру с двумя входными параметрами – имя базы
-- данных и имя таблицы, которая выводит сведения об индексах указанной
-- таблицы в указанной базе данных. Созданную хранимую процедуру
-- протестировать.
	CREATE OR REPLACE PROCEDURE get_indexes_info(tblname VARCHAR)
	AS $$
	DECLARE
	    rec RECORD;
	    cur CURSOR FOR
	        SELECT pind.indexname, pind.indexdef FROM pg_indexes pind 
	        WHERE pind.schemaname = 'public' AND pind.tablename = tblname
	        ORDER BY pind.indexname;
	BEGIN
	    OPEN cur;
	    LOOP
	        FETCH cur INTO rec;
	        RAISE NOTICE 'TABLE: %, INDEX: %s, DEFINITION: %', tblname, rec.indexname, rec.indexdef;
	        EXIT WHEN NOT FOUND;
	    END LOOP;
	    CLOSE cur;
	END;
	$$ LANGUAGE PLPGSQL;
	CALL get_indexes_info('executors');
	CALL get_indexes_info('customers');
	CALL get_indexes_info('activities');


create procedure my_proc(dbname varchar(30), tablename varchar(30))
	as
	    $$
	    begin
	    SELECT
	      class1.relname, i.*
	    FROM
	      pg_index i
	      join pg_class class1 on class1.oid = i.indexrelid
	      join pg_class class2 on class2.oid = i.indrelid
	    WHERE
	      class2.relname = tablename;
	    end;
	    $$
	language 'plpgsql';
	
	drop procedure my_proc(dbname varchar, tablename varchar);
	
	call my_proc('', 'team');

-------------------------------
-Создать хранимую процедуру с входными параметром, которая выводит имена и описания типа объектов(только хранимых процедур и скалярных
-функций), в тексте которых на языке sql встречается строка, задаваемая параметром процедуры.
------------------------------------
CREATE OR REPLACE PROCEDURE info_routine
(
    str VARCHAR(32)
)
AS '
DECLARE
    elem RECORD;
BEGIN
    FOR elem in
        SELECT routine_name, routine_type
        FROM information_schema.routines
             -- Чтобы были наши схемы.
        WHERE specific_schema = ''public''
        AND (routine_type = ''PROCEDURE''
        OR (routine_type = ''FUNCTION'' AND data_type != ''record''))
        AND routine_definition LIKE CONCAT(''%'', str, ''%'')
    LOOP
        RAISE NOTICE ''elem: %'', elem;
    END LOOP;
END;
' LANGUAGE plpgsql;


CALL info_routine('CONCAT');


-- null - процедура
-- in
-- record - мб таблица.


select data_type, specific_name
FROM information_schema.routines
WHERE specific_schema = 'public';


CREATE OR REPLACE FUNCTION func_int()
RETURNS INT AS '
    SELECT  5
' LANGUAGE sql;

------------------------------
-фигня где имя базы данных и дата резевной копии
-------------------------------------------
CREATE OR REPLACE PROCEDURE backup()
	AS $$
	DECLARE
	    elem varchar;
	    reserve_name varchar;
	BEGIN
	    FOR elem IN
	        SELECT datname FROM pg_database
	    LOOP
	        SELECT elem || '_' || EXTRACT(year FROM current_date)::varchar ||
	        EXTRACT(month FROM current_date)::varchar || EXTRACT(day FROM current_date)::varchar
	        INTO reserve_name;
	        RAISE NOTICE 'making copy of % as %', elem, reserve_name;
	        EXECUTE 'CREATE DATABASE ' || reserve_name || ' WITH TEMPLATE ' || elem;
	    END LOOP;
	END;
	$$ LANGUAGE PLPGSQL;


