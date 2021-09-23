-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в
-- предложении WHERE. 

select * FROM requests
WHERE worker_id IN ( SELECT requests.worker_id 
 FROM workers LEFT OUTER JOIN requests 
 ON workers.worker_id = requests.worker_id 
 WHERE experience = 0
 AND amount > 10);
 
 
DELETE FROM requests
WHERE worker_id IN ( SELECT requests.worker_id 
 FROM workers LEFT OUTER JOIN requests 
 ON workers.worker_id = requests.worker_id 
 WHERE experience = 0
 AND amount > 10);
 
 
select * FROM requests
WHERE worker_id IN ( SELECT requests.worker_id 
 FROM workers LEFT OUTER JOIN requests 
 ON workers.worker_id = requests.worker_id 
 WHERE experience = 0
 AND amount > 10);