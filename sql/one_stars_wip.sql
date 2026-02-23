-- Find which sellers have the most 1-star reviews
-- Who is responsible for 1-star reviews


WITH sellers_items AS (
SELECT
	s.seller_id,
	i.order_id
FROM cleaning.cleaning_sellers s
LEFT JOIN cleaning.cleaning_items i ON s.seller_id = i.seller_id
GROUP BY seller_id, order_id
),

order_reviews AS (
SELECT
	r.review_id,
	o.order_id,
	r.review_score
FROM cleaning.cleaning_reviews r
LEFT JOIN cleaning.cleaning_orders o ON r.order_id = o.order_id
)
-- SELECT
-- 	seller_id,
-- 	ROUND(AVG(avg_review_score::numeric),2) AS avg_review_score
-- FROM seller_order_enriched
-- GROUP BY seller_id
-- ORDER BY AVG(avg_review_score) ASC;