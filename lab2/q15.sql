-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY и предложения HAVING. 
-- Получить список товаров, среднее количество заказываемых единиц которых больше 
-- общего среднего количества заказываемых единиц

SELECT office_supply_id, AVG(amount) AS average_amount
FROM requests
GROUP BY office_supply_id 
HAVING AVG(amount) > ( SELECT AVG(amount) AS common_avg_amount 
 FROM requests) 

 ( SELECT AVG(amount) AS common_avg_amount 
 FROM requests) 
 
