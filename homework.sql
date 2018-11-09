USE sakila;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, ' ', last_name )) as ACTOR_FIRST_LAST from actor;
SELECT * FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan','Bangladesh','China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, so create a column in the table
-- actor named description and use the data type BLOB (Make sure to research the type BLOB, 
-- as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;
SELECT * FROM actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor
DROP COLUMN description;
SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT * FROM actor;
SELECT last_name, COUNT(last_name) AS last_name_count FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names
-- that are shared by at least two actors.
SELECT last_name, COUNT(last_name) AS last_name_count FROM actor
GROUP BY last_name
HAVING COUNT(*) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172
AND last_name = 'WILLIAMS';
SELECT * FROM actor
WHERE last_name = 'Williams';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the 
-- correct name after all! In a single query, if the first name of the actor is currently HARPO, 
-- change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = 172;
SELECT * FROM actor
WHERE last_name = 'Williams';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT 
	s.first_name, 
    s.last_name,
    a.address
FROM staff s
RIGHT JOIN  address a on s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT 
	SUM(p.amount) as total_amt,
    s.staff_id,
    s.first_name,
    s.last_name
FROM payment p
INNER JOIN staff s on p.staff_id = s.staff_id
WHERE p.payment_date LIKE '2005-08%'
GROUP BY s.staff_id,s.first_name,s.last_name
;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
SELECT
	f.title,
    COUNT(fa.actor_id) as actor_count
FROM film f
INNER JOIN film_actor fa on f.film_id = fa.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT
	f.title,
    COUNT(i.inventory_id) as inventory_count
FROM film f
INNER JOIN inventory i on f.film_id = i.film_id
WHERE f.title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each 
-- customer. List the customers alphabetically by last name:
SELECT
	c.first_name,
    c.last_name,
    SUM(p.amount) as amt_paid
FROM customer c
INNER JOIN payment p on c.customer_id = p.customer_id
GROUP BY c.last_name, c.first_name
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended 
-- consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries
-- to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title from film
WHERE title LIKE 'K%'
OR title LIKE 'Q%'
AND language_id IN 
    (SELECT language_id from language
	WHERE language_id = 1);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name,last_name
FROM actor
WHERE actor_id IN
	(SELECT actor_id
	from film_actor
	WHERE film_id IN
		(SELECT film_id
		FROM film
		WHERE title = 'Alone Trip')
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
-- email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT 
	cust.first_name,
    cust.last_name,
    cust.email
FROM customer cust
JOIN address a ON a.address_id = cust.address_id
JOIN city ON city.city_id = a.city_id
JOIN country ON country.country_id = city.country_id
WHERE country.country_id = 20
;
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a 
-- promotion. Identify all movies categorized as family films.
SELECT f.title
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.category_id = 8;

-- 7e. Display the most frequently rented movies in descending order.
SELECT 
	f.title,
    COUNT(r.rental_id) AS rental_count
FROM rental r
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY f.title
ORDER BY rental_count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT
	store.store_id,
    SUM(p.amount)
FROM store
JOIN staff ON staff.store_id = store.store_id
JOIN rental r ON r.staff_id = staff.staff_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT
	store.store_id,
    city.city,
    country.country
FROM store
JOIN address a ON a.address_id = store.address_id
JOIN city ON city.city_id = a.city_id
JOIN country ON country.country_id = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT 
	c.name,
    SUM(p.amount) AS gross_revenue
FROM payment p
JOIN rental r ON r.rental_id = p.rental_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film_category fc ON fc.film_id = i.film_id
JOIN category c ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW gross_rev_vw AS
SELECT 
	c.name,
    SUM(p.amount) AS gross_revenue
FROM payment p
JOIN rental r ON r.rental_id = p.rental_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film_category fc ON fc.film_id = i.film_id
JOIN category c ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM gross_rev_vw;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW gross_rev_vw;