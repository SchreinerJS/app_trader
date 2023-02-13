--EXPENSES

--Two groups of apps - free, paid
--rights to broker the app
--free $25,000
--paid 10000 * price = fair market price; 25000 > fair market price 

--advertising flat $1000/month even if app is in both stores
--$1000 * 12 * longevity

--INCOME
--$2500/month gross income/app 
--$2500 * 12 * longevity
--$2500 * 12 * 1 = 60000

--longevity = 1 year + (0.5 year * (star_rating * 4))
--longevity = 1 year + (0.5 year * (2 * 4)) = 5

--FOCUSES
--genre, content rating, price range
--when recommending types of apps
--narrow recommendation of 10 apps with sole focus of profitability
--recommend 4 apps that are profitable and also align with PI day/Valentine's



--RAW PRICES
WITH full_table AS ((SELECT name, price::money, rating
				   FROM app_store_apps)
				   UNION ALL
				   (SELECT name, price::money, rating
				   FROM play_store_apps))
SELECT name, 
	   price::numeric, 
	   rating, 
	   (1 + (0.5 * rating * 4)) AS longevity,
	   CASE WHEN (price::numeric * 10000) <= 25000 THEN 25000
		 	WHEN (price::numeric * 10000) > 25000 THEN (price::numeric * 10000)
		 	END AS purchase_price,
	   (2500 * 12 * (1 + (0.5 * rating * 4))) AS raw_income,
	   (1000 * 12 * (1 + (0.5 * rating * 4))) AS advertising_cost
FROM full_table;
--

--GROSS PROFIT
WITH raw_prices AS (WITH full_table AS ((SELECT name, price::money, rating, review_count::int   --ECT UNION of both tables
				   						FROM app_store_apps)
				   						UNION ALL
				   						(SELECT name, price::money, rating, review_count::int
				   						FROM play_store_apps))
					SELECT name, 
	   					price::numeric, 
	   					rating, 
	  					(1 + (0.5 * rating * 4)) AS longevity,
	  					CASE WHEN (price::numeric * 10000) <= 25000 THEN 25000
		 				WHEN (price::numeric * 10000) > 25000 THEN (price::numeric * 10000)
		 				END AS purchase_price,
	   					(2500 * 12 * (1 + (0.5 * rating * 4))) AS raw_income,
	   					(1000 * 12 * (1 + (0.5 * rating * 4))) AS advertising_cost,
						review_count
					FROM full_table)														 --ECT of raw prices query above
SELECT name,
	   price,
	   rating,
	   purchase_price,
	   raw_income,
	   advertising_cost,
	   review_count,
	   (raw_income - purchase_price - advertising_cost) AS gross_income
FROM raw_prices
WHERE (raw_income - purchase_price - advertising_cost) IS NOT NULL
ORDER BY gross_income DESC;
--


--GENRES ADDED
WITH raw_prices AS (WITH full_table AS ((SELECT name, price::money, rating, review_count::int, primary_genre AS genres  --ECT UNION of both tables
				   						FROM app_store_apps)
				   						UNION ALL
				   						(SELECT name, price::money, rating, review_count::int, genres
				   						FROM play_store_apps))
					SELECT name, 
	   					price::numeric, 
	   					rating, 
	  					(1 + (0.5 * rating * 4)) AS longevity,
	  					CASE WHEN (price::numeric * 10000) <= 25000 THEN 25000
		 				WHEN (price::numeric * 10000) > 25000 THEN (price::numeric * 10000)
		 				END AS purchase_price,
	   					(2500 * 12 * (1 + (0.5 * rating * 4))) AS raw_income,
	   					(1000 * 12 * (1 + (0.5 * rating * 4))) AS advertising_cost,
						review_count,
						genres
					FROM full_table
				    WHERE genres ILIKE 'games%' OR genres ILIKE 'entertainment%' OR genres ILIKE 'education%'
								 AND rating = 5.0)														 						--ECT of raw prices query above
SELECT name,
	   price,
	   rating,
	   purchase_price,
	   raw_income,
	   advertising_cost,
	   review_count,
	   genres,
	   (raw_income - purchase_price - advertising_cost) AS gross_income
FROM raw_prices
WHERE (raw_income - purchase_price - advertising_cost) = 173000
ORDER BY review_count DESC
--

--COUNT OF APP GENRES WITH TOP GROSS INCOME
WITH raw_prices AS (WITH full_table AS ((SELECT name, price::money, rating, review_count::int, primary_genre AS genres  --ECT UNION of both tables
				   						FROM app_store_apps)
				   						UNION ALL
				   						(SELECT name, price::money, rating, review_count::int, genres
				   						FROM play_store_apps))
					SELECT name, 
	   					price::numeric, 
	   					rating, 
	  					(1 + (0.5 * rating * 4)) AS longevity,
	  					CASE WHEN (price::numeric * 10000) <= 25000 THEN 25000
		 				WHEN (price::numeric * 10000) > 25000 THEN (price::numeric * 10000)
		 				END AS purchase_price,
	   					(2500 * 12 * (1 + (0.5 * rating * 4))) AS raw_income,
	   					(1000 * 12 * (1 + (0.5 * rating * 4))) AS advertising_cost,
						review_count,
						genres
					FROM full_table
				    WHERE genres ILIKE 'games%' OR genres ILIKE 'entertainment%' OR genres ILIKE 'education%'
								 AND rating = 5.0)														 						
SELECT genres, COUNT(genres)
FROM raw_prices
WHERE (raw_income - purchase_price - advertising_cost) = 173000
GROUP BY genres
ORDER BY count(genres) DESC



--APP STORE TYPE COLUMN
WITH type_table AS (SELECT 
						CASE WHEN price = 0 THEN 'free'
			         	WHEN price > 0 THEN 'paid'
			        	ELSE 'unknown' END AS type
              		FROM app_store_apps)
SELECT type, COUNT(type)
FROM type_table
GROUP BY type;
--
SELECT *
FROM app_store_apps

SELECT *
FROM play_store_apps


SELECT name, price::money, rating,                
FROM app_store_apps)
UNION ALL
SELECT name, price::money, rating
FROM play_store_apps
--

--PI THEMED APPS
WITH raw_prices AS (WITH full_table AS ((SELECT name, price::money, rating, review_count::int, primary_genre AS genres  --ECT UNION of both tables
				   						FROM app_store_apps)
				   						UNION ALL
				   						(SELECT name, price::money, rating, review_count::int, genres
				   						FROM play_store_apps))
					SELECT name, 
	   					price::numeric, 
	   					rating, 
	  					(1 + (0.5 * rating * 4)) AS longevity,
	  					CASE WHEN (price::numeric * 10000) <= 25000 THEN 25000
		 				WHEN (price::numeric * 10000) > 25000 THEN (price::numeric * 10000)
		 				END AS purchase_price,
	   					(2500 * 12 * (1 + (0.5 * rating * 4))) AS raw_income,
	   					(1000 * 12 * (1 + (0.5 * rating * 4))) AS advertising_cost,
						review_count,
						genres
					FROM full_table
				    WHERE genres ILIKE 'games%' OR genres ILIKE 'entertainment%' OR genres ILIKE 'education%'
								 AND rating = 5.0)														 						--ECT of raw prices query above
SELECT name,
	   price,
	   rating,
	   purchase_price,
	   raw_income,
	   advertising_cost,
	   review_count,
	   genres,
	   (raw_income - purchase_price - advertising_cost) AS gross_income
FROM raw_prices
WHERE (raw_income - purchase_price - advertising_cost) = 173000
	AND name ILIKE ('%pie%')
	OR name ILIKE ('%brain%')
ORDER BY gross_income DESC
--Monkey Math School Sunshine, Math Ninja HD, HIt the Button Math, Abby Monkey Basic Skills

--VALENTINES DAY APPS
WITH raw_prices AS (WITH full_table AS ((SELECT name, price::money, rating, review_count::int, primary_genre AS genres  --ECT UNION of both tables
				   						FROM app_store_apps)
				   						UNION ALL
				   						(SELECT name, price::money, rating, review_count::int, genres
				   						FROM play_store_apps))
					SELECT name, 
	   					price::numeric, 
	   					rating, 
	  					(1 + (0.5 * rating * 4)) AS longevity,
	  					CASE WHEN (price::numeric * 10000) <= 25000 THEN 25000
		 				WHEN (price::numeric * 10000) > 25000 THEN (price::numeric * 10000)
		 				END AS purchase_price,
	   					(2500 * 12 * (1 + (0.5 * rating * 4))) AS raw_income,
	   					(1000 * 12 * (1 + (0.5 * rating * 4))) AS advertising_cost,
						review_count,
						genres
					FROM full_table
				    WHERE genres ILIKE 'games%' OR genres ILIKE 'entertainment%' OR genres ILIKE 'education%'
								 AND rating = 5.0)														 						--ECT of raw prices query above
SELECT name,
	   price,
	   rating,
	   purchase_price,
	   raw_income,
	   advertising_cost,
	   review_count,
	   genres,
	   (raw_income - purchase_price - advertising_cost) AS gross_income
FROM raw_prices
WHERE name ILIKE '%valentine%'
ORDER BY gross_income DESC
--Valentines love color by number-Pixel art coloring, CLUE Bingo: Valentine's Day, Tangled Up! - Valentine Special, Jewel Mania: Valentine's

--GENRES UNION ALL
WITH raw_prices AS (WITH full_table AS ((SELECT name, price::money, rating, review_count::int, primary_genre AS grouped_genres
				   						FROM app_store_apps)
				   						UNION ALL
				   						(SELECT name, price::money, rating, review_count::int, 
										 	CASE WHEN genres ILIKE '%edu%' THEN 'Education'
														WHEN genres ILIKE 'sim%' THEN 'Games'
														WHEN genres ILIKE 'action%' THEN 'Games'
														WHEN genres ILIKE 'adv%' THEN 'Games'
														WHEN genres ILIKE 'trivia%' THEN 'Games'
														WHEN genres ILIKE 'board%' THEN 'Games'
														WHEN genres ILIKE 'puz%' THEN 'Games'
														WHEN genres ILIKE 'stategy%' THEN 'Games'
														WHEN genres ILIKE '%arcade%' THEN 'Games'
														WHEN genres ILIKE 'rac%' THEN 'Games'
														WHEN genres ILIKE '%play%' THEN 'Games'
														WHEN genres ILIKE 'card%' THEN 'Games' 
	 													ELSE genres END AS grouped_genres
				   						FROM play_store_apps))
					SELECT name, 
	   					price::numeric, 
	   					rating, 
	  					(1 + (0.5 * rating * 4)) AS longevity,
	  					CASE WHEN (price::numeric * 10000) <= 25000 THEN 25000
		 				WHEN (price::numeric * 10000) > 25000 THEN (price::numeric * 10000)
		 				END AS purchase_price,
	   					(2500 * 12 * (1 + (0.5 * rating * 4))) AS raw_income,
	   					(1000 * 12 * (1 + (0.5 * rating * 4))) AS advertising_cost,
						review_count,
						grouped_genres
					FROM full_table)														 
SELECT name,
	   price,
	   rating,
	   purchase_price,
	   raw_income,
	   advertising_cost,
	   review_count,
	   (raw_income - purchase_price - advertising_cost) AS gross_income,
	   grouped_genres
FROM raw_prices
WHERE (raw_income - purchase_price - advertising_cost) = 173000
ORDER BY gross_income DESC;

--COUNT OF APPS PER GENRE
WITH raw_prices AS (WITH full_table AS ((SELECT name, price::money, rating, review_count::int, primary_genre AS grouped_genres
				   						FROM app_store_apps)
				   						UNION ALL
				   						(SELECT name, price::money, rating, review_count::int, 
										 	CASE WHEN genres ILIKE '%edu%' THEN 'Education'
														WHEN genres ILIKE 'sim%' THEN 'Games'
														WHEN genres ILIKE 'action%' THEN 'Games'
														WHEN genres ILIKE 'adv%' THEN 'Games'
														WHEN genres ILIKE 'trivia%' THEN 'Games'
														WHEN genres ILIKE 'board%' THEN 'Games'
														WHEN genres ILIKE 'puz%' THEN 'Games'
														WHEN genres ILIKE 'stategy%' THEN 'Games'
														WHEN genres ILIKE '%arcade%' THEN 'Games'
														WHEN genres ILIKE 'rac%' THEN 'Games'
														WHEN genres ILIKE '%play%' THEN 'Games'
														WHEN genres ILIKE 'card%' THEN 'Games' 
	 													ELSE genres END AS grouped_genres
				   						FROM play_store_apps))
					SELECT name, 
	   					price::numeric, 
	   					rating, 
	  					(1 + (0.5 * rating * 4)) AS longevity,
	  					CASE WHEN (price::numeric * 10000) <= 25000 THEN 25000
		 				WHEN (price::numeric * 10000) > 25000 THEN (price::numeric * 10000)
		 				END AS purchase_price,
	   					(2500 * 12 * (1 + (0.5 * rating * 4))) AS raw_income,
	   					(1000 * 12 * (1 + (0.5 * rating * 4))) AS advertising_cost,
						review_count,
						grouped_genres
					FROM full_table)														 
SELECT grouped_genres, COUNT(grouped_genres)
FROM raw_prices
WHERE (raw_income - purchase_price - advertising_cost) = 173000
GROUP BY grouped_genres
ORDER BY COUNT(grouped_genres) DESC;
--

--TOP 10 WITH INTERSECTED TABLES
WITH raw_prices AS (WITH full_table AS ((SELECT name, price::money, rating
				   						FROM app_store_apps)
				   						INTERSECT
				   						(SELECT name, price::money, rating
				   						FROM play_store_apps))
					SELECT name, 
	   					price::numeric, 
	   					rating, 
	  					(1 + (0.5 * rating * 4)) AS longevity,
	  					CASE WHEN (price::numeric * 10000) <= 25000 THEN 25000
		 				WHEN (price::numeric * 10000) > 25000 THEN (price::numeric * 10000)
		 				END AS purchase_price,
	   					(2500 * 12 * (1 + (0.5 * rating * 4))) AS raw_income,
	   					(1000 * 12 * (1 + (0.5 * rating * 4))) AS advertising_cost					
					FROM full_table)
SELECT name,
	   raw_prices.price,
	   raw_prices.rating,
	   raw_prices.purchase_price,
	   raw_income,
	   advertising_cost,
	   (raw_income - purchase_price - advertising_cost) AS gross_income,
	   app_store_apps.review_count AS app_store_review_count,
	   play_store_apps.review_count AS play_store_review_count,
	   (app_store_apps.review_count::integer + play_store_apps.review_count) AS combined_review_count
FROM raw_prices
INNER JOIN app_store_apps USING(name)
INNER JOIN play_store_apps USING(name)
WHERE (raw_income - purchase_price - advertising_cost) IS NOT NULL
ORDER BY combined_review_count DESC;

--Instagram, Subway Surfers, My Talking Tom, Hay Day, My talking Angela, Asphalt 8: Airborne, PicsArt Photo Studio: Collage Maker & Pic Editor, Trivia Crack, Wish - Shopping Made Fun, Hungry Shark Evolution