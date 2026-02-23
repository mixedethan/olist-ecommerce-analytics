				-- staging_orders -> cleaning_orders --
DROP VIEW IF EXISTS cleaning.cleaning_orders;

-- what are we working with?
SELECT *
FROM staging.staging_orders;

-- check unique order status
SELECT order_status, COUNT(*) AS Occurences
FROM staging.staging_orders
GROUP BY order_status;

-- create a cleaned view
CREATE OR REPLACE VIEW cleaning.cleaning_orders AS
WITH converted_dates AS (
	SELECT 
		order_id,
		customer_id,
		UPPER(order_status) AS order_status,
		-- convert time columns from text to a timestamp data type
		order_purchase_timestamp AS purchase_ts,
	    order_approved_at AS approved_ts,
	    order_delivered_carrier_date AS pickup_ts,
	    order_delivered_customer_date AS delivered_ts,
	    order_estimated_delivery_date::timestamp AS estimated_ts
	FROM staging.staging_orders
	WHERE order_status NOT IN ('CANCELED', 'UNAVAILABLE', 'CREATED', 'APPROVED') -- filter outliers
)

SELECT 
	*,
	ROUND((EXTRACT(EPOCH FROM (delivered_ts - purchase_ts)) / 86400.0), 2) AS delivery_lead_time, -- time taken from purchase to delivery in days
	ROUND((EXTRACT(EPOCH FROM (estimated_ts - delivered_ts)) / 86400.0), 2) AS delta_estimated_actual, -- difference between estimated arrival and actual arrival in days
	-- ROUND((EXTRACT(EPOCH FROM (pickup_ts - purchase_ts)) / 86400.0), 2) AS seller_handling_time,
	CASE
	  WHEN delivered_ts IS NULL THEN NULL
	  WHEN delivered_ts > estimated_ts THEN 1
	  ELSE 0
	END AS is_late_delivery,
	GREATEST(EXTRACT(EPOCH FROM (delivered_ts - estimated_ts)) / 86400.0, 0) AS days_late,
	CASE -- check if it was delivered, if not mark it. adding delivery check feature
		WHEN delivered_ts IS NULL AND order_status = 'DELIVERED' THEN 'DATA ERROR'
		WHEN delivered_ts IS NULL THEN 'NOT DELIVERED'
		ELSE 'DELIVERED'
	END as delivery_check
FROM converted_dates;

				-- staging_items -> cleaning_items --
DROP VIEW IF EXISTS cleaning.cleaning_items;
SELECT *
FROM staging.staging_items;

--- sample order containing 3 of the same items to understand staging_items structure
SELECT *
FROM staging.staging_items
WHERE order_id = '00143d0f86d6fbd9f9b38ab440ac16f5';

-- check for nulls
SELECT COUNT(*)
FROM staging.staging_items
WHERE 
	shipping_limit_date IS NULL
	OR price IS NULL
	OR freight_value IS NULL
;

CREATE OR REPLACE VIEW cleaning.cleaning_items AS
SELECT
	order_id,
	order_item_id AS item_sequence_num,
	product_id,
	seller_id,
	shipping_limit_date AS seller_shipping_deadline,
	price,
	freight_value,
	ROUND((price::numeric + freight_value::numeric), 2) AS total_item_value
FROM staging.staging_items;


				-- staging_payments -> cleaning_payments --
DROP VIEW IF EXISTS cleaning.cleaning_payments;

SELECT *
FROM staging.staging_payments;

-- distinct payment types
SELECT DISTINCT payment_type, COUNT(*)
FROM staging.staging_payments
GROUP BY payment_type;
-- remove not_defined

CREATE OR REPLACE VIEW cleaning.cleaning_payments AS
SELECT
	order_id,
	payment_sequential,
	COALESCE(NULLIF(payment_type,'not_defined'),'unknown') AS payment_type,
	payment_installments,
	payment_value
FROM staging.staging_payments;

SELECT *
FROM cleaning.cleaning_payments;



				-- staging_products -> cleaning_products --
DROP VIEW IF EXISTS cleaning.cleaning_products;

SELECT *
FROM staging.staging_products;

SELECT *
FROM staging.staging_category_translation;

SELECT *
FROM staging.staging_products AS p
LEFT JOIN  staging.staging_category_translation AS t 
ON p.product_category_name = t.product_category_name;

CREATE OR REPLACE VIEW cleaning.cleaning_products AS
SELECT
	product_id,
	COALESCE(product_category_name_english, p.product_category_name) AS product_category_name,
	product_name_length,
	product_description_length,
	product_photos_qty,
	product_weight_g AS product_weight_grams,
	product_length_cm,
	product_height_cm,
	product_width_cm,
	product_length_cm * product_height_cm * product_width_cm AS product_volume_cm_3
FROM staging.staging_products AS p
LEFT JOIN staging.staging_category_translation AS t 
ON p.product_category_name = t.product_category_name;

SELECT *
FROM cleaning.cleaning_products;



				-- staging_customers -> cleaning_customers --
DROP VIEW IF EXISTS cleaning.cleaning_customers;

SELECT *
FROM staging.staging_customers;

-- check for nulls in columns which shouldn't contain them
SELECT COUNT(*) AS num_null_unique_ids
FROM staging.staging_customers
WHERE customer_unique_id IS NULL;

-- check for duplicates in possible columns
DROP VIEW IF EXISTS cleaning.cleaning_customers;

WITH customer_dupes AS (
	SELECT 
		customer_unique_id,
		ROW_NUMBER() OVER(
			PARTITION BY customer_unique_id
		) AS num_occurences
	FROM staging.staging_customers
	GROUP BY customer_unique_id
)

SELECT COUNT(*) AS num_dupes
FROM customer_dupes
WHERE num_occurences > 1;

CREATE OR REPLACE VIEW cleaning.cleaning_customers AS
SELECT
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	staging.UNACCENT(UPPER(customer_city)) AS customer_city,
	UPPER(customer_state)
FROM staging.staging_customers;

SELECT *
FROM cleaning.cleaning_customers;


				-- staging_sellers -> cleaning_sellers --
DROP VIEW IF EXISTS cleaning.cleaning_sellers;

SELECT *
FROM staging.staging_sellers;

-- cities and the number of times they appear
SELECT seller_city, COUNT(*) AS num_occurences
FROM staging.staging_sellers
GROUP BY seller_city
ORDER BY COUNT(*) DESC;

SELECT * FROM cleaning.cleaning_geolocation;

CREATE OR REPLACE VIEW cleaning.cleaning_sellers AS
SELECT
	seller_id,
	g.zip_code AS seller_zip_code,
	g.city AS seller_city,
	g.state AS seller_state,
	g.lat AS seller_lat,
	g.long AS seller_long
FROM staging.staging_sellers AS s
LEFT JOIN cleaning.cleaning_geolocation AS g
ON s.seller_zip_code_prefix = g.zip_code;

SELECT * FROM cleaning.cleaning_sellers;


				-- staging_reviews -> cleaning_reviews --
DROP VIEW IF EXISTS cleaning.cleaning_reviews;

SELECT * FROM staging.staging_reviews;

CREATE OR REPLACE VIEW cleaning.cleaning_reviews AS
SELECT
	review_id,
	order_id,
	review_score,
	review_comment_title,
	review_comment_message
FROM staging.staging_reviews
WHERE review_score IS NOT NULL;

SELECT * FROM cleaning.cleaning_reviews;