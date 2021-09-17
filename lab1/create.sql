create table if not exists Departments
(
    DepartmentID serial primary key,
    DepartmentName varchar(30) not null,
    DepartmentSize integer check (DepartmentSize between 0 and 10000),
    City varchar(20) not null,
    Income numeric(9, 2) check (Income between 0 and 1000000000)
);

create table if not exists Workers(
	WorkerID serial primary key,
	DepartmentID integer references Departments(DepartmentID),
	FirstName varchar(15) not null,
	SecondName varchar(20) not null,
	Experience integer check (Experience between 0 and 80)
);

create table if not exists OfficeSupplies(
	OfficeSupplyID serial primary key,
	OfficeSupplyName varchar(40) not null,
	PackSize integer check (PackSize between 1 and 1000),
	Price numeric(5, 2) check (Price between 0 and 10000),
	Weight numeric(2, 2) check (Price between 0 and 100)
);

create table if not exists Requests(
	RequestID serial primary key,
	WorkerID integer references Workers(WorkerID),
	DepartmentID integer references Departments(DepartmentID),
	Amount integer check (Amount between 1 and 1000),
	Completed boolean
);


--drop table requests;
--drop table workers;
--drop table departments;
--drop table officesupplies;


--copy Departments(DepartmentName, DepartmentSize, City, Income) from 'C:\Users\alena\Desktop\BMSTU_5sem_databases\lab1\departments.csv' delimiter ',' csv;


----alter table food add constraint name check (not null);
----insert into people(name, sex, age) values('Winterpuma', 'f', 18);
--select * from people where name = 'Winterpuma';

--select * from people;
--select * from food_category;
--select * from food;
--select * from diet;
--select name, kcal from food

--drop table food;
--drop table food_category;