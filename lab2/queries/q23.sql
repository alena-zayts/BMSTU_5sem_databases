-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.

-- Определение ОТВ
with recursive orders(office_supply_id, n) as (
 -- Определение закрепленного элемента
SELECT office_supply_id, 1 as prev_amount
 FROM office_supplies
 where office_supply_id < 10
  -- Определение рекурсивного элемента
union all 
select office_supply_id, n+1 
from orders 
where n < 5
)
-- Инструкция, использующая ОТВ
select * 
from orders