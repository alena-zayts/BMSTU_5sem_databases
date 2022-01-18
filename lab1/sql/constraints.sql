alter table departments
add constraint pk_department_id primary key (department_id),
add constraint check_department_size check (department_Size between 0 and 100000),
add constraint check_income check (income between 0.00 and 999999999.99);

alter table workers
add constraint pk_worker_id primary key (worker_id),
add constraint fk_department_id foreign key (department_id) references departments (department_id),
add constraint check_experience check (experience between 0 and 80);

alter table office_supplies
add constraint pk_office_supply_id primary key (office_supply_id),
add constraint check_pack_size check (pack_size between 1 and 1000),
add constraint check_price check (price between 0.00 and 99999.99),
add constraint check_weight check (weight between 0.01 and 99.99);


alter table requests
add constraint pk_request_id primary key (request_id),
add constraint fk_worker_id foreign key (worker_id) references workers (worker_id),
add constraint fk_office_supply_id foreign key (office_supply_id) references office_supplies (office_supply_id),
add constraint check_amount check (amount between 1 and 1000),
add constraint movers_amount check (movers_amount between 1 and 10)







