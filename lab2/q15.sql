--5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом. 
-- id невыполненных заказов товаров, у которых цена меньше 1000
SELECT 
    request_id, completed
FROM 
    requests
WHERE 
    EXISTS( SELECT 
                1 
            FROM 
                office_supplies
            WHERE 
                requests.office_supply_id = office_supplies.office_supply_id and price < 1000)
     and not completed 