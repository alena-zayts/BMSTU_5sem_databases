-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3. 
-- большие заказы дорогих товаров от сотрудников из богатых отделов

SELECT income, amount, price
FROM ((
        SELECT office_supply_id, department_id, income, amount
        FROM (( 
                SELECT workers.worker_id, workers.department_id, departments.income
                FROM (workers JOIN departments ON workers.department_id = departments.department_id) 
                WHERE income > 10000000
        ) AS  from_rich_department
        JOIN requests ON requests.worker_id = from_rich_department.worker_id)
        WHERE requests.amount > 200
    ) AS from_rich_and_a_lot
    join office_supplies ON office_supplies.office_supply_id = from_rich_and_a_lot.office_supply_id)
    WHERE price > 10000