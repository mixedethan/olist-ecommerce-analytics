CREATE OR REPLACE VIEW analysis.full_seller_info AS (
	SELECT
		k.seller_id,
		k.seller_city,
		k.seller_state,
		k.seller_lat,
		k.seller_long,
		k.all_orders,
		k.delivered_orders,
		k.total_item_revenue,
		k.avg_review_score,
		k.reviewed_orders,
		k.one_star_rate,
		k.avg_delivery_lead_time,
		k.late_deliveries,
		k.avg_days_when_late,
		k.late_delivery_rate,
		t.seller_score,
		t.tier
	FROM analysis.seller_kpis k
	LEFT JOIN analysis.seller_tiers t
		ON k.seller_id = t.seller_id
);