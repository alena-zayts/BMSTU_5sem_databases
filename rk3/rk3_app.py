# Вариант 1

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



# 1. Найти все отделы, в которых работает более 10 сотрудников
def request_1():
    print('\n\nr1: Найти все отделы, в которых работает более 10 сотрудников\n\n')
    print('cur:')
    task = '''
select department
from employees
group by department 
having count(*) > 10;
    '''
    cur = con.cursor()

    cur.execute(task)
    rows = cur.fetchall()
    for elem in rows:
        print(*elem)
    print()

    cur.close()

    query = (Employee.
             select(Employee.department).
             group_by(Employee.department).
             having(fn.Count(SQL('*')) > 10))

    print('peewee')
    executed = query.dicts().execute()
    for elem in executed:
        print(elem['department'])


# 2. Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня
def request_2():
    print('\n\nr2: Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня\n\n')
    print('cur:')
    task = '''
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
    '''
    cur = con.cursor()

    cur.execute(task)
    rows = cur.fetchall()
    for elem in rows:
        print(*elem)
    print()

    cur.close()





# 3. Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату.
def request_3(date):
    print('\n\nr3: Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. \n\n')
    print('cur:')
    task = f'''
select distinct department
from employees 
where employee_id in (
with help_row_numbers as (
			select employee_id, r_type, r_date, r_time, row_number() over (partition by employee_id, r_date, r_type order by r_time) as r1
			from times)
	select employee_id 
	from help_row_numbers
	where r_type =  1 and r1 = 1 and r_time > '09:00:00' and r_date = '{date}');
    '''
    cur = con.cursor()

    cur.execute(task)
    rows = cur.fetchall()
    for elem in rows:
        print(*elem)
    print()

    cur.close()

    ids = (Time.
           select(Time.employee_id).
           where(Time.r_date == f"'{date}'" and Time.r_type == 1).
           group_by(Time.employee_id).
           having(fn.min(Time.r_time) > '09:00:00'))

    executed = ids.dicts().execute()
    answer = (Employee.
              select(Employee.department).
              distinct().
              where(Employee.employee_id.in_(ids)))
    answer = answer.dicts().execute()
    print('peewee')

    for elem in answer:
        print(elem['department'])




def main():
    request_1()
    request_2()
    request_3('2021-12-14')



if __name__ == "__main__":
    main()
