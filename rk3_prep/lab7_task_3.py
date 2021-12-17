# Спасибо статейке:
# https://habr.com/ru/post/322086/
# И, конечно, документации:
# http://docs.peewee-orm.com
# -----------------------------------
# таблица связи между типом поля в нашей модели и в базе данных:
# http://docs.peewee-orm.com/en/latest/peewee/models.html#field-types-table

from peewee import *
from colors import *

# Подключаемся к нашей БД.
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


class Departments(BaseModel):
    id = IntegerField(column_name='department_id')
    department_name = CharField(column_name='department_name')
    department_size = IntegerField(column_name='department_size')
    city = CharField(column_name='city')
    income = FloatField(column_name='income')

    class Meta:
        table_name = 'departments'


class Workers(BaseModel):
    id = IntegerField(column_name='worker_id', primary_key=True)
    department_id = ForeignKeyField(Departments)
    first_name = CharField(column_name='first_name')
    second_name = CharField(column_name='second_name')
    experience = IntegerField(column_name='experience')

    class Meta:
        table_name = 'workers'


class OfficeSupplies(BaseModel):
    id = IntegerField(column_name='office_supply_id')
    office_supply_name = CharField(column_name='office_supply_name')
    pack_size = IntegerField(column_name='pack_size')
    price = FloatField(column_name='price')
    weight = FloatField(column_name='weight')

    class Meta:
        table_name = 'office_supplies'

class Requests(BaseModel):
    id = IntegerField(column_name='request_id')
    worker_id = ForeignKeyField(Workers)
    office_supply_id = ForeignKeyField(OfficeSupplies)
    amount = IntegerField(column_name='amount')
    completed = BooleanField(column_name='completed')
    movers_amount = IntegerField(column_name='movers_amount')

    class Meta:
        table_name = 'requests'


def query_1():
    print(GREEN, f'{"1. Однотабличный запрос на выборку:":<130}')
    print('Работники из 1 отдела с опытом до 40, отсортированные по имени')

    query = Workers.select().\
        where(Workers.department_id == 1).where(Workers.experience <= 40).\
        order_by(Workers.first_name)

    # print(BLUE, f'\n{"Запрос:":130}\n\n', query, '\n')

    workers_selected = query.dicts().execute()

    # print(YELLOW, f'\n{"Результат:":^130}\n')
    for elem in workers_selected:
        print(elem)


def query_2():
    global con
    print(BLUE, f'\n{"2. Многотабличный запрос на выборку:":<130}\n')
    print(BLUE, f'{"Первые 100 работников со всеми заказанными ими товарами:":<130}\n')

    query = Workers.select(Workers.id, Workers.first_name, OfficeSupplies.id, OfficeSupplies.office_supply_name).\
        join(Requests).join(OfficeSupplies).order_by(Workers.id).where(Workers.id < 100)

    u_b = query.dicts().execute()
    for elem in u_b:
        print(elem)


def print_last_workers():
    print(f'\n{"Последние 5 работников:":<130}\n')
    query = Workers.select().limit(5).order_by(Workers.id.desc())
    for elem in query.dicts().execute():
        print(elem)
    print()


def add_worker(new_department_id, new_first_name, new_second_name, new_experience):
    global con

    try:
        with con.atomic() as txn:
            Workers.create(department_id=new_department_id, first_name=new_first_name,
                           second_name=new_second_name, experience=new_experience)
            print(YELLOW, "Работник успешно добавлен!")
    except Exception as e:
        print(e)
        txn.rollback()


def update_department(worker_id, new_department_id):
    try:
        worker = Workers(id=worker_id)
        worker.department_id = new_department_id
        worker.save()
        print(GREEN, "Работник успешно переведен в другой отдел!")
    except Exception as e:
        print(e)


def del_worker(worker_id):
    try:
        worker = Workers.get(Workers.id == worker_id)
        worker.delete_instance()
        print(BLUE, "Работник успешно уволен!")
    except Exception as e:
        print(e)

def query_3():
    # 3. Три запроса на добавление, изменение и удаление данных в базе данных.
    print(YELLOW, f'\n{"3. Три запроса на добавление, изменение и удаление данных в базе данных:":<130}\n')

    print_last_workers()

    add_worker(17, 'Alena', 'Zaytseva', 80)
    print_last_workers()

    update_department(10001, 77)
    print_last_workers()

    del_worker(10001)
    print_last_workers()


def query_4():
    # 4. Получение доступа к данным, выполняя только хранимую процедуру.
    global con
    cursor = con.cursor()

    print(GREEN, f'\n{"4. Получение доступа к данным, выполняя только хранимую процедуру:":^130}\n')
    add_worker(17, 'Alena', 'Zaytseva', 80)
    print_last_workers()

    cursor.execute(f"CALL move_worker(10002, 17, 77);")
    # Фиксируем изменения.
    # Т.е. посылаем команду в бд.
    # Метод commit() помогает нам применить изменения,
    # которые мы внесли в базу данных,
    # и эти изменения не могут быть отменены,
    # если commit() выполнится успешно.
    con.commit()

    print_last_workers()

    cursor.close()


def task_3():
    global con

    query_1()
    query_2()
    query_3()
    query_4()

    con.close()

if __name__ == '__main__':
    task_3()