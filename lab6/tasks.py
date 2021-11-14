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

    create_list_box(rows, "Задание 2", row='request_id      office_supply_name     worker_first_name')


def task3(cur, con = None):
    cur.execute("\
    with otv (first_name, department_id, department_size, income) \
    AS \
    ( \
        select workers.first_name, departments.department_id, departments.department_size, departments.income \
        from workers join departments on workers.department_id=departments.department_id \
    ) \
    SELECT first_name, department_id, department_size, income, avg(income) over(partition by department_size) avg_income_by_size \
    from otv \
    order by department_size;")
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
    root_1 = Tk()

    root_1.title('Задание 5')
    root_1.geometry("300x200")
    root_1.configure(bg="#DEB887")
    root_1.resizable(width=False, height=False)

    Label(root_1, text="  Введите department_id:", bg="#DEB887").place(
        x=75, y=50)
    department_id = Entry(root_1)
    department_id.place(x=75, y=85, width=150)

    b = Button(root_1, text="Выполнить",
               command=lambda arg1=cur, arg2=department_id: execute_task5(arg1, arg2),  bg="#F5F5DC")
    b.place(x=75, y=120, width=150)

    root_1.mainloop()

def task6(cur, con = None):
    root = Tk()

    root.title('Задание 6')
    root.geometry("300x200")
    root.configure(bg="#DEB887")
    root.resizable(width=False, height=False)

    Label(root, text="  Введите границы опыта:", bg="#DEB887").place(
        x=75, y=50)
    l_exp = Entry(root)
    l_exp.place(x=75, y=75, width=150)
    h_exp = Entry(root)
    h_exp.place(x=75, y=95, width=150)

    b = Button(root, text="Выполнить",
               command=lambda arg1=cur, arg2=l_exp, arg3=h_exp: execute_task6(arg1, arg2, arg3),  bg="#F5F5DC")
    b.place(x=75, y=120, width=150)

    root.mainloop()


def task7(cur, con=None):
    root_1 = Tk()

    root_1.title('Задание 7')
    root_1.geometry("300x200")
    root_1.configure(bg="#DEB887")
    root_1.resizable(width=False, height=False)

    Label(root_1, text="  Введите требуемый заработок:", bg="#DEB887").place(
        x=75, y=50)
    prize_for = Entry(root_1)
    prize_for.place(x=75, y=85, width=150)

    b = Button(root_1, text="Выполнить",
               command=lambda arg1=cur, arg2=prize_for: execute_task7(arg1, arg2),  bg="#F5F5DC")
    b.place(x=75, y=120, width=150)

    root_1.mainloop()


def task8(cur, con = None):
    cur.execute(
        "SELECT pg_postmaster_start_time();")
    time = cur.fetchone()[0].strftime("%Y-%m-%d %H:%M:%S")
    mb.showinfo(title="Информация",
                message=f"Время запуска сервера:\n{time}")


def task9(cur, con):
    cur.execute("drop table if exists banned_requests;")
    cur.execute(" \
        CREATE TABLE IF NOT EXISTS banned_requests \
        ( \
            banned_requests_id serial not null PRIMARY KEY, \
            request_id integer, \
            FOREIGN KEY (request_id) REFERENCES requests(request_id), \
            money_to_return INT, \
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

    names = ["номер заявки",
             "сумму на возврат",
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