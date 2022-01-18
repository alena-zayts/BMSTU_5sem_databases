--create extension plpython3u;

-- 1) Определяемая пользователем скалярная функция CLR.
-- название департамента по id.
CREATE OR REPLACE FUNCTION get_department_name(in_department_id INT)
RETURNS VARCHAR
AS $$
res = plpy.execute(f" \
    SELECT department_name \
    FROM departments  \
    WHERE department_id = {in_department_id};")
if res:
    return res[0]['department_name']
$$ LANGUAGE plpython3u;

SELECT * FROM get_department_name(1) as "Department name";

















-- 2) Пользовательскую агрегатную функцию CLR.
-- (ниже-средний доход по городу)

-- CREATE OR REPLACE FUNCTION count_avg_income(smth INT, in_city VARCHAR)
-- RETURNS numeric
-- AS $$
-- res = plpy.execute(f" SELECT city,income FROM departments")
-- count = 0
-- summ = 0
-- for elem in res:
-- 	if elem["city"] == in_city:
-- 		count += 1
-- 		summ += elem["income"]

-- return summ / count
-- $$ LANGUAGE plpython3u;

-- SELECT * FROM count_avg_income(0, 'Andreaberg') as "avg income";










-- 3) Определяемую пользователем табличную функцию CLR.
-- Сотрудники, работающие в том же отделе, в котором работает сотрудник с заданным id
CREATE OR REPLACE FUNCTION get_collegues(in_worker_id int)
RETURNS TABLE
(
    worker_id int,
	department_id int,
	department_size int
)
AS $$
rv = plpy.execute(f" \
				  SELECT workers.worker_id as worker_id, departments.department_id as department_id, departments.department_size as department_size \
				  FROM workers JOIN departments on workers.department_id = departments.department_id")
need_dep_id = None
for elem in rv:
    if elem["worker_id"] == in_worker_id:
	    need_dep_id = elem["department_id"]

res = []
for elem in rv:
    if elem["department_id"] == need_dep_id:
	    res.append(elem)
return res
$$ LANGUAGE plpython3u;

SELECT * FROM get_collegues(203);

SELECT workers.worker_id as worker_id, departments.department_id as department_id, departments.department_size as department_size
FROM workers JOIN departments on workers.department_id = departments.department_id
order by department_id;







-- 4) хранимая процедура
-- Перевести сотрудника in_w_id из отдела in_prev_d_id в отдел in_new_d_id
drop table if exists workers_copy;
drop table if exists departments_copy;
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
AS $$
plan = plpy.prepare("""UPDATE workers_copy
                       SET department_id = $2
                       WHERE worker_id = $1""", ['integer', 'integer'])

rv = plpy.execute(plan, [in_w_id, in_new_d_id])

plan = plpy.prepare("""UPDATE departments_copy
                       SET department_size = department_size - 1
                       WHERE department_id = $1""", ['integer'])

rv = plpy.execute(plan, [in_prev_d_id])

plan = plpy.prepare("""UPDATE departments_copy
                       SET department_size = department_size + 1
                       WHERE department_id = $1""", ['integer'])

rv = plpy.execute(plan, [in_new_d_id])

$$ LANGUAGE plpython3u;



















-- 5) Триггер CLR.
-- Заменяем увольнение на обнуление стажа
drop VIEW if exists workers_new;

CREATE VIEW workers_new AS
SELECT *
FROM workers
WHERE worker_id < 1000;

CREATE OR REPLACE FUNCTION soft_dismissal()
RETURNS TRIGGER
AS $$
old_id = TD["old"]["worker_id"]
rv = plpy.execute(f" \
UPDATE workers_new SET experience = 0  \
WHERE worker_id = {old_id}")

return TD["new"]
$$ LANGUAGE plpython3u;

CREATE TRIGGER soft_dismissal_trigger
INSTEAD OF DELETE ON workers_new
FOR EACH ROW
EXECUTE PROCEDURE soft_dismissal();

SELECT *
FROM workers_new
order by first_name;

DELETE FROM workers_new
WHERE first_name = 'Adam';

SELECT *
FROM workers_new
order by first_name;










-- 6) Определяемый пользователем тип данных CLR.

drop type if exists most_experienced cascade;

CREATE TYPE most_experienced AS
(
	id VARCHAR,
	experience INT
);

CREATE OR REPLACE FUNCTION get_most_experienced(in_department_id int)
RETURNS most_experienced
AS
$$
plan = plpy.prepare("      \
SELECT worker_id, experience \
FROM workers                \
WHERE department_id = $1           \
ORDER BY experience DESC;", ["INTEGER"])

rv = plpy.execute(plan, [in_department_id])

if (rv.nrows()):
    return (rv[0]["worker_id"], rv[0]["experience"])
$$ LANGUAGE plpython3u;

SELECT * FROM get_most_experienced('1');


