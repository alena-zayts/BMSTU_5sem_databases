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


def create_workers(file_name):
    # Содает коллекцию объектов.
    # Загружая туда данные из файла file_name.
    file = open(file_name, 'r')
    workers = []

    for i, line in enumerate(file):
        arr = line.split(',')
        arr[0], arr[3] = int(arr[0]), int(arr[3])
        workers.append(Worker(i, *arr).get())

    return workers
