USE sakila;
#####Challenge 1#####
#1.1 Determine the shortest and longest movie durations and name the values as max_duration and min_duration.
SELECT title, length
FROM film
WHERE length = (SELECT MAX(length) FROM film);

#1.2. Express the average movie duration in hours and minutes. Don't use decimals
SELECT 
    FLOOR(AVG(length) / 60) AS hours,
    MOD(ROUND(AVG(length)), 60) AS minutes
FROM film;

#2.1 Calculate the number of days that the company has been operating.
#Hint: To do this, use the rental table, and the DATEDIFF() function to subtract the earliest date in the rental_date column from the latest date.
SELECT DATEDIFF(MAX(return_date),MIN(rental_date))
FROM rental;

#2.2 Retrieve rental information and add two additional columns to show the month and weekday of the rental. Return 20 rows of results.
SELECT 
    rental_id,
    rental_date,
    customer_id,
    MONTHNAME(rental_date),
    DAYNAME(rental_date)
FROM rental
LIMIT 20;

#2.3 Bonus: Retrieve rental information and add an additional column called DAY_TYPE with values 'weekend' or 'workday', depending on the day of the week.
#Hint: use a conditional expression.



#3. You need to ensure that customers can easily access information about the movie collection. To achieve this, retrieve the film titles and their rental duration. If any rental duration value is NULL, replace it with the string 'Not Available'. Sort the results of the film title in ascending order.
#Please note that even if there are currently no null values in the rental duration column, the query should still be written to handle such cases in the future.
#Hint: Look for the IFNULL() function.

SELECT
	title,
	rental_duration,
    IFNULL(rental_duration, 'Not Available') as status
FROM film;



###Challenge 2####
SELECT * FROM film;
#1.1 The total number of films that have been released.
SELECT COUNT(distinct title) FROM film;

#1.2 The number of films for each rating.
SELECT rating , COUNT(distinct title) 
FROM film
group by rating;

#1.3 The number of films for each rating, sorting the results in descending order of the number of films.
SELECT rating , COUNT(distinct title) AS totals
FROM film
group by rating
ORDER BY totals DESC;

#2.1 The mean film duration for each rating, and sort the results in descending order of the mean duration.
SELECT rating , ROUND(AVG(length),2) as avg_length
FROM film
group by rating
ORDER BY avg_length DESC;


#2.2 Identify which ratings have a mean duration of over two hours in order to help select films for customers who prefer longer movies.
SELECT rating , ROUND(AVG(length),2) as avg_length
FROM film
group by rating
Having avg_length / 60 > 2
ORDER BY avg_length DESC;







