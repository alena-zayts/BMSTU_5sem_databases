-- 18. Простая инструкция UPDATE. 
UPDATE requests 
SET amount = 1 
WHERE completed;

SELECT *
from requests
where completed and amount != 1