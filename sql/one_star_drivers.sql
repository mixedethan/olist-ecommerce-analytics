-- Drivers of 1-star Reviews

-- which sellers account for the largest amount of 1-star reviews?
WITH seller_orders AS (
	SELECT
		i.seller_id,
		i.order_id,
		s.seller_city,
		s.seller_state
	FROM cleaning.cleaning_items i
	LEFT JOIN cleaning.cleaning_sellers s ON i.seller_id = s.seller_id 
	GROUP BY seller_id, order_id
),

order_reviews AS (
	SELECT
)