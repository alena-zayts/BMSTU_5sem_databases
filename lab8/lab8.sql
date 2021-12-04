DROP TABLE if exists nifi_workers;

create table if not exists nifi_workers(
	Worker_ID integer primary key,
	Department_ID integer not null,
	First_Name varchar(15) not null,
	Second_Name varchar(20) not null,
	Experience integer not null
);

select * from nifi_workers;

INSERT INTO nifi_workers(worker_id, Department_ID, First_Name, Second_Name, Experience)
VALUES(1, 1, 'me', 'again', 10000);

select *
from nifi_workers
order by  worker_id;

--delete from lab_08_nifi.device where id < 100;

-- {
--     "id": 1,
--     "company": "OOO First",
--     "year_of_issue": 2000,
--     "color": "blue",
--     "price": 10000
-- }