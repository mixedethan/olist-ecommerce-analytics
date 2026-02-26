	-- Sellers Master View
SELECT *
FROM cleaning.cleaning_sellers s
LEFT JOIN cleaning.cleaning_items i ON s.seller_id = i.seller_id
LEFT JOIN cleaning.cleaning_orders o ON i.order_id = o.order_id
LEFT JOIN cleaning.cleaning_products p ON i.product_id = p.product_id
LEFT JOIN cleaning.cleaning_reviews r ON o.order_id = r.order_id;


-- all data we will need, rows are ITEM-level
WITH base_seller_info AS (
	SELECT 
		-- seller info
		s.seller_id,
		seller_zip_code,
		seller_city,
		seller_state,
		seller_lat,
		seller_long,

		-- order info
		o.order_id,
		item_sequence_num,
		p.product_id,
		seller_shipping_deadline,
		price,
		freight_value,
		total_item_value,

		-- logistics
		purchase_ts,
		approved_ts,
		pickup_ts,
		delivered_ts,
		estimated_ts,
		delivery_lead_time,
		delta_estimated_actual,
		delivery_check,

		-- item/product info
		product_category_name,
		product_weight_grams,
		product_volume_cm_3,
		review_score,
		review_comment_message,
		CASE WHEN review_score = 5 THEN 1 ELSE 0 END AS is_five_star,
		CASE WHEN review_score = 1 THEN 1 ELSE 0 END AS is_one_star,
		CASE WHEN review_comment_message IS NOT NULL THEN 1 ELSE 0 END AS has_review_comment
		
	FROM cleaning.cleaning_sellers s
	LEFT JOIN cleaning.cleaning_items i ON s.seller_id = i.seller_id
	LEFT JOIN cleaning.cleaning_orders o ON i.order_id = o.order_id
	LEFT JOIN cleaning.cleaning_products p ON i.product_id = p.product_id
	LEFT JOIN cleaning.cleaning_reviews r ON o.order_id = r.order_id
),

-- feature engineering
seller_agg AS (
	SELECT
		seller_id,
		ROUND(AVG(price::numeric), 2) AS avg_item_price, -- avg item price
		ROUND(AVG(freight_value::numeric), 2) AS avg_shipping_cost, -- avg shipping cost
		ROUND(SUM(price::numeric), 2) AS total_revenue,
		COUNT(CASE WHEN delivery_check = 'DELIVERED' THEN 1 END) AS num_items_delivered,
		COUNT(CASE WHEN delivery_check != 'DELIVERED' THEN 1 END) AS num_items_not_delivered,
		COUNT(order_id) AS total_orders,
		ROUND(AVG(delivery_lead_time::numeric), 2) AS avg_purchase_to_delivery, -- avg purchase to delivered time
		COUNT(CASE WHEN delta_estimated_actual < 0 THEN 1 END) AS orders_delivered_late,
		COUNT(CASE WHEN delta_estimated_actual > 0 THEN 1 END) AS orders_delivered_early,
		ROUND(AVG(review_score::numeric), 2) AS avg_review_score
		
	FROM base_seller_info
	GROUP BY seller_id
	ORDER BY SUM(price) DESC
)

SELECT * FROM seller_agg;











-- sellers with their total items sold, number of unique products they offer, and total orders.
-- SELECT
-- 	seller_id,
-- 	COUNT(*) AS total_items_sold,
-- 	COUNT(DISTINCT product_id) AS unique_products,
-- 	COUNT(DISTINCT order_id) AS total_orders,
-- 	RANK() OVER(ORDER BY COUNT(DISTINCT order_id) DESC) AS orders_rankings
-- FROM total_seller_info
-- GROUP BY seller_id;
