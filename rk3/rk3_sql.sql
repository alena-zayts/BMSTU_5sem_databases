drop table if exists times cascade;
drop table if exists employees cascade;


create table times
(
	id serial primary key,
	employee_id int,
	r_date date,
	weekday varchar(12),
	r_time time,
	r_type int
);

create table employees
(
	employee_id serial primary key,
	fio varchar(40),
	birth_date date,
	department varchar(25)
);


alter table employees
add constraint fk_employee_id foreign key (employee_id) references employees (employee_id);



-- Работники.
INSERT INTO employees (fio, birth_date, department)
VALUES ('AAA', '2000-01-01', 'IT'),
	   ('BBB', '1960-03-01', 'IT'),

	   ('CCC', '1998-03-17', 'HR'),

	   ('DDD', '1988-03-17', 'PR'),
	   ('EEE', '2005-01-14', 'PR'),
	  --добьем до 11
	   ('EEE', '2005-01-14', 'PR'),
	   ('EEE', '2005-01-14', 'PR'),
	   ('EEE', '2005-01-14', 'PR'),
	   ('EEE', '2005-01-14', 'PR'),
	   ('EEE', '2005-01-14', 'PR'),
	   ('EEE', '2005-01-14', 'PR'),
	   ('EEE', '2005-01-14', 'PR'),
	   ('EEE', '2005-01-14', 'PR'),
	   ('EEE', '2005-01-14', 'PR'),

	   -- и тут 11
	   ('EEE', '2005-01-14', 'wow'),
	   ('EEE', '2005-01-14', 'wow'),
	   ('EEE', '2005-01-14', 'wow'),
	   ('EEE', '2005-01-14', 'wow'),
	   ('EEE', '2005-01-14', 'wow'),
	   ('EEE', '2005-01-14', 'wow'),
	   ('EEE', '2005-01-14', 'wow'),
	   ('EEE', '2005-01-14', 'wow'),
	   ('EEE', '2005-01-14', 'wow'),
	   ('EEE', '2005-01-14', 'wow'),
	   ('EEE', '2005-01-14', 'wow'),
	   ('EEE', '2005-01-14', 'wow');







INSERT INTO times (employee_id, r_date, weekday, r_time, r_TYPE)
VALUES

------------- отдел IT
-- 1
-- все в один день
-- не опоздал, но выходил 4 раза
--
(1, '2021-12-14', 'Вторник', '08:50:00', 1),
(1, '2021-12-14', 'Вторник', '10:55:00', 2),
(1, '2021-12-14', 'Вторник', '10:59:00', 1),
(1, '2021-12-14', 'Вторник', '11:55:00', 2),
(1, '2021-12-14', 'Вторник', '11:59:00', 1),
(1, '2021-12-14', 'Вторник', '12:55:00', 2),
(1, '2021-12-14', 'Вторник', '12:59:00', 1),
(1, '2021-12-14', 'Вторник', '15:50:00', 2),

-- 2
-- о 3 днях
-- опоздал на 55 минут, выходил 4 раза
(2, '2021-12-14', 'Вторник', '09:55:00', 1),
(2, '2021-12-14', 'Вторник', '10:20:00', 2),
(2, '2021-12-14', 'Вторник', '10:40:00', 1),
(2, '2021-12-14', 'Вторник', '11:20:00', 2),
(2, '2021-12-14', 'Вторник', '11:40:00', 1),
(2, '2021-12-14', 'Вторник', '12:20:00', 2),
(2, '2021-12-14', 'Вторник', '12:40:00', 1),
(2, '2021-12-14', 'Вторник', '20:55:00', 2),
-- опять опоздал в ту же неделю, не выходил, на работе 3 часа
(2, '2021-12-15', 'Среда', '10:00:00', 1),
(2, '2021-12-15', 'Среда', '13:00:00', 2),
-- опять опоздал в другую неделю, не выходил, на работе 8 часов
(2, '2021-12-01', 'Среда', '09:55:00', 1),
(2, '2021-12-01', 'Среда', '17:55:00', 2),


--------------- отдел HR
-- 3
-- 2 дня
-- опоздал, не выходил, на работе 10.04
(3, '2021-12-14', 'Вторник', '09:05:00', 1),
(3, '2021-12-14', 'Вторник', '19:09:00', 2),
-- опять опоздал в другую неделю, не выходил, на работе 8 часов
(3, '2021-12-01', 'Среда', '09:55:00', 1),
(3, '2021-12-01', 'Среда', '17:55:00', 2),


-------------- отдел PR
-- 4
-- 1 день
-- опоздал, выходил на 2 часа, на работе всего 10, рабочих 8
(4, '2021-12-14', 'Вторник', '10:51:00', 1),
(4, '2021-12-14', 'Вторник', '11:00:00', 2),
(4, '2021-12-14', 'Вторник', '13:00:00', 1),
(4, '2021-12-14', 'Вторник', '21:51:00', 2),

-- 5
-- 1 день
-- опоздал, не выходил, на работе всего 3
(5, '2021-12-14', 'Вторник', '9:01:00', 1),
(5, '2021-12-14', 'Вторник', '12:01:00', 2);



select * from employees;
select * from times order by employee_id, r_time;


--Написать скалярную функцию, возвращающую количество сотрудников в возрасте от 18 до
--40, выходивших более 3х раз.

--- (предполагая, что имелось в виду выходил более 3 раз в течение любого дня)
-- если считать, что уход домой не учитывается, то >4, иначе >3
drop function if exists task1();
CREATE OR REPLACE FUNCTION task1()
RETURNS real
AS $$
plan = plpy.prepare("""
select count(*) as amount
from employees
where employee_id in (
	with help_row_numbers as (
		select id, employee_id, r_date, r_time, r_type, row_number() over (partition by employee_id, r_date, r_type order by r_time) as r1
		from times
		order by employee_id, r_date, r_time, r_type)
	select employee_id
	from help_row_numbers
	where r_type = 2
	group by employee_id
	having max(r1) > 4 )
and EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date) between 18 and 40;""")
res = plpy.execute(plan)
if res:
	return res[0]['amount']

$$ LANGUAGE plpython3u;

SELECT * FROM task1() as "amount";



--------- 2 задание, исходники
-- Найти все отделы, в которых работает более 10 сотрудников
select department
from employees
group by department
having count(*) > 10;


-- Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня
select *
from employees
where employee_id in (
	with help_row_numbers as (
			select employee_id, r_type, row_number() over (partition by employee_id, r_date, r_type order by r_time) as r1
			from times)
		select employee_id
		from help_row_numbers
		where r_type = 2
		group by employee_id
		having max(r1) = 1
);




--Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату.
select distinct department
from employees
where employee_id in (
with help_row_numbers as (
			select employee_id, r_type, r_date, r_time, row_number() over (partition by employee_id, r_date, r_type order by r_time) as r1
			from times)
	select employee_id
	from help_row_numbers
	where r_type =  1 and r1 = 1 and r_time > '09:00:00' and r_date = '2021-12-14' -- первый приход
);


-- так намного проще
select distinct department
from employees
where employee_id in (
-- айди этих сотрудников
select employee_id
from times
where r_date = '2021-12-14' and r_type = 1
group by employee_id
having min(r_time) > '09:00:00';

