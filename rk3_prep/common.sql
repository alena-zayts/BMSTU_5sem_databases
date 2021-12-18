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
	   ('BBB', '1989-03-01', 'IT'),

	   ('CCC', '1998-03-17', 'HR'),

	   ('DDD', '1988-03-17', 'PR'),
	   ('EEE', '2005-01-14', 'PR');





INSERT INTO times (employee_id, r_date, weekday, r_time, r_TYPE)
VALUES

------------- отдел IT
-- 1
-- все в один день
-- не опоздал, но выходил на 4 минуты, на работе всего 7 часов, рабочих - 6.54
(1, '2021-12-14', 'Вторник', '08:50:00', 1),
(1, '2021-12-14', 'Вторник', '10:55:00', 2),
(1, '2021-12-14', 'Вторник', '10:59:00', 1),
(1, '2021-12-14', 'Вторник', '15:50:00', 2),

-- 2
-- о 3 днях
-- опоздал на 55 минут, выходил на 20 минут, на работе всего 11 часов, рабочих - 10.40
(2, '2021-12-14', 'Вторник', '09:55:00', 1),
(1, '2021-12-14', 'Вторник', '10:20:00', 2),
(1, '2021-12-14', 'Вторник', '10:40:00', 1),
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





-- Задание 1 часть 2.
-- Кол-во опоздавших сотрудников.
-- Дата опоздания в кач-ве параметра.


-- запрос на sql
with first_time_in as (
select employee_id, min(r_time) as time_in
from times
where r_type = 1 and r_date = '2021-12-14'
group by employee_id )
select count(*)
from first_time_in
where time_in > time '09:00:00';




--plp
drop function if exists count_lates(date);
CREATE OR REPLACE FUNCTION count_lates(in_date date)
RETURNS int
AS $$

plan = plpy.prepare("""
with first_time_in as (
select employee_id, min(r_time) as time_in
from times
where r_type = 1 and r_date = $1
group by employee_id )
select count(*) as amount_of_laters
from first_time_in
where time_in > time '09:00:00';""", ['date'])

res = plpy.execute(plan, [in_date])

if res:
	return res[0]['amount_of_laters']

$$ LANGUAGE plpython3u;

SELECT * FROM count_lates('2021-12-14') as "amount_of_laters";



--sql
drop function if exists count_lates_s(date);
CREATE OR REPLACE FUNCTION count_lates_s(in_date DATE)
RETURNS bigINT
AS
$$
with first_time_in as (
select employee_id, min(r_time) as time_in
from times
where r_type = 1 and r_date = in_date
group by employee_id )
select count(*)
from first_time_in
where time_in > time '09:00:00';
$$ LANGUAGE SQL;

SELECT count_lates_s('2021-12-14') AS cnt;



-- 1. Отделы, в которых сотрудники опаздывают более 1х раз в неделю

select distinct department
from employees join
(
with first_time_in as (
	select distinct on (r_date, time_in) id, employee_id, EXTRACT(WEEK FROM r_date) as week_num, EXTRACT(year FROM r_date) as year, r_date, min(r_time) OVER (PARTITION BY employee_id, r_date) as time_in
	from times
	where r_type = 1)
select employee_id, year, week_num, count(*) as lates_per_week
from first_time_in
where time_in > time '09:00:00'
group by employee_id, year, week_num
having count(*) > 1
order by employee_id
) as lates on employees.employee_id = lates.employee_id;


-- тут находим таких сотрудников
--with first_time_in as (
--	select distinct on (r_date, time_in) id, employee_id, EXTRACT(WEEK FROM r_date) as week_num, EXTRACT(year FROM r_date) as year, r_date, min(r_time) OVER (PARTITION BY employee_id, r_date) as time_in
--	from times
--	where r_type = 1)
--select employee_id, year, week_num, count(*) as lates_per_week
--from first_time_in
--where time_in > time '09:00:00'
--group by employee_id, year, week_num
--having count(*) > 1
--order by employee_id;




-- 2.
-- Найти средний возраст сотрудников, не находящихся
-- на рабочем месте 8 часов в неделю.
select avg(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date))
from employees  join
	(
	select distinct on (employee_id, r_date) employee_id, r_date, sum(tmp_dur) over (partition by employee_id, r_date) as day_dur
	from
		(
		select id, employee_id, r_date, r_time, r_type, lag(r_time) over (partition by employee_id, r_date order by r_time) as prev_time, r_time-lag(r_time) over (partition by employee_id, r_date order by r_time) as tmp_dur
		from times
		order by employee_id, r_date, r_time
		) as small_durations
	) as day_durations
on employees.employee_id = day_durations.employee_id
where day_durations.day_dur < '08:00:00';






-- 3. Все отделы и кол-во сотрудников
-- Хоть раз опоздавших за всю историю учета.

with first_time_in as (
	select distinct on (r_date, time_in) id, employee_id, EXTRACT(WEEK FROM r_date) as week_num, EXTRACT(year FROM r_date) as year, r_date, min(r_time) OVER (PARTITION BY employee_id, r_date) as time_in
	from times
	where r_type = 1)
select department, count(distinct first_time_in.employee_id)
from first_time_in join employees on first_time_in.employee_id = employees.employee_id
where time_in > '9:00:00'
group by department;








-------------------------------------------------- версия Алены (странно писать о себе в 3 лице...)
-- 2. Написать скалярную функцию, возвращающую количество сотрудников
-- в возрасте от 18 до 40, выходивших более 2х раз.


-- сама функция, пояснения ниже (от мелких запросов к основному)
drop function if exists task2();
CREATE OR REPLACE FUNCTION task2()
RETURNS real
AS $$
plan = plpy.prepare("""
select count(*) as avg_age
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
	having max(r1) > 2 )
and EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date) between 18 and 40;""")

res = plpy.execute(plan)

if res:
	return res[0]['avg_age']

$$ LANGUAGE plpython3u;

SELECT * FROM task2() as "avg_age";



--- так сможем посчитать количество выходов - это
--  максиммальный row_number по r_type=2  для каждого сотрудника в течении дня
select id, employee_id, r_date, r_time, r_type, row_number() over (partition by employee_id, r_date, r_type order by r_time) as r1
from times
order by employee_id, r_date, r_time, r_type;


-- нам все-равно, в какой именно день он там курил постоянно, поэтому просто макс смотрим
with help_row_numbers as (
	select id, employee_id, r_date, r_time, r_type, row_number() over (partition by employee_id, r_date, r_type order by r_time) as r1
	from times
	order by employee_id, r_date, r_time, r_type)
select employee_id, max(r1) as max_leaves
from help_row_numbers
where r_type = 2
group by employee_id
having max(r1) > 2;

-- осталось взять id и по нему средний возраст
select avg(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date))
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
	having max(r1) > 2 )
and EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date) between 18 and 40;


-- 3. Написать скалярную функцию, возвращающую минимальный
-- Возраст сотрудника, опоздавшего более чем на 10 минут.
drop function if exists task3();
CREATE OR REPLACE FUNCTION task3()
RETURNS real
AS $$
plan = plpy.prepare("""
select min(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date)) as min_age
from employees
where employee_id in (
	with help_row_numbers as (
			select id, employee_id, r_date, r_time, r_type, row_number() over (partition by employee_id, r_date, r_type order by r_time) as r1
			from times
			order by employee_id, r_date, r_time, r_type)
		select employee_id
		from help_row_numbers
		where r_type = 1 and r1 = 1
		group by employee_id
		having max(r_time) - '09:00:00' > '00:10:00');""")

res = plpy.execute(plan)

if res:
	return res[0]['min_age']

$$ LANGUAGE plpython3u;

SELECT * FROM task3() as "min_age";

-- ну если прям по дате захочется
with help_row_numbers as (
		select id, employee_id, r_date, r_time, r_type, row_number() over (partition by employee_id, r_date, r_type order by r_time) as r1
		from times
		order by employee_id, r_date, r_time, r_type)
	select employee_id, max(r_time) as latest_come, r_date
	from help_row_numbers
	where r_type = 1 and r1 = 1
	group by employee_id, r_date;


-- на sql
select min(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date)) as min_age
from employees
where employee_id in (
	with help_row_numbers as (
			select id, employee_id, r_date, r_time, r_type, row_number() over (partition by employee_id, r_date, r_type order by r_time) as r1
			from times
			order by employee_id, r_date, r_time, r_type)
		select employee_id
		from help_row_numbers
		where r_type = 1 and r1 = 1
		group by employee_id
		having max(r_time) - '09:00:00' > '00:10:00')

