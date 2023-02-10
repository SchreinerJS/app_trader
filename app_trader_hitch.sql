-- -- App Trader
-- -- Your team has been hired by a new company called App Trader to help them explore and gain insights from apps 
-- that are made available through the Apple App Store and Android Play Store.   

-- -- App Trader is a broker that purchases the rights to apps from developers in order to market the apps and offer in-app purchases.
-- The apps' developers retain all money from users purchasing the app from the relevant app store, and they retain half of the money 
-- made from in-app purchases. App Trader will be solely responsible for marketing any apps they purchase the rights to.

-- -- Unfortunately, the data for Apple App Store apps and the data for Android Play Store apps are located in separate tables with no 
-- referential integrity.

-- -- 1. Loading the data
-- -- 	a. Launch PgAdmin and create a new database called app_trader.
DONE
-- -- 	b. Right-click on the app_trader database and choose Restore...
DONE
-- -- 	c. Use the default values under the Restore Options tab.
DONE 
-- -- 	d. In the Filename section, browse to the backup file app_store_backup.backup in the data folder of this repository.
DONE
-- -- 	e. Click Restore to load the database.
DONE
-- -- 	f. Verify that you have two tables:
-- -- 		- app_store_apps with 7197 rows
-- -- 		- play_store_apps with 10840 rows
DONE

SELECT *
FROM app_store_apps;

Information about the app store APPS:
*There are 7197 apps in the App Store. 
*The largest size bytes app is a chinese Entertainment App 
SELECT *
FROM app_store_apps
ORDER BY size_bytes DESC;
*The smallest size bytes app is a Game App called Cat-A-Pult:Endless stacking of 8-bit kittens
SELECT *
FROM app_store_apps
ORDER BY size_bytes ASC;
*All apps operate through the USD currency.
*There are 4056 Free apps 
SELECT *
FROM app_store_apps
WHERE price = '0.00'; 

*The most expensive app is LAMP Words For Life for $299.99, the runner up is Proloquo2Go-Symbol-based AAC for $249.99 
SELECT name, MAX(price) AS price 
FROM app_store_apps
GROUP BY name
ORDER BY price DESC;

*The app that received the most reviews is Facebook (2,974,676) after changing the value from text to numeric. Next is Instagram at 2,161,558. 
SELECT name, MAX(review_count)::numeric as reviews, primary_genre, rating
FROM app_store_apps
GROUP BY name, primary_genre, rating 
ORDER BY reviews DESC; 

*492 apps have a 5.00 rating 
SELECT name, MAX(rating) as rating, primary_genre, price
FROM app_store_apps
WHERE rating = '5.0'
GROUP BY name, primary_genre, price
ORDER BY rating DESC;

*26 apps rating 5.0 are entertainment, 23 genres 
SELECT primary_genre, name, rating
FROM app_store_apps
WHERE rating = '5.0' AND primary_genre = 'Entertainment'
ORDER BY primary_genre;

*The count of apps in each category. The highest is games. 
SELECT primary_genre, COUNT(primary_genre) as count  
FROM app_store_apps
GROUP BY primary_genre
ORDER BY count DESC;

*Of the 5.0 rated apps there are the top categories 
SELECT primary_genre, COUNT(primary_genre) as count, rating  
FROM app_store_apps
WHERE rating = '5'
GROUP BY primary_genre, rating
ORDER BY count DESC;

SELECT rating, COUNT(rating) as count  
FROM app_store_apps
GROUP BY rating
ORDER BY count DESC;

--APP STORE TYPE COLUMN
WITH type_table AS (SELECT 
						CASE WHEN price = 0 THEN 'free'
			         	WHEN price > 0 THEN 'paid'
			        	ELSE 'unknown' END AS type
              		FROM app_store_apps)
SELECT type, COUNT(type)
FROM type_table
GROUP BY type;
---------------------------------------
Information about the Play App store 

SELECT *
FROM play_store_apps
WHERE type = 'Free';
10,039 free apps  
*10,040 free apps 

SELECT *
FROM play_store_apps
WHERE type <> 'Free';
*800 paid apps 

SELECT price,
CASE WHEN price = '0' THEN 'free'
	 WHEN price > '0' THEN 'paid'
	 ELSE END AS price_app 
FROM play_store_apps
GROUP BY price;


*119 DISINCT genres. 
SELECT DISTINCT genres
FROM play_store_apps;

SELECT genres, COUNT(genres) as count  
FROM play_store_apps
GROUP BY genres
ORDER BY count DESC;

SELECT rating, COUNT(rating) as count  
FROM play_store_apps
GROUP BY rating
ORDER BY rating DESC;

SELECT DISTINCT genres, COUNT(genres) as count  
FROM play_store_apps
WHERE genres ILIKE '%edu%'
GROUP BY genres
ORDER BY count DESC;


-Expenses
-Two groups of apps - FREE, Paid 
-rights to broker the app 
-free $25,000
-paid 10,000 * price = fair market price; 25000 > fair market price

-advertising flat $1000/month even if app is in both stores

-INCOME 
-$5000/month gross income/app 
$5000 * 12 * longevity 
-$5000 * 12 * 1 = 60000

-longevity = 1 year + (0.5 year * (star_rating  * 4))
-longevity = 1 year + (0.5 year * (2*4))= 5

Longetivity: From 0 to 1 rating would be 4 (.25) incremental increases. For every .25 incremental increase the longetivity increases by 6 months. So
for a 0 rating the longetivity is 1yr. 

RATING
				0 you will last 1yr 
				1 you will last 3yrs (1yrs + (6mons * 4 incremental increases= 24 months = 2yrs))
				2 you will last 5yrs (1yrs + (6mons * 8 incremental increases= 48 months = 4yrs))
				3 you will last 7yrs (1yrs + (6mons * 12 incremental increases= 72 months = 6yrs))
				4 you will last 9yrs (1yrs + (6mons * 16 incremental increases= 96 months = 8yrs))
				5 you will last 11yrs (1yrs + (6mons * 20 incremental increases= 120 months = 10yrs))

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

--GROSS PROFIT
WITH raw_prices AS (WITH full_table AS ((SELECT name, price::money, rating              --ECT UNION of both tables
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
				FROM full_table)														 --ECT of raw prices query above
SELECT DISTINCT name,
	   price,
	   rating,
	   purchase_price,
	   raw_income,
	   advertising_cost,
	   (raw_income - purchase_price - advertising_cost) AS gross_income
FROM raw_prices
WHERE (raw_income - purchase_price - advertising_cost) IS NOT NULL
ORDER BY name DESC;









-FOCUSES

UNION BOTH TABLES USING name, price, rating, primary_genre as genres



(SELECT name, price::money, rating, primary_genre as genres
FROM app_store_apps)
UNION
(SELECT name, price::money, rating, genres
FROM play_store_apps)
ORDER BY genres; 

WITH all_genres AS ((SELECT name, price::money, rating, primary_genre as genres, review_count::int
					FROM app_store_apps)
					UNION
					(SELECT name, price::money, rating, genres, review_count
					FROM play_store_apps
					ORDER BY genres))

SELECT DISTINCT name, genres, rating, MAX(review_count) as max_review
FROM all_genres
WHERE genres ILIKE 'games%' OR genres ILIKE 'enter%' OR genres ILIKE '%education%' AND rating ='5.0'
GROUP BY rating, genres, name
ORDER BY max_review DESC NULLS LAST;





-- -- 2. Assumptions
-- -- Based on research completed prior to launching App Trader as a company, you can assume the following:

-- -- 	a. App Trader will purchase the rights to apps for 10,000 times the list price of the app on the Apple App Store/Google Play Store, 
-- however the minimum price to purchase the rights to an app is $25,000. For example, a $3 app would cost $30,000 (10,000 x the price) and 
-- a free app would cost $25,000 (The minimum price). NO APP WILL EVER COST LESS THEN $25,000 TO PURCHASE.

-- -- 	b. Apps earn $5000 per month on average from in-app advertising and in-app purchases regardless of the price of the app.

-- -- 	c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to
-- the app in both stores, it can market the app for both stores for a single cost of $1000 per month.

-- -- 	d. For every quarter-point that an app gains in rating, its projected lifespan increases by 6 months, in other words, an app with a rating 
-- of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be 
-- expected to last 9 years. Ratings should be rounded to the nearest 0.25 to evaluate an app's likely longevity.

-- -- 	e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the 
-- same $1000 per month.

-- -- 3. Deliverables
-- -- 	a. Develop some general recommendations about the price range, genre, content rating, or any other app characteristics that the company should
-- target.

-- -- 	b. Develop a Top 10 List of the apps that App Trader should buy based on profitability/return on investment as the sole priority.

-- -- 	c. Develop a Top 4 list of the apps that App Trader should buy that are profitable but that also are thematically appropriate for next months's 
-- Pi Day themed campaign.

-- -- 	c. Submit a report based on your findings. The report should include both of your lists of apps along with your analysis of their cost and 
-- potential profits. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report.





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