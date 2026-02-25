-- Late Delivery Impact on 1-star Reviews
-- how much worse are reviews for on-time vs late deliveries?
 
-- late delivery distribution
SELECT
	o.is_late_delivery,
	COUNT(*) AS frequency,
	COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percentage_of_whole,
	ROUND(AVG(r.review_score::numeric), 2) AS avg_score,
	COUNT(*) FILTER (WHERE r.review_score = 1) AS num_1_star
FROM cleaning.cleaning_reviews r
LEFT JOIN cleaning.cleaning_orders o 
	ON r.order_id = o.order_id
WHERE o.is_late_delivery IN (0, 1)
GROUP BY o.is_late_delivery;


-- review score avgs vs differents levels of days late
SELECT 
	DISTINCT CEILING(o.days_late) AS days_late, -- distinct days late rounded up to whole day
	COUNT(*) AS occurences, -- number of occurences for that specific amount of days late
	ROUND(AVG(r.review_score), 2) AS avg_review_score, -- avg review score for the amt of days late
	COUNT(*) FILTER (WHERE r.review_score = 1) AS num_1_star,
	COUNT(*) FILTER (WHERE r.review_score <= 2) AS num_low_reviews
FROM cleaning.cleaning_reviews r
LEFT JOIN cleaning.cleaning_orders o 
	ON r.order_id = o.order_id
WHERE o.days_late > 0
GROUP BY CEILING(o.days_late)
ORDER BY days_late;


-- review score avgs vs buckets of days
SELECT 
	CASE
		WHEN o.days_late BETWEEN -1 AND 0.01 THEN 'Early/On-time'
		WHEN o.days_late BETWEEN 0.01 AND 1 THEN 'Within a Day'
		WHEN o.days_late BETWEEN 1 AND 3 THEN '1-3 Days'
		WHEN o.days_late BETWEEN 3 AND 5 THEN '3-5 Days'
		WHEN o.days_late BETWEEN 5 AND 7 THEN '5-7 Days'
		ELSE '7+ Days'
	END AS days_late_bucket, -- distinct days late rounded up to whole day
	ROUND(AVG(r.review_score), 2) AS avg_review_score, -- avg review score for the amt of days late
	COUNT(*) AS occurences, -- number of occurences for that specific amount of days late
	COUNT(*) FILTER (WHERE r.review_score = 1) AS num_1_star,
	ROUND(COUNT(*) FILTER (WHERE r.review_score = 1)::numeric / COUNT(*), 2) AS one_star_rate
FROM cleaning.cleaning_reviews r
LEFT JOIN cleaning.cleaning_orders o 
	ON r.order_id = o.order_id
WHERE o.days_late >= 0
GROUP BY days_late_bucket
ORDER BY MIN(days_late);




