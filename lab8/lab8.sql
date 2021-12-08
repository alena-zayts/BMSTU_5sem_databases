DROP TABLE if exists nifi_workers cascade;

create table if not exists nifi_workers(
	Worker_ID integer primary key,
	Department_ID integer not null,
	First_Name varchar(15) not null,
	Second_Name varchar(20) not null,
	Experience integer not null
);

select * from nifi_workers;


DROP TABLE if exists nifi_log;

--логирование записей
CREATE TABLE nifi_log(
    id Serial PRIMARY KEY,
    worker_id INTEGER NOT NULL,
    event_type varchar(16) NOT NULL,
    event_date DATE NOT NULL,
    event_time TIME NOT NULL,
    FOREIGN KEY(worker_id) REFERENCES nifi_workers(worker_id)
);



CREATE or replace FUNCTION nifi_insert_trigger_proc() RETURNS trigger AS $emp_stamp$
    begin
	    INSERT INTO nifi_log(worker_id, event_type, event_date, event_time)
	    VALUES (new.worker_id, 'Insert', (SELECT CURRENT_DATE), (SELECT CURRENT_TIME));
        RETURN NEW;
    END;
$emp_stamp$ LANGUAGE plpgsql;




CREATE TRIGGER nifi_insert_trigger
AFTER INSERT
    ON nifi_workers
    FOR EACH row
    	EXECUTE PROCEDURE nifi_insert_trigger_proc();

INSERT INTO nifi_workers(worker_id, Department_ID, First_Name, Second_Name, Experience)
VALUES(1, 1, 'me', 'again', 10000);

select *
from nifi_workers
order by  worker_id;

select *
from nifi_log
order by  event_date, event_time;


