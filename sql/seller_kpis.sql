-- Seller KPI Dataset
-- seller-order CTE -> order-metrics CTE -> join them and aggregate to seller KPIs

-- transform item level data to seller order level
CREATE OR REPLACE VIEW analysis.seller_kpis AS (
	WITH seller_order AS (
	SELECT
		i.seller_id,
		i.order_id,
		COUNT(*) AS items_in_order,
		SUM(i.price) as item_revenue,
		SUM(i.freight_value) AS freight_total,
		MIN(i.seller_shipping_deadline) AS first_shipping_deadline
	FROM cleaning.cleaning_items i
	GROUP BY seller_id, order_id
	),
	
	order_metrics AS ( -- all our order-level metrics
	  SELECT
	    o.order_id,
	    o.order_status,
	    o.delivery_check,
	    o.delivery_lead_time,
	    o.is_late_delivery,
	    o.days_late,
	    o.purchase_ts,
	    o.pickup_ts,
	    o.delivered_ts,
	    o.estimated_ts
	  FROM cleaning.cleaning_orders o
	),
	
	order_review AS ( -- bring in our review metrics
	  SELECT
	    r.order_id,
	    AVG(r.review_score)::numeric(4,2) AS avg_review_score,
	    COUNT(*) AS review_count,
		(MAX(r.review_score) = 1)::int AS is_one_star
	  FROM cleaning.cleaning_reviews r
	  GROUP BY r.order_id
	),
	
	seller_order_enriched AS ( -- combined seller order, order metrics, and order reviews
	  SELECT
	    so.seller_id,
	    so.order_id,
	    so.items_in_order,
	    so.item_revenue,
	    so.freight_total,
	    om.delivery_check,
	    om.delivery_lead_time,
	    om.is_late_delivery,
	    om.days_late,
	    orv.avg_review_score,
	    orv.review_count,
		orv.is_one_star
	  FROM seller_order so
	  LEFT JOIN order_metrics om ON so.order_id = om.order_id
	  LEFT JOIN order_review orv ON so.order_id = orv.order_id
	),
	
	seller_kpis AS (
		SELECT -- pull our KPIs from the combined data
		  seller_id,
		  COUNT(*) AS all_orders,
		  COUNT(*) FILTER (WHERE delivery_check = 'DELIVERED') AS delivered_orders,
		  SUM(item_revenue) AS total_item_revenue,
		  ROUND(AVG(avg_review_score::numeric), 2) AS avg_review_score,
		  COUNT(*) FILTER (WHERE avg_review_score IS NOT NULL) AS reviewed_orders,
		  AVG(is_one_star) AS one_star_rate,
		  ROUND(AVG(delivery_lead_time::numeric) FILTER (WHERE delivery_check = 'DELIVERED'), 2) AS avg_delivery_lead_time,
		  COUNT(*) FILTER (WHERE delivery_check = 'DELIVERED' AND is_late_delivery = 1) AS late_deliveries,
		  AVG(days_late) FILTER (WHERE delivery_check = 'DELIVERED' AND is_late_delivery = 1) AS avg_days_when_late
		FROM seller_order_enriched
		GROUP BY seller_id
	)
	
	
	SELECT 
		k.seller_id,
		s.seller_city,
		s.seller_state,
		s.seller_lat,
		s.seller_long,
		k.all_orders,
		k.delivered_orders,
		k.total_item_revenue,
		k.avg_review_score,
		k.reviewed_orders,
		ROUND(k.one_star_rate, 2) AS one_star_rate,
		k.avg_delivery_lead_time,
		k.late_deliveries,
		ROUND(k.avg_days_when_late, 2) AS avg_days_when_late,
		ROUND(k.late_deliveries::numeric / NULLIF(delivered_orders, 0), 2) AS late_delivery_rate
	FROM seller_kpis k
	LEFT JOIN cleaning.cleaning_sellers s ON k.seller_id = s.seller_id
)