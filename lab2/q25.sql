--25. Оконные фнкции для устранения дублей
--Придумать запрос, в результате которого в данных появляются полные дубли. 
--Устранить дублирующиеся строки с использованием функции ROW_NUMBER()

with duplicated as (
select * 
from workers
where experience between 10 and 30
union all
select * 
from workers
where experience between 20 and 40)
select *
from (select worker_id, second_name, experience, row_number() over (partition by worker_id) as rn 
from duplicated) dpl
where dpl.rn=1
order by experience