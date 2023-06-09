SELECT *
FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1

--

SELECT BILLING_COUNTRY,
	COUNT(*) AS TOTAL_INVOICES
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY TOTAL_INVOICES DESC
--

SELECT INVOICE_ID,
	SUM(TOTAL) AS TOTAL
FROM INVOICE
GROUP BY INVOICE_ID
ORDER BY TOTAL DESC
LIMIT 3

--

SELECT BILLING_CITY,
	SUM(TOTAL) AS TOTAL
FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY TOTAL DESC
LIMIT 1

--

SELECT CUSTOMER.CUSTOMER_ID,
	CUSTOMER.FIRST_NAME,
	CUSTOMER.LAST_NAME,
	SUM(INVOICE.TOTAL) AS TOTAL
FROM CUSTOMER
JOIN INVOICE ON INVOICE.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID
GROUP BY CUSTOMER.CUSTOMER_ID
ORDER BY TOTAL DESC
LIMIT 1

--

SELECT *
FROM GENRE

--

SELECT *
FROM INVOICE_LINE

--

SELECT DISTINCT CUSTOMER.EMAIL,
	CUSTOMER.FIRST_NAME,
	CUSTOMER.LAST_NAME,
	GENRE.NAME
FROM CUSTOMER
JOIN INVOICE ON INVOICE.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID
JOIN INVOICE_LINE ON INVOICE.INVOICE_ID = INVOICE_LINE.INVOICE_ID
JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
WHERE GENRE.NAME = 'Rock'
ORDER BY CUSTOMER.EMAIL

--
SELECT DISTINCT CUSTOMER.EMAIL,
	CUSTOMER.FIRST_NAME,
	CUSTOMER.LAST_NAME
FROM CUSTOMER
JOIN INVOICE ON INVOICE.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID
JOIN INVOICE_LINE ON INVOICE.INVOICE_ID = INVOICE_LINE.INVOICE_ID
WHERE TRACK_ID in
		(SELECT TRACK_ID
			FROM TRACK
			JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
			WHERE GENRE.NAME Like 'Rock')
ORDER BY CUSTOMER.EMAIL

--

SELECT ARTIST.NAME AS ARTISTNAME,
	COUNT(TRACK.TRACK_ID) AS TOTALCOUNT
FROM ARTIST
JOIN ALBUM ON ALBUM.ARTIST_ID = ARTIST.ARTIST_ID
JOIN TRACK ON TRACK.ALBUM_ID = ALBUM.ALBUM_ID
WHERE TRACK_ID in
		(SELECT TRACK_ID
			FROM TRACK
			JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
			WHERE GENRE.NAME Like 'Rock')
GROUP BY ARTIST.NAME
ORDER BY TOTALCOUNT DESC
LIMIT 10

--

SELECT NAME,
	MILLISECONDS
FROM TRACK
WHERE TRACK.MILLISECONDS >
		(SELECT AVG(TRACK.MILLISECONDS)
			FROM TRACK)
ORDER BY MILLISECONDS DESC

--

SELECT DISTINCT NAME
FROM ARTIST

--
--IF BEST SELLER ARTIST ONLY REQUIRED

WITH ARTISTS_DETAILS AS
	(SELECT ARTIST.ARTIST_ID,
			ARTIST.NAME,
			SUM(INVOICE_LINE.UNIT_PRICE * INVOICE_LINE.QUANTITY) AS TOTAL
		FROM INVOICE_LINE
		JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
		JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID
		JOIN ARTIST ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
		GROUP BY 1
		ORDER BY 3 DESC
	 	LIMIT 1
	)

SELECT CUSTOMER.CUSTOMER_ID,
	CUSTOMER.FIRST_NAME,
	CUSTOMER.LAST_NAME,
	ARTISTS_DETAILS.NAME,
	SUM (INVOICE_LINE.UNIT_PRICE * INVOICE_LINE.QUANTITY) AS TOTAL
FROM CUSTOMER
JOIN INVOICE ON INVOICE.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID
JOIN INVOICE_LINE ON INVOICE_LINE.INVOICE_ID = INVOICE.INVOICE_ID
JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID
JOIN ARTISTS_DETAILS ON ARTISTS_DETAILS.ARTIST_ID = ALBUM.ARTIST_ID
GROUP BY 1,2,
	3,4
ORDER BY 5 DESC

-- IF ALL ARTISTS ARE REQUIRED

SELECT CUSTOMER.CUSTOMER_ID,
	CUSTOMER.FIRST_NAME,
	CUSTOMER.LAST_NAME,
	ARTIST.NAME,
	SUM (INVOICE_LINE.UNIT_PRICE * INVOICE_LINE.QUANTITY) AS TOTAL
FROM CUSTOMER
JOIN INVOICE ON INVOICE.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID
JOIN INVOICE_LINE ON INVOICE_LINE.INVOICE_ID = INVOICE.INVOICE_ID
JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID
JOIN ARTIST ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
GROUP BY 1,2,
	3,4
ORDER BY 5 DESC

--

WITH TOP_GENRE AS

(SELECT COUNT(INVOICE_LINE.QUANTITY) AS PURCHASES,
	CUSTOMER.COUNTRY,
	GENRE.GENRE_ID,
	GENRE.NAME,
	ROW_NUMBER() OVER (PARTITION BY CUSTOMER.COUNTRY ORDER BY COUNT(INVOICE_LINE.QUANTITY) DESC) AS RANKS
FROM INVOICE_LINE
JOIN INVOICE ON INVOICE_LINE.INVOICE_ID = INVOICE.INVOICE_ID
JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
GROUP BY 2,3,4
ORDER BY 2 ASC, 1 DESC)

SELECT *
FROM TOP_GENRE
WHERE RANKS <=1

-- Using Recursive

WITH RECURSIVE

	TOP_GENRE AS (SELECT COUNT(INVOICE_LINE.QUANTITY) AS PURCHASES,
	CUSTOMER.COUNTRY,
	GENRE.GENRE_ID,
	GENRE.NAME
FROM INVOICE_LINE
JOIN INVOICE ON INVOICE_LINE.INVOICE_ID = INVOICE.INVOICE_ID
JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
GROUP BY 2,3,4
ORDER BY 2 ASC, 1 DESC
			 ),
		MAX_BY_COUNTRY AS (SELECT MAX(PURCHASES) AS MAXIMUM_PURCHASES, COUNTRY
		FROM TOP_GENRE
		GROUP BY 2
		ORDER BY 2
		)
SELECT TOP_GENRE.* FROM TOP_GENRE
JOIN MAX_BY_COUNTRY ON TOP_GENRE.COUNTRY = MAX_BY_COUNTRY.COUNTRY
WHERE MAX_BY_COUNTRY.MAXIMUM_PURCHASES = TOP_GENRE.PURCHASES

--

SELECT * FROM CUSTOMER
--

WITH CTE AS
(SELECT CUSTOMER.CUSTOMER_ID, CUSTOMER.FIRST_NAME, CUSTOMER.LAST_NAME, INVOICE.BILLING_COUNTRY, SUM(INVOICE.TOTAL) AS MAX_AMOUNT,
ROW_NUMBER() OVER (PARTITION BY INVOICE.BILLING_COUNTRY ORDER BY SUM(INVOICE.TOTAL)) AS ROWNUM
FROM INVOICE
JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
GROUP BY 1,2,3,4
ORDER  BY 4 DESC, 5 ASC
)

SELECT * FROM CTE where rownum <=1

-- Using Recursive

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;
