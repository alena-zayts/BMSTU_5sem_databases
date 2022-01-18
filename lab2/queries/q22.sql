-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение
-- канцтовары, которых заказывают больше всего
WITH office_supplies_amounts AS (
    SELECT office_supply_id, SUM(amount) AS total_amount
    FROM requests
    GROUP BY office_supply_id 
   ), top_office_supplies AS (
    SELECT office_supply_id 
    FROM office_supplies_amounts
    WHERE total_amount >= (SELECT 0.9 * max(total_amount) FROM office_supplies_amounts)
   )
SELECT office_supply_id, office_supply_name
FROM office_supplies
WHERE office_supply_id IN (SELECT office_supply_id FROM top_office_supplies);

