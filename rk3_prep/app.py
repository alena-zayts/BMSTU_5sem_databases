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

    class Meta:
        table_name = 'times'

def request_1():
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
    # task_1()
    # task_2()
    # task_3()


if __name__ == "__main__":
    main()