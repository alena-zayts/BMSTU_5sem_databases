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


--insert into employees (fio, birth_date, department)
--values
--	('qwe', date('25-01-2001'), 'rtyu'),
--	('asd', date('23-05-1939'), 'fghj'),
--	('tired', date('20-01-1969'), 'to print it'),
--	('but', date('20-07-1993'), 'need at least 10'),
--	('records', date('24-01-1299'), 'int this'),
--	('wonderful', date('20-01-1949'), 'table'),
--	('iu7', date('20-04-1959'), 'the best');
--
--insert into times (employee_id, r_date, weekday, r_time, r_TYPE)
--values
--	(1, date('14-12-2018'), 'Суббота', '08:20', 1),
--	(1, date('14-12-2018'), 'Суббота', '09:20', 2),
--	(1, date('14-12-2018'), 'Суббота', '09:00', 1),
--	(2, date('14-12-2018'), 'Суббота', '10:20', 1),
--	(3, date('14-12-2018'), 'Суббота', '09:30', 2),
--	(4, date('14-12-2018'), 'Суббота', '08:50', 1),
--	(5, date('15-12-2018'), 'Суббота', '10:20', 1);


-- Работники.
INSERT INTO employees
VALUES (0, 'Сукочева', '2000-07-19', 'Программист');

INSERT INTO employees
VALUES (1, 'Малков', '1998-01-02', 'Программист');

INSERT INTO employees
VALUES (2, 'Софрнова', '2002-05-01', 'Системный администратор');

INSERT INTO employees
VALUES (3, 'Власов', '1995-11-11', 'Руководитель');

-- Пришли.
INSERT INTO times
VALUES (0, 0, CURRENT_DATE - 1, 'Понедельник', '08:55:00', 1);

INSERT INTO times
VALUES (1, 1, CURRENT_DATE - 1, 'Понедельник', '09:55:00', 1);		--o

INSERT INTO times
VALUES (2, 2, date('2021-12-15'), 'Суббота', '09:05:00', 1);		--o

INSERT INTO times
VALUES (3, 3, CURRENT_DATE - 1, 'Понедельник', '10:51:00', 1);		--o

-- Ушли.
INSERT INTO times
VALUES (4, 0, CURRENT_DATE - 1, 'Понедельник', '16:05:00', 2);

INSERT INTO times
VALUES (5, 1, CURRENT_DATE - 1, 'Понедельник', '16:06:00', 2);

INSERT INTO times
VALUES (6, 2, date('2021-12-15'), 'Суббота', '19:09:00', 2);

INSERT INTO times
VALUES (7, 3, CURRENT_DATE - 1, 'Понедельник', '21:00:00', 2);

INSERT INTO times
VALUES (8, 0, CURRENT_DATE - 1, 'Понедельник', '10:55:00', 2);
INSERT INTO times
VALUES (9, 0, CURRENT_DATE - 1, 'Понедельник', '10:59:00', 1);
INSERT INTO times
VALUES (10, 3, CURRENT_DATE - 1, 'Понедельник', '13:00:00', 2);
INSERT INTO times
VALUES (11, 3, CURRENT_DATE - 1, 'Понедельник', '11:00:00', 1);


INSERT INTO times
VALUES (12, 2, date('2021-12-16'), 'e', '10:09:00', 1);  			----O
INSERT INTO times
VALUES (13, 1, date('2021-12-25'), 'Понедельник', '09:55:00', 1);	----O
INSERT INTO times
VALUES (14, 1, date('2021-11-16'), 'Понедельник', '09:55:00', 1);	----O


select * from employees;
select * from times order by employee_id, r_time;







-- Задание 1 часть 2.
-- Кол-во опоздавших сотрудников.
-- Дата опоздания в кач-ве параметра.


-- запрос на sql
with first_time_in as (
select employee_id, min(r_time) as time_in
from times
where r_type = 1 and r_date = CURRENT_DATE - 1
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
where time_in > time '08:00:00';""", ['date'])

res = plpy.execute(plan, [in_date])

if res:
	return res[0]['amount_of_laters']

$$ LANGUAGE plpython3u;

SELECT * FROM count_lates(CURRENT_DATE - 1) as "amount_of_laters";



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
where time_in > time '08:00:00';
$$ LANGUAGE SQL;

SELECT count_lates_s(CURRENT_DATE - 1) AS cnt;



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



with first_time_in as (
	select distinct on (r_date, time_in) id, employee_id, EXTRACT(WEEK FROM r_date) as week_num, EXTRACT(year FROM r_date) as year, r_date, min(r_time) OVER (PARTITION BY employee_id, r_date) as time_in
	from times
	where r_type = 1)
select employee_id, year, week_num, count(*) as lates_per_week
from first_time_in
where time_in > time '09:00:00'
group by employee_id, year, week_num
having count(*) > 1
order by employee_id;

--select id, employee_id, r_date, r_time, r_type, EXTRACT(WEEK FROM r_date) as week_num, EXTRACT(year FROM r_date) as year
--from times;
--
--select *
--from times
--where r_type = 1 and time_in > time '09:00:00';
--
--select
--from employees
--group by employee_id


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
where time_in > '10:00:00'
group by department;