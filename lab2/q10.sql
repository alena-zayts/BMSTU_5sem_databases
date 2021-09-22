-- 10. Инструкция SELECT, использующая поисковое выражение CASE.


SELECT worker_id, experience,
 CASE 
 WHEN experience < 10 THEN 'junior' 
 WHEN experience < 30 THEN 'middle' 
 WHEN experience < 70 THEN 'senior' 
 ELSE 'GOD' 
 END AS status 
FROM workers