create table if not exists Departments
(
    Department_ID integer not null,
    Department_Name varchar(30) not null,
    Department_Size integer not null,
    City varchar(20) not null,
    Income numeric(9, 2) not null
);

create table if not exists Workers(
	Worker_ID integer not null,
	Department_ID integer not null,
	First_Name varchar(15) not null,
	Second_Name varchar(20) not null,
	Experience integer not null
);

create table if not exists Office_Supplies(
	Office_Supply_ID integer not null,
	Office_Supply_Name varchar(40) not null,
	Pack_Size integer not null,
	Price numeric(5, 2) not null,
	Weight numeric(2, 2) not null
);

create table if not exists Requests(
	Request_ID integer not null,
	Worker_ID integer not null,
	Office_Supply_ID integer not null,
	Amount integer not null,
	Completed boolean not null
);





--

--select * from people where name = 'Winterpuma';

--select * from people;
--select * from food_category;
--select * from food;
--select * from diet;
--select name, kcal from food
