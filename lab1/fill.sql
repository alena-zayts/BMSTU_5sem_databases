\copy departments (department_name, department_size, city, income) from '/Users/alena/Desktop/BMSTU_5sem_databases/lab1/departments.csv' delimiter ',' csv;
\copy workers (department_id, first_name, second_name, experience) from '/Users/alena/Desktop/BMSTU_5sem_databases/lab1/workers.csv' delimiter ',' csv;
\copy office_supplies (office_supply_name, pack_size, price, weight) from '/Users/alena/Desktop/BMSTU_5sem_databases/lab1/office_supplies.csv' delimiter ',' csv;
\copy requests (worker_id, office_supply_id, amount, completed) from '/Users/alena/Desktop/BMSTU_5sem_databases/lab1/requests.csv' delimiter ',' csv;

