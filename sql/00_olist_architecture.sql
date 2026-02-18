CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS
  staging.staging_reviews,
  staging.staging_payments,
  staging.staging_items,
  staging.staging_products,
  staging.staging_sellers,
  staging.staging_geolocation,
  staging.staging_orders,
  staging.staging_customers,
  staging.staging_category_translation
CASCADE;

CREATE TABLE staging.staging_category_translation
(
  product_category_name text,
  product_category_name_english text
);

CREATE TABLE staging.staging_customers
(
  customer_id text PRIMARY KEY,
  customer_unique_id text NOT NULL,
  customer_zip_code_prefix integer,
  customer_city text,
  customer_state text
);

CREATE TABLE staging.staging_orders
(
  order_id text PRIMARY KEY,
  customer_id text NOT NULL,
  order_status text,
  order_purchase_timestamp timestamptz,
  order_approved_at timestamptz,
  order_delivered_carrier_date timestamptz,
  order_delivered_customer_date timestamptz,
  order_estimated_delivery_date date
);

CREATE TABLE staging.staging_geolocation
(
  geolocation_zip_code_prefix integer,
  geolocation_lat double precision,
  geolocation_lng double precision,
  geolocation_city text,
  geolocation_state text
);

CREATE TABLE staging.staging_products
(
  product_id text PRIMARY KEY,
  product_category_name text,
  product_name_length integer,
  product_description_length integer,
  product_photos_qty integer,
  product_weight_g integer,
  product_length_cm integer,
  product_height_cm integer,
  product_width_cm integer
);

CREATE TABLE staging.staging_sellers
(
  seller_id text PRIMARY KEY,
  seller_zip_code_prefix integer,
  seller_city text,
  seller_state text
);

CREATE TABLE staging.staging_items
(
  order_id text NOT NULL,
  order_item_id integer NOT NULL,
  product_id text NOT NULL,
  seller_id text NOT NULL,
  shipping_limit_date timestamptz,
  price numeric(12,2),
  freight_value numeric(12,2),
  PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE staging.staging_payments
(
  order_id text NOT NULL,
  payment_sequential integer NOT NULL,
  payment_type text,
  payment_installments integer,
  payment_value numeric(12,2),
  PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE staging.staging_reviews
(
  review_id text NOT NULL,
  order_id text NOT NULL,
  review_score integer,
  review_comment_title text,
  review_comment_message text,
  review_creation_date timestamptz,
  review_answer_timestamp timestamptz,
  PRIMARY KEY (review_id, order_id)
);

-- FKs with unique, descriptive constraint names
ALTER TABLE staging.staging_orders
  ADD CONSTRAINT fk_staging_orders_customer
  FOREIGN KEY (customer_id)
  REFERENCES staging.staging_customers (customer_id)
  NOT VALID;

ALTER TABLE staging.staging_items
  ADD CONSTRAINT fk_staging_items_order
  FOREIGN KEY (order_id)
  REFERENCES staging.staging_orders (order_id)
  NOT VALID;

ALTER TABLE staging.staging_items
  ADD CONSTRAINT fk_staging_items_product
  FOREIGN KEY (product_id)
  REFERENCES staging.staging_products (product_id)
  NOT VALID;

ALTER TABLE staging.staging_items
  ADD CONSTRAINT fk_staging_items_seller
  FOREIGN KEY (seller_id)
  REFERENCES staging.staging_sellers (seller_id)
  NOT VALID;

ALTER TABLE staging.staging_payments
  ADD CONSTRAINT fk_staging_payments_order
  FOREIGN KEY (order_id)
  REFERENCES staging.staging_orders (order_id)
  NOT VALID;

ALTER TABLE staging.staging_reviews
  ADD CONSTRAINT fk_staging_reviews_order
  FOREIGN KEY (order_id)
  REFERENCES staging.staging_orders (order_id)
  NOT VALID;