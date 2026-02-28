-- Seller Tiers
-- (Excellent/Good/Watchlist/Toxic) using explicit thresholds 
-- (1‑star rate, late_delivery_rate, avg_review_score, volume/revenue)

-- all our kpis
SELECT COUNT(seller_id)
FROM analysis.seller_kpis
WHERE reviewed_orders > 5;

-- unique order amounts
SELECT all_orders AS num_orders, COUNT(all_orders) AS occurences
FROM analysis.seller_kpis
GROUP BY all_orders;


-- too many lesser established sellers will skew our numbers, filter sellers with only > 20 reviewed order
WITH eligible AS (
	SELECT *
	FROM analysis.seller_kpis
	WHERE reviewed_orders > 3
),

norm AS (
	SELECT
		e.*,

		-- scores where higher is better
		PERCENT_RANK() OVER(ORDER BY e.avg_review_score) AS pr_review_score,
		PERCENT_RANK() OVER(ORDER BY e.total_item_revenue) AS pr_revenue,

		-- scores where lower is better (we invert to ensure higher percents are better)
		1 - PERCENT_RANK() OVER(ORDER BY e.one_star_rate) AS pr_one_star_good,
		1 - PERCENT_RANK() OVER(ORDER BY e.late_delivery_rate) AS pr_late_delivery_good,
		1 - PERCENT_RANK() OVER(ORDER BY e.avg_delivery_lead_time) AS pr_delivery_lead_time_good
	FROM eligible e
),

--
seller_score_calc AS(
	SELECT
		n.*,
		ROUND(100 * (
				0.30 * n.pr_review_score +
				0.10 * n.pr_revenue +
				0.25 * n.pr_one_star_good +
				0.25 * n.pr_late_delivery_good +
				0.10 * n.pr_delivery_lead_time_good)::numeric
		, 2) AS seller_score
	FROM norm n
),

tier_kpis AS (
	SELECT
		-- KPIs
		seller_id,
		total_item_revenue,
		avg_review_score,
		one_star_rate,
		avg_delivery_lead_time,
		late_deliveries,
		late_delivery_rate,

		-- our derived seller score
		seller_score
		
	FROM seller_score_calc s
	ORDER BY seller_score DESC
)

SELECT * FROM tier_kpis;