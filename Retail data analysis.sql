
--DATA PREPARATION & UNDERSTANDING
SELECT * FROM Customer
SELECT * FROM prod_cat_info
SELECT * FROM Transactions

--Q1. WHAT IS THE TOTAL NUMBER OF ROWS IN EACH 3 TABLES IN THE DATABASE?

SELECT COUNT (*) 
FROM Customer
UNION
SELECT COUNT (*) 
FROM Transactions
UNION
SELECT COUNT (*) 
FROM prod_cat_info

select sum(total) All_total from (select count(*) as total from [dbo].[Customer]union Allselect count(*) as total from [dbo].[prod_cat_info]union allselect count(*) as total from [dbo].[Transactions]) a



--Q2. WHAT IS THE TOTAL NUMBER OF TRANSACTIONS THAT HAVE A RETURN?

SELECT COUNT(DISTINCT transaction_id ) AS Return_transactions
FROM Transactions
WHERE Qty < 0

SELECT COUNT( DISTINCT transaction_id )FROM Transactions



/* Q3. AS YOU HAVE NOTICED THE DATES PROVIDE ACROSS THE DATASETS ARE NOT IN A CORRECT FORMAT. AS FIRST STEPS, CONVERT THE DATE
       VARIABLES INTO VALID DATE FORMATS BEFORE PROCEEDING AHEAD? */

SELECT CONVERT(date, DOB, 101)  as Correct_date from dbo.Customer
SELECT CONVERT(date, tran_date, 101) as Correct_date from dbo.Transactions

--Q4. WHAT IS THE TIME RANGE OF TRANSACTION DATA AVAILABLE FOR ANALYSIS? SHOW OUTPUT OF IN NUMBER OF DAYS YEARS AND DAYS?

SELECT DATEDIFF(yyyy, Min(tran_date),Max(tran_date)) AS range_in_year,
DATEDIFF(MM, Min(tran_date),Max(tran_date)) AS range_in_month,
 DATEDIFF(DD, Min(tran_date),Max(tran_date)) AS range_in_days
FROM Transactions



--Q5. WHICH PRODUCT CATEGORY DOES THE SUBCATEGORY 'DIY' BELONGS TO?

SELECT prod_cat, prod_subcat
FROM prod_cat_info
WHERE prod_subcat = 'DIY'


--DATA ANALYSIS

--Q1. WHICH CHANNEL IS MOSTLY USED FOR TRANSACTIONS?

SELECT TOP 1  store_type, COUNT(Store_type)
FROM Transactions
GROUP BY Store_type
ORDER BY COUNT(Store_type) DESC

--Q2. WHAT IS THE COUNT OF MALE AND FEMALE CUSTOMERS IN DATABASE?

SELECT Gender, COUNT(*) as No_of_cust FROM Customer as cust
GROUP BY Gender 

--Q3. FROM WHICH CITY WE HAVE MAXIMUM NUMBER OF CUSTOMERS AND HOW MANY ?

SELECT TOP 1 city_code, COUNT(city_code) as num_of_customers
FROM Customer
GROUP BY city_code
ORDER BY COUNT(city_code) DESC

-- Q4 HOW MANY SUB-CATEGORIES ARE THERE UNDER THE BOOKS CATEGORY?

SELECT prod_cat, COUNT(prod_subcat) As sub_Categories
FROM prod_cat_info
GROUP BY prod_cat
HAVING prod_cat = 'Books'

-- Q5 WHAT IS THE MAX QUANTITY OF PRODUCTS EVER ORDERED?

SELECT  MAX(Qty) As max_orders 
FROM Transactions 

-- Q6 WHAT IS THE NET TOTAL REVENUE GENERATED IN CATEGORIES ELECTRONICS & BOOKS? 

 SELECT p.prod_cat, ROUND(SUM(t.total_amt),2) As Total_rev_gen_in_elec_books
FROM Transactions As t
Inner Join prod_cat_info AS p
ON t.prod_subcat_code = p.prod_sub_cat_code
AND t.prod_cat_code = p.prod_cat_code
WHERE p.prod_cat IN ('Electronics' , 'Books') 
GROUP BY p.prod_cat

-- Q7 HOW MANY CUSTOMERS HAVE >10 TRANSACTIONS WITH US EXCLUDING RETURNS?

SELECT COUNT(*) AS total_count
FROM(
SELECT cust_id, COUNT(transaction_id) AS number_of_transactions
FROM Transactions
WHERE Qty >0 
GROUP BY cust_id
HAVING COUNT(cust_id) > 10
) AS t


Select cust_id, count(transaction_id) as Counts from Transactionswhere cust_id not in  (select distinct cust_id from Transactions where qty<0)group by cust_idhaving count(transaction_id)>10;

-- Q8 WHAT US THE COMBINED REVENUE EARNED FROM 'ELECTRONICS' & 'CLOTHING' CATEGORIES FROM "FLAGSHIP STORES"?

SELECT ROUND(SUM(total_amt),2) As Total_rev_elec_clothing
FROM Transactions As t
Inner Join prod_cat_info AS p
ON t.prod_cat_code = p.prod_cat_code
AND t.prod_subcat_code = p.prod_sub_cat_code
WHERE p.prod_cat IN ('Electronics' , 'Clothing') 
AND t.Store_type = 'Flagship Store'

/* Q9 WHAT IS THE TOTAL REVENUE GENERATED FROM 'MALE' CUSTOMERS IN 'ELECTRONICS' CATEGORY?
      OUTPUT SHOULD DISPLAY TOTAL REVENUE BY PROD SUB-CAT. */

SELECT p.prod_subcat,  SUM(total_amt) AS total_revnue
FROM Transactions AS t
LEFT JOIN Customer AS c
ON t.cust_id = c.customer_Id
LEFT JOIN prod_cat_info AS p
ON t.prod_cat_code = p.prod_cat_code
AND t.prod_subcat_code = p.prod_sub_cat_code
WHERE c.Gender = 'M' 
AND prod_cat IN ( 'Electronics')
GROUP BY p.prod_subcat


/* Q10 WHAT IS PERCENTAGE OF SALES AND RETURNS BY PROD SUB-CATE; DISPLAY ONLY TOP 5 SUB-CATE
       IN TERMS OF SALES? */

select
[Subcategory] = P.prod_subcat,
[Sales] =   Round(SUM(cast( case when T.Qty > 0 then total_amt else 0 end as float)),2) , 
[Returns] = Round(SUM(cast( case when T.Qty < 0 then total_amt else 0 end as float)),2) , 
[Profit] =  Round(SUM(cast(total_amt as float)),2) 
from Transactions as T
INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_sub_cat_code
group by P.prod_subcat

Select Top 5 prod_subcat,
Round(Sum(Cast(Case When Qty > 0 Then Qty Else 0 end as float)),2) Sales,
Round(Sum(Cast(Case When Qty < 0 Then Qty Else 0 end as Float)),2) asReturn,
Round(Sum(Cast(Case When Qty < 0 Then Qty Else 0 end as Float)),2)* 100/Round(Sum(Cast(Case When Qty > 0 Then Qty Else 0 end as float)),2) [asReturn%],
100 + Round(Sum(Cast(Case When Qty < 0 Then Qty Else 0 end as Float)),2)* 100/Round(Sum(Cast(Case When Qty > 0 Then Qty Else 0 end as float)),2) [Sales %]
from Transactions AS T
INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_sub_cat_code
group by prod_subcat
Order By [Sales %]

/* Q11 FOR ALL CUSTOMERS AGED B/W 25 TO 35 YEARS FIND WHAT IS THE NET TOTAL REVENUE
       GENERATED BY THESE CONSUMERS IN THE LAST 30 DAYS OF TRANSACTION FROM MAX TRANSACTION
	   DATE AVAILABLE IN THE DATA? */

SELECT  SUM(total_amt) AS total_revenue
FROM Transactions AS t
LEFT JOIN Customer AS c
ON t.cust_id = c.customer_Id
WHERE DATEDIFF(Year, [DOB], GETDATE() ) > 25
  AND DATEDIFF(Year, [DOB], GETDATE() ) < 35
  AND tran_date > = DATEADD(dd, -30, (SELECT MAX(tran_date) FROM transactions)) 


-- Q12 WHICH PRODUCT CATEGORY HAS SEEN THE MAX VALUE OF RETURNS IN THE LAST 3 MONTHS OF TRANSACTION?

SELECT TOP 1 COUNT(transaction_id) AS NUM_of_returns, p.prod_cat
FROM Transactions as t
INNER JOIN prod_cat_info AS p
ON t.prod_cat_code = p.prod_cat_code
 WHERE t.tran_date >= DATEADD(mm, -3, (SELECT MAX(tran_date) FROM Transactions) )
  AND Qty < 0
GROUP BY prod_cat
ORDER BY NUM_of_returns DESC

-- Q13 WHICH STORE-TYPE SELLS THE MAX PRODUCTS: BY VALUE OF SALES AMOUNT AND BY QUANTITY SOLD?

SELECT Store_type, SUM(total_amt) AS SALES_WISE, SUM(Qty) AS QTY_wise
FROM Transactions
GROUP BY Store_type
HAVING SUM(total_amt) >= ALL(SELECT SUM(total_amt) FROM Transactions GROUP BY Store_type)
AND SUM(Qty) >= ALL(SELECT SUM(Qty) FROM Transactions GROUP BY Store_type)
ORDER BY SALES_WISE DESC



-- Q14 WHAT ARE THE CATEGORIES FOR WHICH AVERAGE REVENUE IS ABOVE THE OVERALL AVERAGE?

SELECT * FROM prod_cat_info
SELECT * FROM Transactions
SELECT * FROM Customer

SELECT AVG(total_amt) AS cat_avg, prod_cat
FROM Transactions AS t
INNER JOIN prod_cat_info AS p
on t.prod_cat_code = p.prod_cat_code
AND t.prod_subcat_code = p.prod_sub_cat_code
GROUP BY prod_cat
HAVING AVG(total_amt) > (SELECT AVG(total_amt) FROM Transactions)



/* Q15 FIND THE AVERAGE & TOTAL REVENUE BY EACH SUBCATEGORY FOR THE CATEGORIES WHICH ARE AMONG TOP 5 CATEGORES IN TERMS OF 
       QUANTITY SOLD? */

SELECT AVG(total_amt) AS AVERAGE, SUM(total_amt) AS SUM, prod_subcat
FROM Transactions AS t
INNER JOIN prod_cat_info AS p
ON t.prod_subcat_code = p.prod_sub_cat_code
AND t.prod_cat_code = p.prod_cat_code
WHERE Qty > 0
GROUP BY prod_subcat
HAVING SUM(Qty) > ALL (SELECT TOP 5 SUM(Qty) FROM Transactions WHERE Qty > 0 GROUP BY prod_cat_code ORDER BY SUM(Qty) DESC) 
