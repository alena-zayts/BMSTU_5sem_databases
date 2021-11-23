--------------------Задание 1
drop database rk2;
create database rk2;

drop table if exists subject cascade;
drop table if exists department cascade;
drop table if exists teacher cascade;
drop table if exists teacher_subject ;


create table subject
(
	id serial primary key,
	subject_name varchar(20),
	hours_num int,
	semester int,
	rate int
);

create table department
(
	id serial primary key,
	name varchar(15),
	description varchar(60)
);

create table teacher
(
	id serial primary key,
	fio varchar(30),
	degree int,
	position varchar(15),
	department_id int
);

alter table teacher
add constraint fk_department_id foreign key (department_id) references department (id);

create table teacher_subject
(
	id serial primary key,
	teacher_id int,
	subject_id int
);

alter table teacher_subject
add constraint fk_teacher_id foreign key (teacher_id) references teacher(id),
add constraint fk_subject_id foreign key (subject_id) references subject(id);

insert into subject (subject_name, hours_num, semester, rate)
values
	('C', 100, 2, 5),
	('python', 50, 1, 2),
	('maths', 10, 1, 5),
	('statistics', 150, 4, 0),
	('russian', 96, 1, 1),
	('english', 8, 1, 2),
	('history', 0, 2, 4),
	('algorythms', 4, 2, 5),
	('maths2', 56, 4, 4),
	('databases', 32, 3, 5),
	('operating systems', 2000, 5, 0);

insert into department (name, description)
values
	('iu7', 'the best'),
	('iu6', 'nah'),
	('sgn', 'learn'),
	('smth', 'doing smth'),
	('his', 'short history'),
	('bm', 'bauman beginning'),
	('qwe', 'rtyu'),
	('asd', 'fghj'),
	('tired', 'to print it'),
	('but', 'need at least 10'),
	('records', 'int this'),
	('wonderful', 'table');
select * from department;

insert into teacher (fio, degree, position, department_id)
values
	('III', 6, 'seminarist', 1),
	('QRY', 0, 'lector', 2),
	('POU', 3, 'seminarist', 1),
	('HUT', 6, 'zamdec', 5),
	('FRE', 3, 'lector', 1),
	('JOK', 4, 'seminarist', 6),
	('DVB', 1, 'seminarist', 1),
	('DVB', 0, 'lector', 1),
	('REW', 3, 'seminarist', 10),
	('POP', 2, 'zamdec', 2),
	('SUP', 1, 'lector', 1);

insert into teacher_subject (teacher_id, subject_id)
values 
	(1, 10),
	(2, 9),
	(3, 8),
	(4, 7),
	(5, 6),
	(6, 5),
	(7, 4),
	(8, 3),
	(9, 2),
	(10, 1),
	(1, 4),
	(2, 6),
	(10, 4),
	(3, 2);

select * from teacher;
select * from subject;
select * from department;
select * from teacher_subject;
	

--------------------Задание 2
---- 1. Инструкция SELECT, использующая предикат сравнения с квантором
---- Вывести ФИО, степень и должность СЕМИНАРИСТОВ, у которых степень выше, 
---- чем у ВСЕХ ЛЕКТОРОВ
select fio, degree, position 
from teacher
where position = 'seminarist' and degree > all (
											select degree 
											from teacher 
											where position = 'lector'
);
	
-- это для проверки, самой высокой степени у лекторов
select max(degree) as max_degree from teacher where position = 'lector';
	
--- 2.  Инструкция SELECT, использующая агрегатные функции в выражениях столбцов
--- статиcтика о предметах по семестрам: количество предметов в семестре и среднее 
--- количество часов на каждый предмет в эттом семестре

select semester, count(*) as amount_of_subjects, avg(hours_num)
from subject 
group by semester
order by semester;

--- 3.Создание новой временной локальной таблицы из результирующего 
--- набора данных инструкции SELECT 
-- Создать таблицу teacher_tmp, где хранятся ФИО и должность преподавателей
-- с кафедры, которая называется 'iu7'

-- одним запросом
drop table if exists teacher_tmp;

with vals (fio, position ) as (
select fio, position 
from teacher join department on teacher.department_id = department.id
where name = 'iu7')
SELECT * INTO temporary table teacher_tmp FROM vals;

select * from teacher_tmp;

-- в несколько шагов
drop table if exists teacher_tmp;
create local temp  table if not exists teacher_tmp
(
	fio varchar(30),
	position varchar(15)
);

insert into teacher_tmp
select fio, position 
from teacher join department on teacher.department_id = department.id
where name = 'iu7';

select * from teacher_tmp;




----- 3. Cоздать хранимую процедуру с входным параметром – имя таблицы, 
----- которая выводит сведения об индексах указанной таблицы в текущей базе
----- данных. Созданную хранимую процедуру протестировать. 
create or replace procedure get_indexes(table_name_in varchar)
as $$
declare 
	rec record;
	cur cursor for 
		select * 
		from pg_indexes pind 
		where pind.schemaname = 'public' and pind.tablename = table_name_in
		order by pind.indexname;
begin
	raise info 'table: % : ', table_name_in;

	open cur;
	LOOP
		fetch cur into rec;
		IF NOT FOUND THEN EXIT;END IF;
		raise info 'index: %', rec.indexname;
		raise info 'index definition: %', rec.indexdef;
	END LOOP;
	close cur;
end;
$$ language plpgsql;

-- тест
call get_indexes('teacher');
call get_indexes('subject');

-- создание дополнительного индекса
CREATE INDEX ON teacher ((lower(fio)));

--тест
call get_indexes('teacher');

	
	
	
