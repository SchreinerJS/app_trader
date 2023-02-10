-- App Trader Project
-------------------------------------------------------------
CURRENT profitability table

--CURRENT PROFITABILITY TABLE 3:30 2-10
	--GROSS PROFIT
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
								 AND rating = 5.0)--ECT of raw prices query above
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

-------------------------------------------------
-- Your team has been hired by a new company called App Trader to help them explore and gain insights from apps that are made available through the Apple App Store and Android Play Store.   

-- App Trader is a broker that purchases the rights to apps from developers in order to market the apps and offer in-app purchases. The apps' developers retain all money from users purchasing the app from the relevant app store, and they retain half of the money made from in-app purchases. App Trader will be solely responsible for marketing any apps they purchase the rights to.

-- Unfortunately, the data for Apple App Store apps and the data for Android Play Store apps are located in SEPARATE TABLES WITH NO REFERENTIAL INTEGRITY.
-------------------------------------
--Q. Should we be 1) combining the tables, 2) creating referential integrity where there was none through formulas, or 3) computing data from the tables separately and then combining the data after with formulas? 
--**See ratings scale for example
-------------------------------------
--1. Loading the data

-- 2. Assumptions
-- Based on research completed prior to launching App Trader as a company, you can assume the following:

-- 	a. App Trader will purchase the rights to apps for 10,000 times the list price of the app on the Apple App Store/Google Play Store, however the minimum price to purchase the rights to an app is $25,000. For example, a $3 app would cost $30,000 (10,000 x the price) and a free app would cost $25,000 (The minimum price). NO APP WILL EVER COST LESS THEN $25,000 TO PURCHASE.

-- 	b. Apps earn $5000 per month on average from in-app advertising and in-app purchases regardless of the price of the app.

-- 	c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.

-- 	d. For every quarter-point that an app gains in rating, its projected lifespan increases by 6 months, in other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years. Ratings should be rounded to the nearest 0.25 to evaluate an app's likely longevity.

-- 	e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.

--APP TRADER'S COSTS/EXPENSES
-- free 25000
-- paid 10000 * [price] = fair market price, MIN 25000 for a free app
-- 1000 for marketing, whether in one or both stores, so both stores are preferred
-- Needs to be subtracted from potential earnings for potential profit

------------------------------------------------
--add a column to our table for app_trader_costs
--CASE WHEN price * 10000 > 25000 THEN ((price * 10000)
--ELSE 25000

--[rights + marketing]
-------------------------------------------------------
--Q: is it easier/better to perform calculations/aggregations on numeric fields and then convert them to money in the output, or convert them to money when bringing the tables together and performing the calculations as money?

-- POTENTIAL APP TRADER EARNINGS
-- 5000/mo app earnings from in-app ads and in-app purchases, regardless of free or paid gross income, app trader gets 1/2 /app 

--For every quarter-point that an app gains in rating, its projected lifespan increases by 6 months, in other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years. Ratings should be rounded to the nearest 0.25 to evaluate an app's likely longevity.
--------------------------------------------------------
--Q. NOTE THE DISCREPANCY BETWEEN the store ratings ranges
--Q. Do we need AVG ratings by app name, are app names distinct
--Q. Do we need to compare app price with longevity, maybe it doesn't last as long but due to the cost it could be more profitable?
--Q.Should our longevity formula calculate based on integers or rounded to the nearest .25  
-----------------------------------------------------
-- every star rating above 0 adds 2 to the formula

--LONGEVITY (1 year + (0.5 * (star_rating * 4)

PROFITABILITY
2500 * 12 * longevity = projected yearly earnings

-------------------------------------------------------
--APP TRADER POTENTIAL PROFITABILITY

-- projected_earnings - costs = projected_profitability

-- FOCUSES
--genre, content rating, price range
--apps that are on both app_store and play_store [need to join the two tables], since $1000 will be spent on marketing either way, that will help to generate more income for app trader.


--COLUMNS & ROWS---------------------------
SELECT *
FROM app_store_apps
--COLUMNS: 
--name	text
--size_bytes	currency
--currency	text (USD)
--price	numeric
--review_count	text
--rating	numeric
--content_rating	text
--primary_genre	text

SELECT COUNT(*)
FROM app_store_apps
--7197 rows

SELECT *
FROM play_store_apps
--COLUMNS:
-- name	text
-- category	text ART_AND_DESIGN
-- rating numeric
-- review_count integer 
-- size text
-- install_count text
-- type text  [free, paid, 1 null]
-- price text

SELECT COUNT(*)
FROM play_store_apps
--ROWS 10840

--counting nulls by column might be more meaningful


--RATINGS---------------------
--Q. How should we factor/filter:
	--1) ratings with NULL values
	--2) Ratings with a 0 value (are they equal to nulls?
	--3) Ratings less than 1
	--4) Should we COALESCE NULLS to a zero or another number?
	--5) NULLS LAST to sort them last

--APP_STORE RATING SCALE
SELECT MIN(rating) AS min_rating,
		MAX(rating) AS max_rating,
		ROUND(AVG(rating), 2) AS avg_rating,
		COUNT(rating) AS number_ratings
FROM app_store_apps
--MIN 0.0
--MAX 5.0
--AVG 3.53
--NUMBER 7197 (no nulls)

SELECT DISTINCT rating
FROM app_store_apps
ORDER BY rating
-- 0.0 = NULL?
-- 1.0
-- 1.5
-- 2.0
-- 2.5
-- 3.0
-- 3.5
-- 4.0
-- 4.5
-- 5.0

--APP_STORE RATINGS NULLS/0s
SELECT COUNT(*)
FROM app_store_apps
WHERE rating IS NULL
-- 0 NULLS
SELECT rating
FROM app_store_apps
-- 7197 rows
SELECT COUNT(*)
FROM app_store_apps
WHERE rating <> 0
--6268 rows with rating not equal to 0
SELECT rating
WHERE rating = 0
-- 929 rows with rating of 0 [=NULL or an actual value which should be included when averaging?]
SELECT rating
FROM app_store_apps
WHERE rating = 0.0
--929 rows searching just for zero
SELECT rating
FROM app_store_apps
WHERE rating > 0 AND rating < 1
ORDER BY rating DESC
--there are no ratings between zero and one, so zero is likely a NULL value, perhaps COALESCE nulls to 0 in play_store_apps, then filter those out before averaging ratings

--NOTE: With AVG, SUM, MIN, or MAX, the NULL values are always ignored
---------------------------------

--PLAY_STORE RATING OVERVIEW
SELECT MIN(rating) AS min_rating,
		MAX(rating) AS max_rating,
		ROUND(AVG(rating), 2) AS avg_rating,
		COUNT(rating) AS number_ratings
FROM play_store_apps
-- MIN 1.0 
-- MAX 5.0
-- AVG 4.19
-- NUMBER RATIGS 9366

--PLAY_STORE DISTINCT RATINGS
SELECT DISTINCT rating
FROM play_store_apps
ORDER BY rating
1.0, 1.2, 1.4...4.9..5.0 + 1 NULL

--PLAY_STORE RATINGS NULLS
SELECT COUNT(*)
FROM play_store_apps
WHERE rating IS NULL
-- 1474 NULLS
SELECT rating
FROM play_store_apps
-- 10840 rows
SELECT COUNT(*)
FROM play_store_apps
WHERE rating IS NOT NULL
-- 9366 rows with ratings

--------------------------------------------------------
--Q. NOTE THE DISCREPANCY BETWEEN the store ratings ranges, app_store is in .5 increments, play_store is in .1 increments
 
------------------------------------------------
GENRE

--CHERNAE GENRE RELATED TO RATINGS

--*Of the 5.0 rated apps there are the top categories 
SELECT primary_genre, COUNT(primary_genre) as count, rating  
FROM app_store_apps
WHERE rating = '5'
GROUP BY primary_genre, rating
ORDER BY count DESC;

--*The app that received the most reviews is Facebook (2,974,676) after changing the value from text to numeric. Next is Instagram at 2,161,558. 
SELECT name, MAX(review_count)::numeric as reviews, primary_genre, rating
FROM app_store_apps
GROUP BY name, primary_genre, rating 
ORDER BY reviews DESC;
--MOST REVIEWS FACEBOOK, INSTAGRAM, 

GENRE COUNTS

--CHERNAE'S CODE
SELECT genres, COUNT(genres) as count  
FROM play_store_apps
GROUP BY genres
ORDER BY count DESC
LIMIT 5;
--1) Tools 842, 2) Entertainment 623 3) Education 549 4) Medical 463 5) Business 460

SELECT primary_genre, COUNT(primary_genre) as count  
FROM app_store_apps
GROUP BY primary_genre
ORDER BY count DESC
LIMIT 5;
--1) Games 3862, 2) Entertainment 535 3) Education 453 4) Photo & Video 349 5) Utilities 248
--------------------------------------------
--NOT WORKING
---------------------------------------------
SELECT genres, COUNT(genres) AS count, 
		CASE WHEN genres ILIKE '%;' THEN '%;' END AS genres1,
		CASE WHEN genres ILIKE ';%' THEN ';%' END AS genres2
FROM play_store_apps
GROUP BY genres
ORDER BY count DESC --attempting to separate strings into 2 columns
--------------------------------
SELECT genres, COUNT(genres), 
		CASE WHEN genres ILIKE 'Edu%' THEN 'Education'
		WHEN genres ILIKE 'Brai' THEN 'Brain Games'
		WHEN genres ILIKE 'Acti' THEN 'Action & Adventure'
		WHEN genres ILIKE 'Simul' THEN 'Simulation'
		END AS grouped_genres
FROM play_store_apps
GROUP BY genres
ORDER BY DESC -- will take a lot of time to get where we can count



--WORK ON THIS--
---------------------------------------------
--REVIEW_COUNT
-- Q Should review count factor into our ratings data?
--	1. Should 5.0 rating with <[number] reviews should be considered outliers, i.e. fake reviews?
-- 	2. Should we favor apps with a high number of reviews, which might indicate an app people take the time to review

SELECT name, MAX(review_count)::numeric as reviews, primary_genre, rating
FROM app_store_apps
GROUP BY name, primary_genre, rating 
ORDER BY reviews DESC

SELECT name, MAX(review_count)::numeric as reviews, primary_genre, rating
FROM play_store_apps
GROUP BY name, primary_genre, rating 
ORDER BY reviews DESC
SELECT DISTINCT review_count

FROM pl
--EXPLORATORY WORK ON THIS 

-------------------------------------------------
--TYPE - play_store_apps ONLY

--RICHARD'S CODE
WITH type_table AS (SELECT 
						CASE WHEN price = 0 THEN 'free'
			         	WHEN price > 0 THEN 'paid'
			        	ELSE 'unknown' END AS type
              		FROM app_store_apps)
SELECT type, COUNT(type)
FROM type_table
GROUP BY type;

--Q: there is a free/paid column in play_store that is not in apps_store. Should we create a free/paid column using case statements in app_store, so we can use that to organize free/paid apps for EXPENSES?

--would we generate more revenue with apps with in-app purchases and advertising on paid v free apps?
--is there a way to determine which apps have in-app purchases and advertising, or do they all?
--if needed we could create a matching column CASE STATEMENT WHEN price = 0.00 THEN 'Free',etc. 

SELECT type, COUNT(type)
FROM play_store_apps
GROUP BY type
ORDER BY type
--FREE: 10039
--PAID: 800
--NULL: 0

--*There are 4056 Free apps 
SELECT *
FROM app_store_apps
WHERE price = '0.00';

SELECT price,
	CASE WHEN price = 0.00 THEN COUNT(price) END AS free
	CASE WHEN price > 0.00 THEN COUNT(price) END AS paid
FROM app_store_apps
GROUP BY price
ORDER BY type DESC

SELECT CASE WHEN price = '0' THEN COUNT(price) END AS free,
	CASE WHEN price > '0' THEN COUNT(price) END AS paid
FROM app_store_apps
ORDER BY free, paid

-----------------------------------------------------
--PRICE
--MIN/MAX for each 
--AVG for each
--would MEDIAN be more meaningful?

--AVG price per genre and a count of apps (resolve price as text issue)
--AVG price when ratings are 3.8 or higher and a count of apps in that category
--Q. Do we need to compare app price with longevity, maybe it doesn't last as long but due to the cost it could be more profitable?

SELECT *
FROM play_store_apps;

SELECT genres, price::money 
FROM play_store_apps
GROUP BY genres, price;

SELECT genres, AVG(price::money) AS avg_price
FROM play_store_apps
GROUP BY genres
ORDER BY avg_price DESC; --doesn't work

SELECT genres, AVG(price::numeric) AS avg_price
FROM play_store_apps
GROUP BY genres
ORDER BY avg_price DESC; --doesn't work

SELECT genres, AVG(price) AS avg_price;
FROM play_store_apps
WHERE price::money
GROUP BY genres, price; --doesn't work

SELECT MIN(CAST(price, '$', 0) AS int) AS min_price,
		MAX(CAST(price, '$', 0) AS int) AS max_price,
		ROUND(AVG(CAST(price, '$', 0) AS int), 2)) AS avg_price,
		COUNT(CAST(price, '$', 0) AS int)) AS number_price
-----------------------------
-- https://stackoverflow.com/questions/54819744/using-cast-in-sql-to-convert-text-data-to-integer-to-take-avg
-- The issue is the $ sign, it is not convertible to int so you can try replacing that by zero since it is in the beginning of the price and won't affect the value.

SELECT sfo_calendar.calender_date,
  		AVG(CAST(replace(sfo_calendar.price,'$',0) AS int) avg_price
FROM sfo_calendar
GROUP BY sfo_calendar.calender_date;

---------------------
-- CHANGE THE DATATYPE OF COLUMN
ALTER TABLE [tbl_name] MODIFY COLUMN [col_name_1] [DATA_TYPE], 
    MODIFY [col_name_2] [data_type], 
    MODIFY [col_name_3] [data_type]
-------------------------------------------------------

--SIZE
--Q Does the size of an app relate to its ratings or its cost
			
------------------------------------------------------
--POPULARITY

-------------------------------------------------------
--NAME
--Q. are names distinct?
SELECT name
FROM app_store_apps
--RESULT: 7197
SELECT DISTINCT name
FROM app_store_apps
--RESULT: 7195

SELECT name
FROM play_store_apps
--RESULT 10840
SELECT DISTINCT name
FROM play_store_apps
--RESULTS 9659

SELECT DISTINCT name, AVG(rating) ROUND(AVG(rating), 1)
FROM play_store_apps
GROUP BY name
ORDER BY rating DESC;

--Q. Do we need AVG ratings by app name, are app names distinct

----------------------------------------------------------
JOINING THE TWO TABLES
			
--CURRENT PROFITABILITY TABLE 3:30 2-10
	--GROSS PROFIT
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
								 AND rating = 5.0)--ECT of raw prices query above
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
------------------------------------
--WORKING--
			
WITH raw_prices AS (WITH full_table AS ((SELECT name, price::money, rating                   --ECT UNION of both tables
				   						FROM app_store_apps)
				   						UNION ALL
				   						(SELECT name, price::money, rating
				   						FROM play_store_apps))
					SELECT DISTINCT name, 
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
ORDER BY gross_income DESC;	
----------------------------------------------------------
	
WITH all_genres AS ((SELECT name, price::money, rating, primary_genre as genres
					FROM app_store_apps
					ORDER BY genres)
					UNION
					(SELECT name, price::money, rating, genres
					FROM play_store_apps
				 	ORDER BY genres))
SELECT DISTINCT name, genres, rating
FROM all_genres
WHERE genres ILIKE '%games%' OR genres ILIKE '%entertainment%' OR genres ILIKE '%education%'
			AND rating = 5.0
GROUP BY rating, genres, name 
ORDER BY rating DESC NULLS LAST
			
WITH all_genres AS ((SELECT DISTINCT name, price::money, rating, primary_genre as genres
					FROM app_store_apps)
					UNION
					(SELECT DISTINCT name, price::money, rating, genres
					FROM play_store_apps))
SELECT genres, AVG(price::genre)
FROM all_genres
WHERE genres ILIKE 'games%' OR genres ILIKE 'enter%' OR genres ILIKE 'edu%'
			AND rating = 5.0
GROUP BY rating, genres, name 
ORDER BY rating DESC NULLS LAST
			
Q relationship between price & reviews
or price & genres 

--WORKING--------------------------------------------------------------------			
--SUBQUERY with CTE for filtering


			
WITH all_genres AS ((SELECT name, price::money, rating, review_count::int, primary_genre as genres
					FROM app_store_apps)
					UNION
					(SELECT DISTINCT name, price::money, rating, review_count::int, genres
					FROM play_store_apps))
SELECT DISTINCT genres,
			name,
			MAX(rating) AS max_rating,
			MIN(price::money) AS min_price,
			MAX(review_count) AS max_review_count
FROM all_genres
WHERE genres ILIKE 'games%' OR genres ILIKE 'entertainment%' OR genres ILIKE 'education%'
			AND rating = 5.0
GROUP BY name, rating, genres, name, review_count
ORDER BY max_price DESC NULLS LAST

			2.49
			
IF MAX RATING, THEN highest price relative to highest review count
is there a correlation between price and longevity
			
			
			
			avg review count for apps 5.0 rating
			avg review count for apps with max price
			do we want three from each of the top 3 genres?
			
AVG RATING
MAX REVIEWS
-----------------------------------------------------------
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

----------------------------------------------------------
(SELECT name, price::money, rating, primary_genre as genres
FROM app_store_apps)
UNION
(SELECT name, price::money, rating, genres
FROM play_store_apps);
WHERE genres LIKE '%'
			
			
(SELECT name, price::money
FROM app_store_apps)
UNION
(SELECT name, price::money 
FROM play_store_apps)
row 16558

(SELECT name, rating, price::money
FROM app_store_apps)
UNION
(SELECT name, rating, price::money 
FROM play_store_apps)
row 16827

(SELECT name, rating, price::money, primary_genres AS genres 
FROM app_store_apps
GROUP by name)
UNION
(SELECT name, rating, price::money, genres 
FROM play_store_apps
GROUP by name) 
--------------------------------------------------------------
 --BH KIM's code
 SELECT
	name,
	((rating * 2 ) + 1) AS longevity,
	((rating * 2 ) + 1) * 5000 AS ad_rev,
	((rating * 2 ) + 1) * 1000 AS marketing,
	CASE WHEN (price::money*10000) > 25000::money THEN (price::money*10000)
		WHEN (price::money*10000) < 25000::money THEN 25000::money
		END AS buying_price
FROM app_store_apps

SELECT
	name,
	((rating * 2 ) + 1) AS longevity,
	((rating * 2 ) + 1) * 2500 AS ad_rev,
	
	CASE WHEN (price::money*10000) > 25000::money THEN (price::money*10000)+1000)
		WHEN (price::money*10000) < 25000::money THEN 26000::money
		END AS costs
			
FROM app_store_apps
WITH both_store AS (
	SELECT
		name,
		app_store_apps.price AS apps_price,
		app_store_apps.rating AS apps_rating,
		play_store_apps.price AS play_price,
		play_store_apps.rating AS play_rating
	FROM app_store_apps
		LEFT JOIN play_store_apps
			USING (name))
SELECT
	name,
	((apps_rating * 2 ) + 1) AS apps_longevity,
	((play_rating * 2 ) + 1) AS play_longevity,
	((apps_rating * 2 ) + 1) * 5000 AS apps_ad_rev,
	((play_rating * 2 ) + 1) * 5000 AS play_ad_rev,
	((apps_rating * 2 ) + 1) * 1000 AS apps_marketing,
	((play_rating * 2 ) + 1) * 1000 AS play_marketing,
	CASE WHEN (apps_price::money*10000) > 25000::money THEN (apps_price::money*10000)
		WHEN (apps_price::money*10000) < 25000::money THEN 25000::money
		END AS buying_price
FROM both_store

--GENERAL RECOMMENDATION
--What types of apps to focus attention on?

--FROM DATA-DRIVEN DECISION MAKING:
--KPIs: Key Performance Indicators
--Extract information from the data which is relevant to measure the success of a company

--REVENUE:
--AVERAGE RATING OF ALL [  ]: CUSTOMER SATISFACTION
--NUMBER OF ACTIVE CUSTOMERS: CUSTOMER ENGAGEMENT

--Genre, content rating, price range 

--Exploratory questions

--GENRE, RATING
--Which 10 apps on app_store_apps have the top ratings?
--Which 10 genres on app_store_apps have the COUNT of ratings > 3.8 or MAX(ratings)?
--same for play_store_apps
--and same for joined_apps

--PRICE, RATING
--AVG price of an app
--AVG price of an app with a rating over 3.8
--Which price ranges on app_store_apps have the highest ratings (use case statement to filter into 3 price ranges)
--What is the AVG price for an app with AVG rating > 3.8 or MAX(rating)
--What is the MIN price for an app with an AVG rating > 3.80
--What is the MAX price for an app with a rating > 3.80 
--Which genres on app_store_apps are in a price range of [target range]
--Q. Should we explore only apps that have ratings, and remove any apps that don't have ratings from our table?
--q. Is there a way to quantitively compare apps with ratings to apps with downloads, and do we need to?

--KPI: AVERAGE RATING OF ALL [  ]: CUSTOMER SATISFACTION
--Once we select our apps, the average rating for the apps for our report

--KPI REVENUE:
--What are the most expensive apps with the most downloads?
--Which apps are generating the most revenue?

--NUMBER OF ACTIVE CUSTOMERS: CUSTOMER ENGAGEMENT
--How many downloads, current customers of the apps we are choosing are there?

--------------------------------------------
--DELIVERABLES
--------------------------------------------
-- 3. Deliverables
-- 	a. Develop some general recommendations about the price range, genre, content rating, or any other app characteristics that the company should target.

-- 	b. TOP 10 LIST -- Develop a Top 10 List of the apps that App Trader should buy BASED ON PROFITABILITY/RETURN ON INVESTMENT as the sole priority.

-- 	c. TOP 4 LIST of the apps that App Trader should buy that are PROFITABLE BUT THEMEATICALLY APPROPRIATE for next months's PI DAY (OR V DAY) themed campaign.

-- 	c. Submit a report based on your findings. The report should include both of your lists of apps along with your analysis of their cost and potential profits. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report.


--2.  Narrow report to 10 apps to buy with sole focus on profitability/return on investment

-- BUILD A QUERY THAT RETURNS TOP [??] GENRES, A PRICE RANGE, AND AN AVG CONTENT RATING OR RATING RANGE
--TO USE AS CTE OR SUBQUERY FOR NARROWING SELECTIONS TO 10 apps

--3. Recommend 4 apps that are profitable and also align with PI day/Valentine's

--IDEAS
--2-14 IS V-DAY
--(4 apps that begin with the letter v) 
--(4 relationship apps) 
--(4 apps with Love in the title)

--3-14 is PI DAY
--(4 apps about pie or have 'pie' in name, Have some PIE on PI DAY) 
--(4 math apps)
--(4 apps with a 3.14 rating -- GIVE THESE 3.14 star apps a try on PI DAY)

Education or math, food, pie