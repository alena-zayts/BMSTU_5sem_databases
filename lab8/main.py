# https://nifi.apache.org/docs/nifi-docs/html/getting-started.html
# http://localhost:8080/nifi


from faker import Faker
from random import randint, choice
import datetime
import time
import json


class device():
    # Структура полностью соответствует таблице device.
    id = int()
    company = str()
    year_of_issue = int()
    color = str()
    price = int()

    def __init__(self, id, company, year_of_issue, color, price):
        self.id = id
        self.company = company
        self.year_of_issue = year_of_issue
        self.color = color
        self.price = price

    def get(self):
        return {'id': self.id, 'company': self.company, 'year_of_issue': self.year_of_issue,
                'color': self.color, 'price': self.price}

    def __str__(self):
        return f"{self.id:<2} {self.company:<20} {self.year_of_issue:<5} {self.color:<5} {self.price:<15}"

class Worker:
    worker_id = int()
    department_id = int()
    first_name = str()
    second_name = str()
    experience = int()

    def __init__(self, worker_id, department_id, first_name, second_name, experience):
        self.worker_id = worker_id
        self.department_id = department_id
        self.first_name = first_name
        self.second_name = second_name
        self.experience = experience

    def get(self):
        return {'worker_id': self.worker_id, 'department_id': self.department_id, 'first_name': self.first_name,
                'second_name': self.second_name, 'experience': self.experience}

    def __str__(self):
        return f"{self.worker_id:<5} {self.department_id:<5} " \
               f"{self.first_name:<15} {self.second_name:<15} {self.experience:<5}"


def main():
    faker = Faker()  # faker.name()
    i = 0

    while True:
        firstName, SecondName = faker.name().split()[:2]
        obj = Worker(i, randint(0, 100), firstName, SecondName, randint(0, 80))


        file_name = "C:/nifi-1.15.0-bin/nifi-1.15.0/data/worker_" + str(i) + "_" + \
                    str(datetime.datetime.now().strftime("%d-%m-%Y_%H_%M_%S")) + ".json"

        print(file_name)

        with open(file_name, "w") as f:
            print(json.dumps(obj.get()), file=f)

        i += 1
        time.sleep(5)
    # faker = Faker()  # faker.name()
    # color = ["blue", "red", "purple", "yellow",
    #          "pink", "green", "black", "white", "coral", "gold", "silver"]
    # i = 0
    #
    # while True:
    #     obj = device(i, faker.name(), randint(2000, 2120), choice(color), randint(0, 100000))
    #
    #     # print(obj)
    #     # print(json.dumps(obj.get()))
    #
    #     file_name = "data/device_" + str(i) + "_" + \
    #                 str(datetime.datetime.now().strftime("%d-%m-%Y_%H:%M:%S")) + ".json"
    #
    #     print(file_name)
    #
    #     with open(file_name, "w") as f:
    #         print(json.dumps(obj.get()), file=f)
    #
    #     i += 1
    #     time.sleep(10)


if __name__ == "__main__":
    main()