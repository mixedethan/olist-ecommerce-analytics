-- Seller KPI Dataset
-- seller-order CTE -> order-metrics CTE -> join them and aggregate to seller KPIs

-- transform item level data to seller order level
WITH seller_order AS (
SELECT
	i.seller_id,
	i.order_id,
	COUNT(*) AS items_in_order,
	SUM(i.price) as item_revenue,
	SUM(i.freight_value) AS freight_total,
	MIN(i.seller_shipping_deadline) AS first_shipping_deadline
FROM cleaning.cleaning_items i
LEFT JOIN cleaning.cleaning_sellers s ON i.seller_id = s.seller_id
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
    COUNT(*) AS review_count
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
    orv.review_count
  FROM seller_order so
  LEFT JOIN order_metrics om ON so.order_id = om.order_id
  LEFT JOIN order_review orv ON so.order_id = orv.order_id
)


SELECT -- pull our KPIs from the combined data
  seller_id,
  COUNT(*) AS seller_orders,
  SUM(items_in_order) AS items_sold,
  SUM(item_revenue) AS total_item_revenue,
  ROUND(AVG(avg_review_score::numeric), 2) AS avg_review_score,
  SUM(review_count) AS num_reviews,
  ROUND(AVG(delivery_lead_time::numeric), 2) AS avg_delivery_lead_time,
  SUM(is_late_delivery)AS late_deliveries,
  ROUND(AVG(is_late_delivery::int), 2) AS late_delivery_rate,
  CASE WHEN AVG(days_late) > 0 THEN ROUND(AVG(days_late), 2) ELSE 0 END AS avg_days_late
FROM seller_order_enriched
WHERE delivery_check = 'DELIVERED'
GROUP BY seller_id;