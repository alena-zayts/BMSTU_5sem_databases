from tkinter import *
from tkinter import messagebox as mb


def create_list_box(rows, title, count=15, row=None):
    root = Tk()

    root.title(title)
    root.resizable(width=False, height=False)

    size = (count + 3) * len(rows[0]) + 1

    list_box = Listbox(root, width=size, height=22,
                       font="monospace 10", bg="#DEB887", highlightcolor='#DEB887',
                       selectbackground='#98ff98', fg="#98ff98")

    list_box.insert(END, "█" * size)

    if row:
        list_box.insert(END, row)

    for row in rows:
        string = (("█ {:^" + str(count) + "} ") * len(row)).format(*row) + '█'
        list_box.insert(END, string)

    list_box.insert(END, "█" * size)

    list_box.grid(row=0, column=0)

    root.configure(bg="#DEB887")

    root.mainloop()


def execute_task1(cur, department_id):
    try:
        department_id = int(department_id.get())
    except:
        mb.showerror(title="Ошибка", message="Введите целое число!")
        return

    cur.execute(" \
        SELECT department_name \
        FROM departments \
        WHERE department_id= %s", (department_id,))

    row = cur.fetchone()

    mb.showinfo(title="Результат",
                message=f"Название отдела с department_id={department_id}: '{row[0]}'")


def execute_task4(cur, table_name, con):
    table_name = table_name.get()

    try:
        cur.execute(f"SELECT *, pg_size_pretty(pg_relation_size(indexrelname::text)) \
        FROM pg_stat_all_indexes \
        WHERE relname = '{table_name}';")
    except:
        # Откатываемся.
        con.rollback()
        mb.showerror(title="Ошибка", message="Такой таблицы не существует!")
        return

    rows = cur.fetchall()
    row = '           '.join(list(elem[0] for elem in cur.description))
    # create_list_box(rows, "Задание 3")
    # rows = [(elem[0],) for elem in cur.description]

    create_list_box(rows, "Задание 4", 17, row=row)

def execute_task5(cur, department_id):
    try:
        department_id = int(department_id.get())
    except:
        mb.showerror(title="Ошибка", message="Введите целое число!")
        return

    cur.execute(f"SELECT get_max_experience_in_department({department_id}) AS max_experience;")
    row = cur.fetchone()

    mb.showinfo(title="Результат",
                message=f"Максимальный опыт в отделе {department_id}: {row[0]}")




def execute_task6(cur, l_exp, h_exp):
    l_exp = l_exp.get()
    h_exp = h_exp.get()
    try:
        l_exp = int(l_exp)
        h_exp = int(h_exp)
    except:
        mb.showerror(title="Ошибка", message="Введите целые числа")
        return

    cur.execute(f"select * from get_experience_info({l_exp}, {h_exp})")

    rows = cur.fetchall()
    row = '       '.join(list(elem[0] for elem in cur.description))

    create_list_box(rows, "Задание 6", 17, row=row)


def execute_task7(cur, proze_for):
    try:
        proze_for = int(proze_for.get())
    except:
        mb.showerror(title="Ошибка", message="Введите целое число")
        return

    cur.execute("drop table if exists workers_copy;")
    cur.execute("drop table if exists departments_copy;")
    cur.execute("SELECT worker_id, department_id, experience "
                "INTO TEMP workers_copy "
                "FROM workers "
                "where department_id between 1 and 5;")
    cur.execute("SELECT department_id, income "
                "INTO TEMP departments_copy "
                "FROM departments "
                "where department_id between 1 and 5;")

    # cur.execute(f"select * "
    #             f"from workers_copy inner join departments_copy "
    #             f"on workers_copy.department_id = departments_copy.department_id "
    #             f"order by worker_id;")
    #
    # rows = cur.fetchall()
    # row = '       '.join(list(elem[0] for elem in cur.description))
    #
    # create_list_box(rows, "Задание 7 (до)", 17, row=row)

    cur.execute(f"CALL prize({proze_for});")

    cur.execute(f"select * "
                f"from workers_copy inner join departments_copy "
                f"on workers_copy.department_id = departments_copy.department_id "
                f"order by worker_id;")

    rows = cur.fetchall()
    row = '       '.join(list(elem[0] for elem in cur.description))

    create_list_box(rows, "Задание 7 (после)", 17, row=row)




def execute_task10(cur, param, con):
    try:
        request_id = int(param[0].get())
        money = int(param[1].get())
        reason = param[2].get()
    except:
        mb.showerror(title="Ошибка", message="Некорректные параметры!")
        return

    cur.execute(
        "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='banned_requests'")

    if not cur.fetchone():
        mb.showerror(title="Ошибка", message="Таблица не создана!")
        return

    try:
        cur.execute("INSERT INTO banned_requests (request_id, money_to_return, reason) VALUES(%s, %s, %s)",
                    (request_id, money, reason))
    except:
        mb.showerror(title="Ошибка!", message="Ошибка запроса!")
        # Откатываемся.
        con.rollback()
        return

    # Фиксируем изменения.
    con.commit()

    mb.showinfo(title="Информация!", message="Получилось")