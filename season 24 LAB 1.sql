USE sakila;
#Display all available tables in the Sakila database.
SHOW TABLES;
#Retrieve all the data from the tables actor, film and customer.
SELECT * FROM actor;
SELECT * FROM film;
SELECT * FROM customer;
#3.1 Titles of all films from the film table
SELECT title FROM film;
#3.2 List of languages used in films, with the column aliased as language from the language table
SELECT * FROM language; 
SELECT name as language FROM language;
#3.3 List of first names of all employees from the staff table
SELECT first_name FROM staff;
#Retrieve unique release years.
SELECT DISTINCT release_year
FROM film;
#5.1 Determine the number of stores that the company has
SELECT COUNT(DISTINCT store_id)
FROM store;
#5.2 Determine the number of employees that the company has.
SELECT COUNT(DISTINCT staff_id)
FROM staff;
#5.3 Determine how many films are available for rent and how many have been rented.
SELECT * FROM rental;
SELECT
  (SELECT COUNT(*) 
   FROM inventory i
   LEFT JOIN rental r
     ON i.inventory_id = r.inventory_id AND r.return_date IS NULL
   WHERE r.rental_id IS NULL) AS available_for_rent,
   
  (SELECT COUNT(DISTINCT inventory_id)
   FROM rental) AS rented_films;

#5.4 Determine the number of distinct last names of the actors in the database.
SELECT COUNT(DISTINCT last_name)
FROM actor;


#Retrieve the 10 longest films.
SELECT * FROM film ORDER BY rental_duration DESC LIMIT 10;

#Retrieve all actors with the first name "SCARLETT"
SELECT * FROM actor
WHERE first_name = "SCARLETT";

