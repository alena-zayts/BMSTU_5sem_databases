from tkinter import *
from tkinter import messagebox as mb


def create_list_box(rows, title, count=15):
    root = Tk()

    root.title(title)
    root.resizable(width=False, height=False)

    size = (count + 3) * len(rows[0]) + 1

    list_box = Listbox(root, width=size, height=22,
                       font="monospace 10", bg="#DEB887", highlightcolor='#DEB887',
                       selectbackground='#59405c', fg="#59405c")

    list_box.insert(END, "█" * size)

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
        cur.execute(f"SELECT * FROM {table_name}")
    except:
        # Откатываемся.
        con.rollback()
        mb.showerror(title="Ошибка", message="Такой таблицы нет!")
        return

    rows = [(elem[0],) for elem in cur.description]

    create_list_box(rows, "Задание 4", 17)


def execute_task6(cur, user_id):
    user_id = user_id.get()
    print(user_id)
    try:
        user_id = int(user_id)
    except:
        mb.showerror(title="Ошибка", message="Введите число!")
        return

    # get_user - Подставляемая табличная функция.
    # Возвращает пользователя по id.
    cur.execute("SELECT * FROM get_user(%s)", (user_id,))

    rows = cur.fetchone()

    create_list_box((rows,), "Задание 6", 17)


def execute_task7(cur, param, con):
    try:
        device_id = int(param[0].get())
        company = param[1].get()
        year_of_issue = int(param[2].get())
        color = param[3].get()
        price = int(param[4].get())
    except:
        mb.showerror(title="Ошибка", message="Некорректные параметры!")
        return

    if year_of_issue < 2000 or year_of_issue > 2120 or price < 0 or price > 100000:
        mb.showerror(title="Ошибка", message="Неподходящие значения!")
        return

    print(device_id, company, year_of_issue, color, price)

    # Выполняем запрос.
    try:
        cur.execute("CALL insert_device(%s, %s, %s, %s, %s);",
                    (device_id, company, year_of_issue, color, price))
    except:
        mb.showerror(title="Ошибка", message="Некорректный запрос!")
        # Откатываемся.
        con.rollback()
        return

    # Фиксируем изменения.
    # Т.е. посылаем команду в бд.
    # Метод commit() помогает нам применить изменения,
    # которые мы внесли в базу данных,
    # и эти изменения не могут быть отменены,
    # если commit() выполнится успешно.
    con.commit()

    mb.showinfo(title="Информация!", message="Девайс добавлен!")


def execute_task10(cur, param, con):
    try:
        user_id = int(param[0].get())
        world_id = int(param[1].get())
        reason = param[2].get()
    except:
        mb.showerror(title="Ошибка", message="Некорректные параметры!")
        return

    print(user_id, world_id, reason)

    cur.execute(
        "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='blacklist'")

    if not cur.fetchone():
        mb.showerror(title="Ошибка", message="Таблица не создана!")
        return

    try:
        cur.execute("INSERT INTO blacklist VALUES(%s, %s, %s)",
                    (user_id, world_id, reason))
    except:
        mb.showerror(title="Ошибка!", message="Ошибка запроса!")
        # Откатываемся.
        con.rollback()
        return

    # Фиксируем изменения.
    con.commit()

    mb.showinfo(title="Информация!", message="Нарушитель добавлен!")