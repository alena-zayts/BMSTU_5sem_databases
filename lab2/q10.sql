-- 9. Инструкция SELECT, использующая простое выражение CASE. 
-- сколько останется лишних

SELECT office_supply_name, amount, pack_size,
	CASE (amount % pack_size)
    WHEN 0 THEN 'perfect'
    ELSE CAST((pack_size - (amount % pack_size)) AS varchar(10)) || ' left'
	END AS lefts
FROM requests JOIN office_supplies ON requests.office_supply_id = office_supplies.office_supply_id
order by lefts desc 