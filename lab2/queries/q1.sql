-- 1. Инструкция SELECT, использующая предикат сравнения. 
-- id запросы и количество грузчиков для: еще не выполненных запросов, для которых хватит 3 грузчиков
SELECT request_id, movers_amount
FROM requests
WHERE NOT completed AND movers_amount <= 3
ORDER BY movers_amount, request_id ASC 