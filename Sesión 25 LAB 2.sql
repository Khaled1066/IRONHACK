USE sakila;


#1.  Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT 
    f.title, 
    s.store_id, 
    COUNT(i.inventory_id) AS available_copies
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN store s ON i.store_id = s.store_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id AND r.return_date IS NULL
WHERE f.title = 'Hunchback Impossible'
  AND r.rental_id IS NULL
GROUP BY f.title, s.store_id;

#2.  List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT title, length
FROM Film
WHERE length > (SELECT AVG(length) FROM Film);

#3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT a.first_name, a.last_name
FROM actor a
WHERE a.actor_id IN (
    SELECT fa.actor_id
    FROM film_actor fa
    WHERE fa.film_id = (
        SELECT f.film_id
        FROM film f
        WHERE f.title = 'Alone Trip'
    )
);

####BONUS#####
#4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film f
WHERE f.film_id IN (
	SELECT fc.film_id
    FROM film_category fc
    WHERE fc.category_id = (
		SELECT c.category_id
        FROM category c
        WHERE c.name = "Family"
	)
);

