-- 3. Инструкция SELECT, использующая предикат LIKE.
-- названия ручек и карандашей 
SELECT office_supply_name
FROM office_supplies
WHERE LOWER(office_supply_name) LIKE '%pen' OR LOWER(office_supply_name) LIKE '%pencil' 