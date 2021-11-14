from tasks import *
from tkinter import *

root = Tk()

task_names = ['Выполнить скалярный запрос.\n[название отдела по id]',
              'Выполнить запрос с несколькими соединениями\n[id заказа, имя сделавшего его сотрудника, название товара]',
              'Выполнить запрос с ОТВ(CTE) и оконными функциями',
              'Выполнить запрос к метаданным',
              'Вызвать скалярную функцию (написанную в третьей лабораторной работе)',
              'Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе)',
              'Вызвать хранимую процедуру (написанную в третьей лабораторной работе)',
              'Вызвать системную функцию или процедуру',
              'Создать таблицу в базе данных, соответствующую тематике БД',
              'Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY',
              ]


def window(cur, con):
    global root

    root.title('Лабораторная работа №6')
    root.geometry("1100x800")
    root.configure(bg="#F5F5DC")
    root.resizable(width=False, height=False)

    tasks = [task1, task2, task3, task4, task5,
             task6, task7, task8, task9, task10]

    for (index, i) in enumerate(range(75, 750, 150)):
        button = Button(text=task_names[index], width=35, height=2,
                        command=lambda a=index: tasks[a](cur, con),  bg="#DEB887")
        button.place(x=290, y=i)

        button = Button(text=task_names[index + 5], width=35, height=2,
                        command=lambda a=index + 5: tasks[a](cur, con),  bg="#DEB887")
        button.place(x=610, y=i)  # anchor="center")


    root.mainloop()