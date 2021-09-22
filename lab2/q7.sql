-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов. 
-- Проверка вычисления среднего

SELECT 
AVG(total_amount) AS Automatic_AVG,
SUM(total_amount) / COUNT(office_supply_id) AS Calculated_AVG 
FROM ( 
SELECT office_supply_id, SUM(amount) AS total_amount 
 FROM requests 
 GROUP BY office_supply_id 
) as gba