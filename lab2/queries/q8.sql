-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
-- тест min/max

SELECT MAX(experience) counted_max, MIN(experience) counted_min, 
 ( SELECT experience 
 FROM workers 
 WHERE experience >= ALL ( SELECT experience  FROM workers) LIMIT 1 ) AS my_max, 
 ( SELECT experience 
 FROM workers 
 WHERE experience <= ALL ( SELECT experience  FROM workers) LIMIT 1 ) AS my_min
FROM workers