-- Late Delivery Impact on 1-star Reviews
-- how much worse are reviews for on-time vs late deliveries?
 
-- late delivery distribution
SELECT
	o.is_late_delivery,
	COUNT(*) AS frequency,
	COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS pct
FROM cleaning.cleaning_reviews r
LEFT JOIN cleaning.cleaning_orders o 
	ON r.order_id = o.order_id
WHERE o.is_late_delivery IN (0, 1)
GROUP BY o.is_late_delivery;


-- late vs on-time review score avgs
SELECT o.is_late_delivery, ROUND(AVG(r.review_score::numeric), 2) AS avg_score
FROM cleaning.cleaning_reviews r
LEFT JOIN cleaning.cleaning_orders o ON r.order_id = o.order_id
WHERE o.is_late_delivery IN (0, 1)
GROUP BY is_late_delivery;




