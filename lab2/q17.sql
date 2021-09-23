-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу
-- результирующего набора данных вложенного подзапроса.
-- вставится много строк

INSERT INTO requests (worker_id, office_supply_id, amount, completed, movers_amount) 
SELECT ( SELECT MAX(worker_id) 
 FROM workers 
 WHERE experience = 0), 
 office_supply_id, 1, false, 1
FROM office_supplies
WHERE office_supply_name like '%pen'


SELECT *
from requests