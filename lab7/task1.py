# Документация:
# https://viralogic.github.io/py-enumerable/

from py_linq import *
from worker import *
from colors import *


# Работники из первых 2 отделов отсортированные по опыту
def request_1(workers):
    result = workers.\
        where(lambda x: x['department_id'] <= 2).\
        order_by(lambda x: x['experience']).\
        select(lambda x: {x['first_name'], x['department_id'], x['experience']})
    return result


# Количество работников с опытом 80 лет
def request_2(workers):

    result = workers.count(lambda x: x['experience'] == 80)

    return result


# минимальный и максимальный опыт и id сотрудников 5 отдела с именем, оканчивающимся на 'a'.
def request_3(workers):
    target_workers = workers.\
        where(lambda x: x['department_id'] == 5 and x['first_name'].endswith('a'))

    age = Enumerable([{target_workers.min(lambda x: x['experience']), target_workers.max(lambda x: x['experience'])}])
    worker_id = Enumerable([{target_workers.min(lambda x: x['worker_id']), target_workers.max(lambda x: x['worker_id'])}])
    result = Enumerable(age).union(Enumerable(worker_id), lambda x: x)

    return result


# количество людей с фамилиями на буквы алфавита,
def request_4(workers):
    result = workers.group_by(key_names=['second_name'], key=lambda x: x['second_name'][0]).\
        select(lambda g: {'key': g.key.second_name, 'count': g.count()}). \
        order_by(lambda x: x['key'])
    return result

# join отделов и сотрудников
def request_5(workers):
    department = Enumerable([{'department_id': i, 'income': i * 100 + i} for i in range(3)])
    # inner_key = i_k первичный ключ
    # outer_key = o_k внешний ключ
    # inner join
    dw = workers.join(department, lambda o_k: o_k['department_id'], lambda i_k: i_k['department_id'])

    for elem in dw:
        print(elem)

    return dw


def task_1():
    # Создаем коллекцию.
    workers = Enumerable(create_workers('workers.csv'))

    print(GREEN, '\n1. Работники из первых 2 отделов, отсортированные по опыту:\n')
    for elem in request_1(workers):
        print(elem)

    print(YELLOW, f'\n2.Количество работников с опытом 80 лет: {str(request_2(workers))}')

    print(BLUE, '\n3. Минимальный и максимальный опыт и id сотрудников 5 отдела с именем, оканчивающимся на "a":\n')
    for elem in request_3(workers):
        print(elem)

    print(GREEN, '\n4. Количество людей с фамилиями на буквы алфавита:\n')
    for elem in request_4(workers):
        print(elem)

    print(YELLOW, '\n5. join отделов и сотрудников:\n')
    for elem in request_5(workers):
        print(elem)

if __name__ == '__main__':
    task_1()