-- Item Master View for Tableau
CREATE OR REPLACE VIEW cleaning.sales_master AS
SELECT
	-- keys & ids
    i.order_id,
    i.item_sequence_num,
    o.customer_id,
    i.seller_id,
    i.product_id,
	
	-- dates and performance
    TO_CHAR(o.purchase_ts, 'YYYY-MM-DD HH24:MI:SS') AS purchase_ts,
    TO_CHAR(o.delivered_ts, 'YYYY-MM-DD HH24:MI:SS') AS delivered_ts,
    TO_CHAR(o.estimated_ts, 'YYYY-MM-DD HH24:MI:SS') AS estimated_ts,
    TO_CHAR(i.seller_shipping_deadline, 'YYYY-MM-DD HH24:MI:SS') AS seller_shipping_deadline,
    ROUND(o.delivery_lead_time::numeric, 2) AS delivery_days, -- time from delivery to purchase
    ROUND(o.delta_estimated_actual::numeric, 2) AS days_ahead_of_estimate, -- difference between est delivery and actual delivery
	o.delivery_check,
    

	-- product info
    p.product_category_name,
    p.product_weight_grams,
    p.product_volume_cm_3,

	-- financials
    i.price,
    i.freight_value,
    ROUND((i.price + i.freight_value)::numeric, 2) AS total_item_value,

	-- customer info
    c.customer_state,
    c.customer_city,

	-- satisfaction
	r.review_score
FROM cleaning.cleaning_items i
INNER JOIN cleaning.cleaning_orders o ON i.order_id = o.order_id
LEFT JOIN cleaning.cleaning_products p ON i.product_id = p.product_id
LEFT JOIN cleaning.cleaning_customers c ON o.customer_id = c.customer_id
LEFT JOIN cleaning.cleaning_reviews r ON i.order_id = r.order_id;

SELECT * FROM cleaning.sales_master;

DROP TABLE IF EXISTS analysis.sales_master;
CREATE TABLE analysis.sales_master AS SELECT * FROM cleaning.sales_master;