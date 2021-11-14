from execute_task import *


def task1(cur, con = None):
    root_1 = Tk()

    root_1.title('Задание 1')
    root_1.geometry("300x200")
    root_1.configure(bg="#DEB887")
    root_1.resizable(width=False, height=False)

    Label(root_1, text="  Введите id:", bg="#DEB887").place(
        x=75, y=50)
    department_id = Entry(root_1)
    department_id.place(x=75, y=85, width=150)

    b = Button(root_1, text="Выполнить",
               command=lambda arg1=cur, arg2=department_id: execute_task1(arg1, arg2),  bg="#F5F5DC")
    b.place(x=75, y=120, width=150)

    root_1.mainloop()


def task2(cur, con = None):
    cur.execute("select requests.request_id, office_supplies.office_supply_name, workers.first_name \
    from workers join (requests join office_supplies \
    on requests.office_supply_id = office_supplies.office_supply_id) \
    on workers.worker_id = requests.worker_id;")

    rows = cur.fetchall()

    create_list_box(rows, "Задание 2")


def task3(cur, con = None):
    # Добавить столбец с суммой кол-ва часов по группам возраста.
    cur.execute("\
    WITH new_table (id, nickname, department_id, sum) \
    AS \
    ( \
        SELECT id, nickname,  department_id, number_of_hours, SUM(number_of_hours) OVER(PARTITION BY department_id) sum \
        FROM users \
        ORDER BY id \
    ) \
    SELECT * FROM new_table;")
    rows = cur.fetchall()
    create_list_box(rows, "Задание 3")


def task4(cur, con):

    root_1 = Tk()

    root_1.title('Задание 4')
    root_1.geometry("300x200")
    root_1.configure(bg="#DEB887")
    root_1.resizable(width=False, height=False)

    Label(root_1, text="Введите название таблицы:", bg="#DEB887").place(
        x=65, y=50)
    name = Entry(root_1)
    name.place(x=75, y=85, width=150)

    b = Button(root_1, text="Выполнить",
               command=lambda arg1=cur, arg2=name: execute_task4(arg1, arg2, con),  bg="#F5F5DC")
    b.place(x=75, y=120, width=150)

    root_1.mainloop()


def task5(cur, con = None):
    cur.execute("SELECT get_max_number_of_hours() AS max_hours;")

    row = cur.fetchone()

    mb.showinfo(title="Результат",
                message=f"Максимальное кол-во часов составляет: {row[0]}")


def task6(cur, con = None):
    root = Tk()

    root.title('Задание 1')
    root.geometry("300x200")
    root.configure(bg="#DEB887")
    root.resizable(width=False, height=False)

    Label(root, text="  Введите id:", bg="#DEB887").place(
        x=75, y=50)
    user_id = Entry(root)
    user_id.place(x=75, y=85, width=150)

    b = Button(root, text="Выполнить",
               command=lambda arg1=cur, arg2=user_id: execute_task6(arg1, arg2),  bg="#F5F5DC")
    b.place(x=75, y=120, width=150)

    root.mainloop()


def task7(cur, con=None):
    root = Tk()

    root.title('Задание 7')
    root.geometry("300x400")
    root.configure(bg="#DEB887")
    root.resizable(width=False, height=False)

    names = ["идентификатор",
             "компанию",
             "год издания",
             "цвет",
             "цену"]

    param = list()

    i = 0
    for elem in names:
        Label(root, text=f"Введите {elem}:",
              bg="#DEB887").place(x=70, y=i + 25)
        elem = Entry(root)
        i += 50
        elem.place(x=70, y=i, width=150)
        param.append(elem)

    b = Button(root, text="Выполнить",
               command=lambda: execute_task7(cur, param, con),  bg="#F5F5DC")
    b.place(x=70, y=300, width=150)

    root.mainloop()


def task8(cur, con = None):
    # Информация:
    # https://postgrespro.ru/docs/postgrespro/10/functions-info
    cur.execute(
        "SELECT current_database(), current_user;")
    current_database, current_user = cur.fetchone()
    mb.showinfo(title="Информация",
                message=f"Имя текущей базы данных:\n{current_database}\nИмя пользователя:\n{current_user}")


def task9(cur, con):
    cur.execute(" \
        CREATE TABLE IF NOT EXISTS blacklist \
        ( \
            user_id INT, \
            FOREIGN KEY(user_id) REFERENCES users(id), \
            world_id INT, \
            FOREIGN KEY(world_id) REFERENCES world(id), \
            reason VARCHAR \
        ) ")

    con.commit()

    mb.showinfo(title="Информация",
                message="Таблица успешно создана!")


def task10(cur, con):
    root = Tk()

    root.title('Задание 10')
    root.geometry("400x300")
    root.configure(bg="#DEB887")
    root.resizable(width=False, height=False)

    names = ["идентификатор человека",
             "идентификатор мира",
             "причину"]

    param = list()

    i = 0
    for elem in names:
        Label(root, text=f"Введите {elem}:",
              bg="#DEB887").place(x=70, y=i + 25)
        elem = Entry(root)
        i += 50
        elem.place(x=115, y=i, width=150)
        param.append(elem)

    b = Button(root, text="Выполнить",
               command=lambda: execute_task10(cur, param, con),  bg="#F5F5DC")
    b.place(x=115, y=200, width=150)

    root.mainloop()