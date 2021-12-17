import datetime
from peewee import *


con = PostgresqlDatabase(
    database='postgres',
    user='postgres',
    password='4541',
    host='127.0.0.1',
    port=5432
)


class BaseModel(Model):
    class Meta:
        database = con


class Employee(BaseModel):
    employee_id = PrimaryKeyField()
    fio = CharField()
    birth_date = DateField()
    department = CharField()

    class Meta:
        table_name = 'employees'


class Time(BaseModel):
    id = PrimaryKeyField()
    employee_id = ForeignKeyField(Employee, on_delete="cascade")
    r_date = DateField()
    weekday = CharField()
    r_time = TimeField()
    r_type = IntegerField()


    tmp_dur = TimeField()
    day_dur = TimeField()

    class Meta:
        table_name = 'times'


# 1. Отделы, в которых сотрудники опаздывают более 1х раз в неделю
def request_1():
    print('r1')
    task = '''
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
    '''
    cur = con.cursor()

    cur.execute(task)
    rows = cur.fetchall()
    for elem in rows:
        print(*elem)
    print()

    cur.close()

    # result = workers.\
    #     where(lambda x: x['department_id'] <= 2).\
    #     order_by(lambda x: x['experience']).\
    #     select(lambda x: {x['first_name'], x['department_id'], x['experience']})
    # return result


# -- 2.
# -- Найти средний возраст сотрудников, не находящихся
# -- на рабочем месте 8 часов в неделю.
# select avg(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date))
# from employees  join
# 	(
# 	select distinct on (employee_id, r_date) employee_id, r_date, sum(tmp_dur) over (partition by employee_id, r_date) as day_dur
# 	from
# 		(
# 		select id, employee_id, r_date, r_time, r_type, lag(r_time) over (partition by employee_id, r_date order by r_time) as prev_time, r_time-lag(r_time) over (partition by employee_id, r_date order by r_time) as tmp_dur
# 		from times
# 		order by employee_id, r_date, r_time
# 		) as small_durations
# 	) as day_durations
# on employees.employee_id = day_durations.employee_id
# where day_durations.day_dur < '08:00:00';
def request_2():
    print('\n\n\nr2')
    task = '''
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
    '''
    cur = con.cursor()

    cur.execute(task)

    rows = cur.fetchall()
    for elem in rows:
        print(*elem)
    print()

    cur.close()





    part_time_by_edate = Time(partition_by=[Time.employee_id, Time.r_date], order_by=[Time.r_time])

    small_durations = Time.select(Time.id, Time.employee_id, Time.r_date, Time.r_time, Time.r_type,
                           Time.r_time - fn.LAG(Time.r_time).over(part_time_by_edate).alias('tmp_dur'))

    small_durations = small_durations.model

    part_by_idd = small_durations(partition_by=[small_durations.employee_id, small_durations.r_date])

    day_durations = small_durations.select(small_durations.employee_id, small_durations.r_date, fn.sum(small_durations.tmp_dur).over(part_by_idd).alias('day_dur'),)
    day_durations = day_durations.model

    day_durations = day_durations.select().where(day_durations.day_dur < Cast("8:00", "time")).model


    cur_year = datetime.datetime.now().year
    res = Employee.select(fn.AVG(cur_year - Employee.birth_date.year)).join(day_durations).scalar()

    print(res)




# -- 3. Все отделы и кол-во сотрудников
# -- Хоть раз опоздавших за всю историю учета.
#
# with first_time_in as (
# 	select distinct on (r_date, time_in) id, employee_id, EXTRACT(WEEK FROM r_date) as week_num, EXTRACT(year FROM r_date) as year, r_date, min(r_time) OVER (PARTITION BY employee_id, r_date) as time_in
# 	from times
# 	where r_type = 1)
# select department, count(distinct first_time_in.employee_id)
# from first_time_in join employees on first_time_in.employee_id = employees.employee_id
# where time_in > '10:00:00'
# group by department;
def request_3():
    print('\n\n\nr3')

    task = '''
with first_time_in as (
	select distinct on (r_date, time_in) id, employee_id, EXTRACT(WEEK FROM r_date) as week_num, EXTRACT(year FROM r_date) as year, r_date, min(r_time) OVER (PARTITION BY employee_id, r_date) as time_in
	from times
	where r_type = 1)
select department, count(distinct first_time_in.employee_id)
from first_time_in join employees on first_time_in.employee_id = employees.employee_id
where time_in > '10:00:00'
group by department;
    '''
    cur = con.cursor()

    cur.execute(task)
    rows = cur.fetchall()
    for elem in rows:
        print(*elem)
    print()

    cur.close()

    # result = workers.\
    #     where(lambda x: x['department_id'] <= 2).\
    #     order_by(lambda x: x['experience']).\
    #     select(lambda x: {x['first_name'], x['department_id'], x['experience']})
    # return result


def task_1():
    cursor = con.execute_sql(" \
        SELECT DISTINCT e.fio FROM employee e JOIN times i ON e.id=i.employee_id \
        WHERE i.r_date = '2018-12-14' AND i.r_type = 1 AND DATE_PART('minute', i.r_time::TIME - '9:00'::TIME) < 5; \
    ")
    for row in cursor.fetchall():
        print(row)

    cursor = Employee.select(Employee.fio).join(Time).where(
        Time.r_date == "2018-12-14",
        Time.r_type == 1,
        fn.Date_part('minute', Time.r_time.cast("time") - Cast("9:00", "time"))
    )
    for row in cursor:
        print(row)


def task_2():
    cursor = con.execute_sql(" \
        SELECT DISTINCT e.fio FROM employee e JOIN times i ON e.id = i.employee_id \
        WHERE i.r_date = '2018-12-14' AND i.r_type = 2 AND i.r_time - LAG(i.r_time) OVER (PARTITION BY i.r_time) > 10; \
    ")
    for row in cursor.fetchall():
        print(row)
    cursor = Employee.select(Employee.fio).join(Time).where(
        Time.r_date == "2018-12-14",
        Time.r_type == 2,
        Time.r_time - fn.Lag(Time.r_time).over(partition_by=[Time.r_time])
    )
    for row in cursor:
        print(row)


def task_3():
    cursor = con.execute_sql(" \
        SELECT DISTINCT e.fio, e.department FROM employee e JOIN times i on e.id=i.employee_id \
        WHERE e.department = 'Бухгалтерия' AND i.r_type = 1 AND i.r_time < '8:00'::TIME \
    ")
    for row in cursor.fetchall():
        print(row)
    cursor = Employee.select(Employee.fio, Employee.department).join(Time).where(
        Employee.department == "Бухгалтерия",
        Time.r_type == 1,
        Time.r_time < Cast("8:00", "time")
    )
    for row in cursor:
        print(row)


def main():
    request_1()
    request_2()
    request_3()



if __name__ == "__main__":
    main()
