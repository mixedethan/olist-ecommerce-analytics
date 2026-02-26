-- Marketplace Health Monthly
-- how the orders purchased in each month/year end up performing

CREATE OR REPLACE VIEW analysis.marketplace_health_monthly AS (
	WITH order_reviews AS ( -- extract the needed order and review info
		SELECT
			o.order_id AS o_order_id,
			o.order_status,
			o.purchase_ts,
			o.delivery_lead_time,
			o.is_late_delivery,
			o.days_late,
			o.delivery_check,
	
			r.order_id AS r_order_id,
			r.review_score
			
		FROM cleaning.cleaning_orders o
		LEFT JOIN cleaning.cleaning_reviews r
			ON o.order_id = r.order_id
	)
	
	SELECT
		-- start of month timestamps and display text
		date_trunc('month', purchase_ts) AS date_key,
		TO_CHAR(DATE_TRUNC('month', purchase_ts), 'MM/YYYY') AS month_year,
	
		-- order aggregates
		COUNT(o_order_id) AS orders_total,
	
		-- reviews
		ROUND(AVG(review_score), 2) AS avg_review_score,
		COUNT(review_score) AS orders_reviewed,
	
		-- deliveries
		COUNT(*) FILTER (WHERE delivery_check = 'DELIVERED') AS orders_delivered,
		ROUND(AVG(delivery_lead_time) FILTER (WHERE delivery_check = 'DELIVERED'), 2) AS avg_delivery_lead_time,
	
		-- late deliveries
		COUNT(*) FILTER (WHERE is_late_delivery = 1 AND delivery_check = 'DELIVERED') AS late_deliveries,
		ROUND(
			COUNT(*) FILTER (
			WHERE is_late_delivery = 1
			AND delivery_check = 'DELIVERED')::numeric -- avoid division by zero by setting to null
			/ NULLIF(COUNT(*) FILTER (WHERE delivery_check = 'DELIVERED'), 0) , 2) AS late_delivery_rate,
	
		-- missing deliveries
		COUNT(*) FILTER (WHERE delivery_check = 'NOT DELIVERED') AS orders_not_delivered,
		ROUND(COUNT(*) FILTER (WHERE delivery_check = 'NOT DELIVERED')::numeric / NULLIF(COUNT(o_order_id), 0), 2) AS not_delivered_rate,
		
		COUNT(*) FILTER (WHERE delivery_check = 'DATA ERROR') AS num_data_errors
	
	FROM order_reviews
	GROUP BY DATE_TRUNC('month', purchase_ts)
	ORDER BY date_key
);
