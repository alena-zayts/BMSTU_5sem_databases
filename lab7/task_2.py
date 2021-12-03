from worker import Worker
import json
import psycopg2
from colors import *
import sys
from tabulate import tabulate  # это модуль, который позволяет красиво отображать табличные данные.

N = 15


def connection():
    # Подключаемся к БД.
    try:
        con = psycopg2.connect(
            database="postgres",
            user="postgres",
            password="4541",
            host="127.0.0.1",  # Адрес сервера базы данных.
            port="5432"  # Номер порта.
        )
    except:
        print("Ошибка при подключении к БД")
        return None

    print("База данных успешно открыта")
    return con


# Создать JSON документ, извлекая его из таблиц Вашей базы данных
def create_workers_json(cur):
    with open('workers.json', 'w') as f:
        cur.copy_to(f, 'workers')
    query = '''
                    create table if not exists workers_json(
	Worker_ID serial not null,
	Department_ID integer not null,
	First_Name varchar(15) not null,
	Second_Name varchar(20) not null,
	Experience integer not null
);
            '''
    cur.execute(query)
    with open('workers.json', 'r') as f:
        cur.copy_from(f, 'workers_json')


def output_json(array, color):
    print(color, f"{'id':<3}{'dep_id':<5} {'first_name':<15} {'second_name':<15} {'experience':<5}")
    print(*array, sep='\n')


def read_table_json(cur, count=N):
    cur.execute("select * from workers_json")
    rows = cur.fetchmany(count)

    array = list()
    for elem in rows:
        array.append(Worker(*elem))

    output_json(array, GREEN)

    return array


# перевод сотрудника в другой отдел
def update_user(workers, worker_id, new_department_id):
    for elem in workers:
        if elem.worker_id == worker_id:
            elem.department_id = new_department_id

    output_json(workers, BLUE)


def add_worker(workers, worker):
    workers.append(worker)
    output_json(workers, YELLOW)


def task_2():
    con = connection()
    cur = con.cursor()

    create_workers_json(cur)

    # 1. Чтение из JSON документа.
    print(GREEN, f'{"1.Чтение из JSON документа:":^130}')
    workers_array = read_table_json(cur)
    # 2. Обновление JSON документа.
    print(BLUE, f'\n{"2.Обновление XML/JSON документа:":^130}')
    update_user(workers_array, 2, 4)
    # 3. Запись (Добавление) в JSON документ.
    print(YELLOW, f'{"3.Запись (Добавление) в XML/JSON документ:":^130}')
    add_worker(workers_array, Worker(9999, 1, 'Alena', 'Zaytseva', 500))

    # Закрываем соединение с БД.
    cur.close()
    con.close()


if __name__ == '__main__':
    task_2()
