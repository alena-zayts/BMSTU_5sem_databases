from faker import Faker
from random import randint, random, choice
import pandas as pd
from random import uniform
from random import choice

faker = Faker(locale="ru_RU")
faker = Faker()

NDepartments = 1000
NWorkers = 5000
ExperienceLimits = [0, 80]
IncomeLimit = 1e9

DepartmentIDList = list(range(1, NDepartments + 1))
WorkerIDList = list(range(1, NDepartments + 1))

sex = ['m', 'f']

workers_filename = 'workers.csv'
departments_filename = 'departments.csv'
products_filename = 'products.csv'
requests_filename = 'requests.csv'

sep = ','

workers_columns = ['WorkerID', 'DepartmentID', 'FirstName', 'SecondName', 'Experience']
departments_columns = ['DepartmentID', 'Name', 'Size', 'City', 'Income']


def generate_workers_and_departments():
    WorkersDf = pd.DataFrame(columns=workers_columns)
    DepartmentSizeDict = {DepartmentID: 0 for DepartmentID in DepartmentIDList}
    for WorkerID in WorkerIDList:
        DepartmentID = choice(DepartmentIDList)
        DepartmentSizeDict[DepartmentID] += 1
        FirstName, SecondName = faker.name().split()[:2]
        Experience = randint(ExperienceLimits[0], ExperienceLimits[1])

        Worker = [WorkerID, DepartmentID, FirstName, SecondName, Experience]
        WorkersDf = WorkersDf.append({workers_columns[i]: Worker[i]
                                      for i in range(len(workers_columns))}, ignore_index=True)
    WorkersDf.to_excel(workers_filename[:-3] + 'xls')
    WorkersDf.to_csv(workers_filename, sep=sep)

    DepartmentsDf = pd.DataFrame(columns=departments_columns)
    for DepartmentID in DepartmentIDList:
        Name = faker.bs()
        Size = DepartmentSizeDict[DepartmentID]
        City = faker.city()
        Income = random() * IncomeLimit
        Department = [DepartmentID, Name, Size, City, Income]
        DepartmentsDf = DepartmentsDf.append({departments_columns[i]: Department[i]
                                              for i in range(len(departments_columns))}, ignore_index=True)
    DepartmentsDf.to_excel(departments_filename[:-3] + 'xls')
    DepartmentsDf.to_csv(departments_filename, sep=sep)


if __name__ == "__main__":
    generate_workers_and_departments()
