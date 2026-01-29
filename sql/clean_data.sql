-- CLEANING --
-- 1) Remove Duplicates
-- 2) Standardize Data
-- 3) Handle Null Values

-- staging_orders -> cleaning_orders
-- check unique order status
SELECT order_status, COUNT(*) AS Occurences
FROM staging.staging_orders
GROUP BY order_status;

-- create a cleaned view
SELECT *
FROM staging.staging_orders;

CREATE OR REPLACE VIEW staging.cleaning_orders AS
SELECT 
	order_id,
	customer_id,
	order_status,
	-- convert time columns from text to a timestamp data type
	TO_TIMESTAMP(order_purchase_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS purchase_ts,
    TO_TIMESTAMP(order_approved_at, 'YYYY-MM-DD HH24:MI:SS') AS approved_ts,
    TO_TIMESTAMP(order_delivered_carrier_date, 'YYYY-MM-DD HH24:MI:SS') AS pickup_ts,
    TO_TIMESTAMP(order_delivered_customer_date, 'YYYY-MM-DD HH24:MI:SS') AS delivered_ts,
    TO_TIMESTAMP(order_estimated_delivery_date, 'YYYY-MM-DD HH24:MI:SS') AS estimated_ts,
	-- check if it was delivered, if not mark it. adding delivery check feature
	CASE
		WHEN order_delivered_customer_date IS NULL AND order_status = 'delivered' THEN 'DATA ERROR'
		WHEN order_delivered_customer_date IS NULL THEN 'not delivered'
		ELSE 'delivered'
	END as delivery_check
FROM staging.staging_orders
-- filter out outliers
WHERE order_status != 'canceled' AND order_status != 'unavailable' AND order_status != 'created' AND order_status != 'approved';


-- staging_items -> cleaning_items

