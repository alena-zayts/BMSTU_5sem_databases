create table if not exists Departments
(
    Department_ID serial not null,
    Department_Name varchar(30) not null,
    Department_Size integer not null,
    City varchar(20) not null,
    Income numeric(11, 2) not null
);

create table if not exists Workers(
	Worker_ID serial not null,
	Department_ID integer not null,
	First_Name varchar(15) not null,
	Second_Name varchar(20) not null,
	Experience integer not null
);

create table if not exists Office_Supplies(
	Office_Supply_ID serial not null,
	Office_Supply_Name varchar(40) not null,
	Pack_Size integer not null,
	Price numeric(7, 2) not null,
	Weight numeric(4, 2) not null
);

create table if not exists Requests(
	Request_ID serial not null,
	Worker_ID integer not null,
	Office_Supply_ID integer not null,
	Amount integer not null,
	Completed boolean not null
);
