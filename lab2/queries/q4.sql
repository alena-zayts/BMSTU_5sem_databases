-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом. 
-- id запроса и его завершенность для: 
-- запросов, сделанных сотрудниками c опытом более 10 лет
SELECT request_id, completed
FROM requests
WHERE worker_id IN (SELECT worker_id 
 FROM workers 
 WHERE experience > 10) 
ORDER BY completed 