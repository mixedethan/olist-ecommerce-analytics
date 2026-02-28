-- Seller Tiers
-- (Excellent/Good/Watchlist/Toxic) using percentile tiers 
-- (1‑star rate, late_delivery_rate, avg_review_score, volume/revenue)

CREATE OR REPLACE VIEW analysis.seller_tiers AS (
	WITH base AS(
		SELECT * FROM analysis.seller_kpis
	),
	
	-- too many lesser established sellers will skew our numbers, filter sellers with only > 20 reviewed order
	eligible AS (
		SELECT *
		FROM analysis.seller_kpis
		WHERE reviewed_orders >= 20 AND delivered_orders > 0
	),
	
	-- normalize our KPIs to 0-1 as they are all on different scales
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
	
	
	seller_score_calc AS(
		SELECT
			n.*,
			ROUND(100 * ( -- we can now weigh each KPI and add them to develop a score
					0.30 * n.pr_review_score +
					0.10 * n.pr_revenue +
					0.25 * n.pr_one_star_good +
					0.25 * n.pr_late_delivery_good +
					0.10 * n.pr_delivery_lead_time_good)::numeric
			, 2) AS seller_score
		FROM norm n
	),
	
	percentiles AS (
		SELECT
			PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY seller_score) AS p50_score,
			PERCENTILE_CONT(0.7) WITHIN GROUP (ORDER BY seller_score) AS p70_score,
			PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY seller_score) AS p90_score
		FROM seller_score_calc s
	)
	
	SELECT
		-- KPIs
		b.seller_id,
		b.total_item_revenue,
		b.avg_review_score,
		b.one_star_rate,
		b.avg_delivery_lead_time,
		b.late_deliveries,
		b.late_delivery_rate,
		b.reviewed_orders,
		b.delivered_orders,
	
		-- derived seller score
		s.seller_score,

		-- tiers
		CASE
			WHEN b.reviewed_orders < 20 OR b.delivered_orders = 0 THEN 'Insufficient Data'
			WHEN s.seller_score >= p.p90_score THEN 'Excellent'
			WHEN s.seller_score >= p.p70_score THEN 'Good'
			WHEN s.seller_score >= p.p50_score THEN 'Watchlist'
			ELSE 'Toxic'
		END AS tier
		
	FROM base b
	LEFT JOIN seller_score_calc s ON b.seller_id = s.seller_id
	CROSS JOIN percentiles p
)
