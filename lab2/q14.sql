--14. Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY, но без предложения HAVING. 
-- для каждого товара получить суммарное количество заказанных единиц, количество заказов


SELECT office_supplies.office_supply_name,
sum(requests.amount) as sum_amount,
count(office_supplies.office_supply_name) as amount_of_orders,
avg(requests.amount) as counted_avg
FROM requests LEFT OUTER JOIN office_supplies ON office_supplies.office_supply_id = requests.office_supply_id 
GROUP BY requests.office_supply_id, office_supplies.office_supply_name
