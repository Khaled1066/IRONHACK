USE sakila;



#####Challenge 1######


SELECT product_id, salesperson_id, total_sales, RANK() OVER (
    PARTITION BY product_id
    ORDER BY total_sales DESC
) AS sales_rank
FROM sales;


#1. Rank films by their length and create an output table that includes the title, length, and rank columns only. 
#   Filter out any rows with null or zero values in the length column.

SELECT 
    title, 
    length, 
    RANK() OVER (ORDER BY length DESC) AS film_rank
FROM film
WHERE length IS NOT NULL AND length > 0;

#2. Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only.
#Filter out any rows with null or zero values in the length column.

SELECT title, length, rating,
RANK() OVER(
	partition by rating
	ORDER BY length DESC) film_rank
FROM film
WHERE length IS NOT NULL AND length > 0;


#3. Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, 
#as well as the total number of films in which they have acted.
#Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

-- Step 1: Create a CTE to count the number of films each actor has acted in
WITH actor_film_count AS (
    SELECT 
        fa.actor_id,
        COUNT(fa.film_id) AS total_films
    FROM film_actor fa
    GROUP BY fa.actor_id
),

-- Step 2: Create another CTE to find the actor who has acted in the most films for each film
film_top_actor AS (
    SELECT 
        f.title,
        fa.actor_id,
        afc.total_films,
        RANK() OVER (PARTITION BY f.film_id ORDER BY afc.total_films DESC) AS rank1
    FROM film f
    JOIN film_actor fa ON f.film_id = fa.film_id
    JOIN actor_film_count afc ON fa.actor_id = afc.actor_id
)

-- Step 3: Select the top-ranked actor for each film
SELECT 
    fta.title,
    a.first_name,
    a.last_name,
    fta.total_films
FROM film_top_actor fta
JOIN actor a ON fta.actor_id = a.actor_id
WHERE fta.rank1 = 1
ORDER BY fta.title;


###### Challenge 2 ######3
select * from rental;
#Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.

WITH monthly_active_customers AS(
	SELECT date_format(r.rental_date, '%Y-%m') as rental_month, count(DISTINCT r.customer_id) AS active_customers
    FROM rental r
    GROUP BY rental_month
    ORDER BY rental_month
	)
    SELECT * FROM monthly_active_customers;
    
#Step 2. Retrieve the number of active users in the previous month.
WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month, 
        COUNT(DISTINCT r.customer_id) AS active_customers
    FROM rental r
    GROUP BY rental_month
    ORDER BY rental_month
),
previous_month_active AS (
    SELECT 
        rental_month,
        active_customers,
        LAG(active_customers, 1) OVER (ORDER BY rental_month) AS prev_month_customers
    FROM monthly_active_customers
)
SELECT * FROM previous_month_active;

#Step 3: Calculate the percentage change in the number of active customers between the current and previous month
WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month, 
        COUNT(DISTINCT r.customer_id) AS active_customers
    FROM rental r
    GROUP BY rental_month
    ORDER BY rental_month
),
previous_month_active AS (
    SELECT 
        rental_month,
        active_customers,
        LAG(active_customers, 1) OVER (ORDER BY rental_month) AS prev_month_customers
    FROM monthly_active_customers
)
SELECT 
    rental_month,
    active_customers,
    prev_month_customers,
    ROUND(
        (active_customers - prev_month_customers) / prev_month_customers * 100, 2
    ) AS pct_change
FROM previous_month_active
WHERE prev_month_customers IS NOT NULL;


    




