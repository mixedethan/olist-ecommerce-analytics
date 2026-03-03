-- Category and Geography
-- how do these affect performance? is performance concentrated in certain groups?

-- GEOGRAPHY
-- City-level

CREATE OR REPLACE VIEW analysis.geo_city_kpis AS (
	SELECT 
		seller_city,
		COUNT(seller_id) AS num_sellers,
		SUM(all_orders) AS num_orders,
		ROUND(SUM(avg_review_score * reviewed_orders) / NULLIF(SUM(reviewed_orders), 0), 2) AS avg_review,
		ROUND(AVG(one_star_rate), 2) AS avg_one_star_rate,
		ROUND(AVG(avg_delivery_lead_time), 2) AS avg_delivery_lead_time,
		SUM(late_deliveries) AS num_late_deliveries,
		ROUND(SUM(late_deliveries) / NULLIF(SUM(delivered_orders), 0), 2) AS avg_late_delivery_rate
	FROM analysis.seller_kpis
	GROUP BY seller_city
	HAVING SUM(all_orders) > 5 -- only cities with more than 5 total orders
);

-- State-level
CREATE OR REPLACE VIEW analysis.geo_state_kpis AS (
	SELECT 
		seller_state,
		COUNT(seller_id) AS num_sellers,
		SUM(all_orders) AS num_orders,
		ROUND(SUM(avg_review_score * reviewed_orders) / NULLIF(SUM(reviewed_orders), 0), 2) AS avg_review_score,
		ROUND(AVG(one_star_rate), 2) AS avg_one_star_rate,
		ROUND(AVG(avg_delivery_lead_time), 2) AS avg_delivery_lead_time,
		SUM(late_deliveries) AS num_late_deliveries,
		ROUND(SUM(late_deliveries) / SUM(delivered_orders), 2) AS avg_late_delivery_rate
	FROM analysis.seller_kpis
	GROUP BY seller_state
	HAVING SUM(all_orders) > 50
);

-- CATEGORY

-- We need to collapse product joined w/ items to the order-level grain.
-- We want to know how review scores vary across product categories
CREATE OR REPLACE VIEW analysis.category_scores AS (
	WITH order_review AS (
		SELECT
			o.order_id,
			r.review_score
		FROM cleaning.cleaning_orders o
		LEFT JOIN cleaning.cleaning_reviews r
			ON o.order_id = r.order_id
		WHERE r.review_score IS NOT NULL
	),
	
	product_item AS (
		SELECT
			orv.order_id,
			orv.review_score,
			i.product_id,
			i.price,
			i.item_sequence_num
		FROM order_review orv
		LEFT JOIN cleaning.cleaning_items i
			ON orv.order_id = i.order_id
	
	),
	
	order_categories AS (
		SELECT
			pi.order_id,
			p.product_category_name,
			ROUND(AVG(pi.review_score), 2) AS review_score,
			ROUND(AVG(price), 2) AS avg_price
		FROM product_item pi
		LEFT JOIN cleaning.cleaning_products p
			ON pi.product_id = p.product_id
		GROUP BY order_id, product_category_name -- each aggregate is a unique combo of order_id and product category.
	)
	
	-- categories & their avg review scores
	SELECT
		product_category_name,
		COUNT(*) AS orders_in_category,
		ROUND(AVG(review_score), 2) AS avg_review_score
	FROM order_categories
	GROUP BY product_category_name
	ORDER BY avg_review_score DESC
);


