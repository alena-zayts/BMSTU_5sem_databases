from faker import Faker
from random import randint, random, choice
import pandas as pd

# faker = Faker(locale="ru_RU")
faker = Faker()

workers_columns = ['WorkerID', 'DepartmentID', 'FirstName', 'SecondName', 'Experience']
departments_columns = ['DepartmentID', 'DepartmentName', 'DepartmentSize', 'City', 'Income']
office_supplies_columns = ['OfficeSupplyID', 'Name', 'PackSize', 'Price', 'Weight']
requests_columns = ['RequestID', 'WorkerID', 'OfficeSupplyID', 'Amount', 'Completed']

NDepartments = 1000
NWorkers = 10000
NOfficeSupplies = 1000
NRequests = 1000

DepartmentIDList = list(range(1, NDepartments + 1))
WorkerIDList = list(range(1, NDepartments + 1))
OfficeSuppliesIDList = list(range(1, NOfficeSupplies + 1))
RequestsIDList = list(range(1, NRequests + 1))

ExperienceLimits = [0, 80]
IncomeLimit = 1e9 - 1
PackSizeLimits = [1, 1000]
PriceLimit = 100000 - 1
WeightLimit = 100 - 1
AmountLimits = [1, 1000]
completed = [0, 1]

FirstNameMaxLen = 15
SecondNameMaxLen = 20
DepartmentNameMaxLen = 30
CityNameMaxLen = 20
OfficeSupplyNameMaxLen = 40


workers_filename = 'workers.csv'
departments_filename = 'departments.csv'
office_supplies_filename = 'office_supplies.csv'
requests_filename = 'requests.csv'

sep = ','

IncomeRound = 2


OfficeSupplyNameInitialList = [
    'Бумага для принтера',
    'Файлы для документов',
    'Папка регистратор (Сегрегатор)',
    'Папки для хранения и перемещения документов (папки с зажимами, скоросшиватели)',
    'Канцелярский степлер',
    'Скобы для степлера',
    'Дырокол',
    'Ножницы',
    'Канцелярский нож',
    'Лотки для бумаг (вертикальные и горизонтальные)',
    'Корзина для мусора',
    'Подставка для ручек',
    'Ручки для письма синие',
    'Ручки цветные, для подчёркивания и выделения в тексте',
    'Корректоры для текста',
    'Подставка для блока бумаги',
    'Настольный органайзер',
    'Калькулятор',
    'Линейка',
    'Ластик для карандаша',
    'Точилка для карандаша',
    'Чернографитовый карандаш',
    'Маркер для выделения текста',
    'Маркеры для досок или флипчарта',
    'Перманентные цветные маркеры',
    'Блок бумаги для записей и стикеры для заметок',
    'Закладки и разделители для папок в документы',
    'Канцелярские кнопки',
    'Канцелярские скрепки',
    'Гвоздики для доски',
    'Магниты для досок',
    'Бумага для флипчарта',
    'Клей ПВА и клей-карандаш',
    'Расшиватель скоб (Антистеплер)',
    'Канцелярская книга',
    'Почтовые конверты',
    'Биндеры (Зажимы для бумаги)',
    'Блокноты или записные книги',
    'Канцелярский и упаковочный скотч',
    'Доска для заметок',
    'Магнитная доска или флипчарт',
    'Чистящие средства для досок',
    'Настольные именные таблички',
    'Папки с файлами',
    'Папки для презентаций',
    'Портфели для документов или папки с отделениями',
    'Подкладка для письма',
    'Штампы и печати',
    'Штемпельная краска',
    'Бейджи для сотрудников',
]

OfficeSupplyNameInitialList = ['timestamp', ]

OfficeSupplyNameList = []
for i in range(NOfficeSupplies // len(OfficeSupplyNameInitialList)):
    for name in OfficeSupplyNameInitialList:
        OfficeSupplyNameList.append(f'{name}, тип {i}')


def generate_workers_and_departments():
    WorkersDf = pd.DataFrame(columns=workers_columns)
    DepartmentSizeDict = {DepartmentID: 0 for DepartmentID in DepartmentIDList}
    for WorkerID in WorkerIDList:
        DepartmentID = choice(DepartmentIDList)
        DepartmentSizeDict[DepartmentID] += 1
        FirstName, SecondName = faker.name().split()[:2]
        if len(FirstName) > FirstNameMaxLen:
            FirstName = FirstName[:FirstNameMaxLen]
        if len(SecondName) > SecondNameMaxLen:
            SecondName = FirstName[:SecondNameMaxLen]
        Experience = randint(ExperienceLimits[0], ExperienceLimits[1])
        Worker = [WorkerID, DepartmentID, FirstName, SecondName, Experience]
        WorkersDf = WorkersDf.append({workers_columns[i]: Worker[i]
                                      for i in range(len(workers_columns))}, ignore_index=True)
    WorkersDf.to_excel(workers_filename[:-3] + 'xls')
    WorkersDf = WorkersDf.drop(workers_columns[0], axis=1)
    WorkersDf.to_csv(workers_filename, sep=sep, header=False, index=False)

    DepartmentsDf = pd.DataFrame(columns=departments_columns)
    for DepartmentID in DepartmentIDList:
        Name = faker.bs()
        if len(Name) > DepartmentNameMaxLen:
            Name = Name[:DepartmentNameMaxLen]
        Size = DepartmentSizeDict[DepartmentID]
        City = faker.city()
        if len(City) > CityNameMaxLen:
            City = City[:CityNameMaxLen]
        Income = random() * IncomeLimit
        Department = [DepartmentID, Name, Size, City, round(Income, IncomeRound)]
        DepartmentsDf = DepartmentsDf.append({departments_columns[i]: Department[i]
                                              for i in range(len(departments_columns))}, ignore_index=True)
    DepartmentsDf.to_excel(departments_filename[:-3] + 'xls')
    DepartmentsDf = DepartmentsDf.drop(departments_columns[0], axis=1)
    DepartmentsDf.to_csv(departments_filename, sep=sep, header=False, index=False)


def generate_office_supplies():
    OfficeSuppliesDf = pd.DataFrame(columns=office_supplies_columns)
    for OfficeSupplyID in OfficeSuppliesIDList:
        Name = OfficeSupplyNameList[OfficeSupplyID - 1]
        if len(Name) > OfficeSupplyNameMaxLen:
            Name = Name[:OfficeSupplyNameMaxLen]
            print(len(Name))
        PackSize = randint(PackSizeLimits[0], PackSizeLimits[1])
        Price = random() * PriceLimit
        Weight = random() * WeightLimit + 0.01

        OfficeSupply = [OfficeSupplyID, Name, PackSize, Price, Weight]
        OfficeSuppliesDf = OfficeSuppliesDf.append({office_supplies_columns[i]: OfficeSupply[i]
                                      for i in range(len(office_supplies_columns))}, ignore_index=True)
    OfficeSuppliesDf.to_excel(office_supplies_filename[:-3] + 'xls')
    OfficeSuppliesDf = OfficeSuppliesDf.drop(office_supplies_columns[0], axis=1)
    OfficeSuppliesDf.to_csv(office_supplies_filename, sep=sep, header=False, index=False)


def generate_requests():
    RequestsDf = pd.DataFrame(columns=requests_columns)
    for RequestID in RequestsIDList:
        WorkerID = choice(WorkerIDList)
        OfficeSupplyID = choice(OfficeSuppliesIDList)
        Amount = randint(AmountLimits[0], AmountLimits[1])
        Completed = choice(completed)

        Request = [RequestID, WorkerID, OfficeSupplyID, Amount, Completed]
        RequestsDf = RequestsDf.append({requests_columns[i]: Request[i]
                                      for i in range(len(requests_columns))}, ignore_index=True)
    RequestsDf.to_excel(requests_filename[:-3] + 'xls')
    RequestsDf = RequestsDf.drop(requests_columns[0], axis=1)
    RequestsDf.to_csv(requests_filename, sep=sep, header=False, index=False)


if __name__ == "__main__":
    generate_workers_and_departments()
    generate_office_supplies()
    generate_requests()

#chcp 1251
# net user postgres /active:yes
# net user postgres 12345

# Пароль пользователя postgres: 4541

