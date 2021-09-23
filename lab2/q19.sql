--19. Инструкция UPDATE со скалярным подзапросом в предложении SET. 
UPDATE requests 
SET amount = ( SELECT AVG(amount) 
 FROM requests 
 WHERE office_supply_id between 1 and 1000) 
WHERE office_supply_id = 1000;

SELECT *
from requests
where office_supply_id = 1000