/*Q1. Who is the senior most employee based on job title?*/
Select * from employee
order by levels desc
limit 1

/*Q2. Which country has the most invoices?*/
Select count(*) as c,(billing_country) 
from invoice
group by billing_country
order by c desc
limit 1

/*What are top 3 values of total invoice?*/
select total from invoice
order by total desc
limit 3

/*Which city has the best customers? 
We would like to throw a promotional Music Festival in the city we made the most money.
Write a query to return one city that has the highest sum of invoice totals.
Return both city names and suum of all invoice totals.*/
Select Sum(total) as invoice_total, billing_city 
from invoice
group by billing_city
order by invoice_total desc
limit 1

/*Who is the best customer? The customer who has spent the most money is the best customer*/
Select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as amount
from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id 
order by amount desc
limit 1

/*Qusetion set 2 

Q1. Write query to return the email, first name, last name and genre of all rock music listeners.
Return your list alphabetically with email starting with A*/
Select distinct first_name, last_name, email 
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id=genre.genre_id
	where genre.name like 'Rock'
)
order by email

/*Write query to return Artist names and total track counts of top 10 rock bands*/
select artist.artist_id, artist.name, count(artist.artist_id) as num_of_songs 
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by num_of_songs desc
limit 10

/*Return all the track names that have song length greater than the average song length.
Return the name and miliseconds for each song
Order by song length with longest song listed first.*/
Select name, milliseconds as song_length from track
where milliseconds>(
	Select avg(milliseconds) from track as avg_track_length)
order by milliseconds desc

/* Question Set 3 

Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

/* source: www.youtube.com/@RishabhMishraOfficial */

/* Thank You :) */

