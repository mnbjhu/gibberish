SELECT 
  username AS name,
  * AS user
FROM users
WHERE user.id <= 123 
ORDER BY name;
