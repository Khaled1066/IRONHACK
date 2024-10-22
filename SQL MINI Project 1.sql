Use ironhack_gambling;

###Pregunta 01###
SELECT Title, FirstName, LastName, DateOfBirth FROM customer;

###Pregunta 02###
SELECT CustomerGroup, count(*) FROM customer group by CustomerGroup;

###Pregunta 03###
SELECT a.* , a.CurrencyCode
FROM customer c
JOIN account a ON c.CustId = a.CustId;

###Pregunta 04###
SELECT product, BetDate, SUM(Bet_Amt) AS total_bet_amount
FROM betting
GROUP BY product, BetDate
order by Product desc;


SELECT p.Product, b.BetDate, SUM(b.Bet_Amt) AS Daily_Amount
 FROM Product p
  INNER JOIN Betting b ON (b.ClassId=p.ClassId AND b.CategoryId=p.CategoryId)
  GROUP BY p.Product, b.BetDate
   ORDER BY p.Product, b.BetDate; 


###Pregunta 05###
SELECT product, 
       BetDate, 
       round(sum(Bet_Amt),2) AS total_bet_amount
FROM betting
WHERE product = 'Sportsbook' 
  AND BetDate >= '2012-11-01'
GROUP BY product, BetDate
ORDER BY BetDate;


SELECT p.Product, b.BetDate, SUM(b.Bet_Amt) AS Daily_Amount
 FROM Product p
  INNER JOIN Betting b ON (b.ClassId=p.ClassId AND b.CategoryId=p.CategoryId AND b.BetDate >= '2012-11-01' AND p.Product='Sportsbook')
  GROUP BY p.Product, b.BetDate
   ORDER BY p.Product, b.BetDate; 


###Pregunta 06###
SELECT a.CurrencyCode, c.CustomerGroup, p.Product, SUM(b.Bet_Amt) AS Daily_Amount
 FROM Product p
  INNER JOIN Betting b ON (b.ClassId=p.ClassId AND b.CategoryId=p.CategoryId AND b.BetDate > '2012-12-01')
  INNER JOIN Account a ON (b.AccountNo=a.AccountNo)
  INNER JOIN Customer c ON (c.CustId=a.CustId)
  GROUP BY a.CurrencyCode, c.CustomerGroup, p.Product
   ORDER BY a.CurrencyCode, c.CustomerGroup, p.Product; 

###Pregunta 07####   
    WITH cte_bet_cust AS(
 SELECT b.*,a.CustId
  FROM Betting b INNER JOIN Account a ON (b.AccountNo=a.AccountNo)
)
SELECT c.Title, c.FirstName, c.LastName, SUM(cte.Bet_Amt) AS Total_Amount
 FROM Customer c
  LEFT JOIN cte_bet_cust cte ON (c.CustId=cte.CustId AND cte.BetDate BETWEEN '2012-11-01' AND '2012-11-30')
  GROUP BY c.Title, c.FirstName, c.LastName
   ORDER BY Total_Amount DESC;

###Pregunta 08###
SELECT
    c.Title,
    c.FirstName,
    c.LastName,
    COUNT(DISTINCT b.Product) AS ProductCount
FROM
    Customer c
JOIN
    Account a ON c.CustId = a.CustId
JOIN
    Betting b ON a.AccountNo = b.AccountNo
GROUP BY
    c.Title, c.FirstName, c.LastName
having ProductCount > 1    
ORDER BY
    ProductCount DESC;
    
    
SELECT DISTINCT
    c.Title,
    c.FirstName,
    c.LastName
FROM
    Customer c
JOIN
    Account a ON c.CustId = a.CustId
JOIN
    Betting b ON a.AccountNo = b.AccountNo AND b.Product IN ('Sportsbook', 'Vegas')
ORDER BY
    c.LastName, c.FirstName;
    
    
###Pregunta 09###
    
SELECT DISTINCT
    c.Title,
    c.FirstName,
    c.LastName,
    COUNT(DISTINCT b.Product)
FROM
    Customer c
JOIN
    Account a ON c.CustId = a.CustId
JOIN
    Betting b ON a.AccountNo = b.AccountNo
WHERE 
    b.Bet_Amt > 0
GROUP BY
    c.Title, c.FirstName, c.LastName
HAVING
    COUNT(DISTINCT b.Product) = 1
    AND MAX(b.Product) = 'Sportsbook'
ORDER BY
    c.LastName, c.FirstName;


SELECT p.Product, SUM(b.Bet_Amt) AS Daily_Amount
 FROM Product p
  INNER JOIN Betting b ON (b.ClassId=p.ClassId AND b.CategoryId=p.CategoryId)
  GROUP BY p.Product
	ORDER BY p.Product;

###Pregunta 10###


WITH PlayerProductTotals AS (
    SELECT
        c.CustId,         -- Player's ID
        p.Product,        -- Product
        SUM(b.Bet_Amt) AS Total_Wagered  -- Total amount wagered on this product
    FROM
        Customer c
    JOIN
        Account a ON c.CustId = a.CustId
    JOIN
        Betting b ON a.AccountNo = b.AccountNo
    JOIN
        Product p ON (b.ClassId = p.ClassId AND b.CategoryId = p.CategoryId)
    WHERE
        b.Bet_Amt > 0  -- Filter for positive bet amounts
    GROUP BY
        c.CustId, p.Product  -- Group by player and product
)
SELECT 
    ppt.CustId,      -- Player's ID
    ppt.Product,     -- Favorite product
    ppt.Total_Wagered -- Total wagered on the favorite product
FROM 
    PlayerProductTotals ppt
JOIN (
    -- Find the maximum total wagered for each player
    SELECT
        CustId,
        MAX(Total_Wagered) AS MaxWagered
    FROM
        PlayerProductTotals
    GROUP BY
        CustId
) max_ppt ON ppt.CustId = max_ppt.CustId AND ppt.Total_Wagered = max_ppt.MaxWagered
ORDER BY
    ppt.CustId;
    
    
###Pregunta 11###

SELECT * FROM student;

SELECT student_name, GPA FROM student
ORDER BY GPA desc
limit 5; 


###Pregunta 12###
SELECT s.School_id, s.School_name, COUNT(st.Student_id) AS Number_Students
from School s
LEFT JOIN Student St ON s.School_id = st.School_id
GROUP BY s.School_id, s.School_name;



SELECT 
			s.student_name,
			s.GPA,
			sch.school_name,
            RANK() OVER(PARTITION BY sch.school_name ORDER BY s.GPA DESC) AS st_rank
	FROM student s
    JOIN
		school sch ON sch.school_id = s.school_id;

###Pregunta 13###
WITH RankedStudent AS (
	SELECT 
			s.student_name,
			s.GPA,
			sch.school_name,
            RANK() OVER(PARTITION BY sch.school_name ORDER BY s.GPA DESC) AS st_rank
	FROM student s
    JOIN
		school sch ON sch.school_id = s.school_id
)

SELECT 
	st_rank
    student_name,
    GPA,
    school_name
FROM 
    RankedStudent
WHERE 
    st_rank <= 3
ORDER BY 
    school_name, st_rank;

   

