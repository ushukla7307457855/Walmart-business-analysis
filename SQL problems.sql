DROP TABLE walmart_db
SELECT * FROM  walmart_db
SELECT COUNT(*) FROM walmart_db

--Q1 FIND DIFFERENT payment methods 
SELECT
payment_method,
COUNT(*)
FROM walmart_db 
GROUP BY payment_method

--Q2 FIND DISTINCT BRANCHES COUNT
SELECT COUNT(DISTINCT branch)
FROM walmart_db;

--Q3 FIND OUt differnet payment method and number of trasactions,number of quantity sold
SELECT 
payment_method,
COUNT(quantity) as number_of_sold_quantity,
COUNT(invoice_id)

FROM walmart_db
GROUP BY 1

--Q4IDENTIFY the highest rated category in each branch displaying the branch,category
SELECT* FROM

(SELECT 
branch,
 category ,
AVG(rating) AS avg_rating,
RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC ) as rank
FROM walmart_db
GROUP BY 1,2)
WHERE rank =1

--Q5 identify the busiest day for each branch based on the number of transctions
--date,branch,transactions,
SELECT* FROM
(
SELECT 
branch,
COUNT(*) as Transactions,
TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') AS DAY_name,
RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart_db
GROUP BY 1,3
)
WHERE rank=1

--Q6 Calculate the total quantity of items sold per payment method.list payment methods and total quantity

SELECT 
payment_method,
SUM(quantity) as number_of_sold_quantity
FROM walmart_db
GROUP BY 1

--Q7 Determine AVG,MIN& MAX rating of the products for each city ,
--list the city ,avg,rating,min rating and max rating
SELECT
city,
category,
AVG(rating) as avg_rating,
MIN(rating) AS min_rating,
MAX(rating) AS max_rating

FROM walmart_db
GROUP BY 1,2

--Q8 Calculate the total profit for each category by considering total_profit
--as (unit_price*quantity*profit_margin).
--List category and total_profit ,ordered from Highest to lowest profit

SELECT 
category,
SUM(unit_price*quantity*profit_margin) as total_profit
FROM walmart_db
GROUP BY 1

--Q9 DETERMINE the most common payment method for each branch
--display branch and the preferred_payment_method
WITH cte 
AS 
(SELECT 
branch,
payment_method,
COUNT(*) AS total_transactions,
RANK() OVER(PARTITION BY payment_method ORDER BY COUNT(*) DESC ) AS rank

FROM walmart_db
GROUP BY 1,2)
SELECT *FROM cte
WHERE rank =1

--Q9 Categories sales into group MORNING,AFTERNOON,EVENING
--FIND out each  of the shift and numbber of invoices

SELECT 
 branch,
 CASE  
    WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
	WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
	ELSE 'Evening'

	END day_time,
	COUNT(*)

FROM walmart_db
GROUP BY 1,2
ORDER BY 1,3

--****Q10 Identify 5 branches with highest decrease ration in revenue 
--compare to  the last year (current year 2023 and last year 2022)

--revenue decrrease ratio= last_rev -curr_rev/last_rev*100

--2022 SALES
WITH revenue_2022
AS
(SELECT 
branch,
SUM(total) as revenue

FROM walmart_db
WHERE EXTRACT (YEAR FROM TO_DATE(date,'DD/MM/YYYY'))=2022
GROUP BY 1
),

 revenue_2023
 AS
(SELECT 
branch,
SUM(total) as revenue

FROM walmart_db
WHERE EXTRACT (YEAR FROM TO_DATE(date,'DD/MM/YYYY'))=2023
GROUP BY 1
)

SELECT ls.branch,
ls.revenue as last_year_revenue,
cs.revenue as cr_year_revenue,
ROUND(
(ls.revenue-cs.revenue)::numeric/ls.revenue::numeric*100,2) AS rev_dec_ratio
FROM revenue_2022 as ls
JOIN 
revenue_2023  as cs
ON ls.branch=cs.branch
WHERE ls.revenue>cs.revenue
ORDER BY  4 DESC 

