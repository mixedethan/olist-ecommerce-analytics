-- clearing out our pandas loaded table and regenerated its structure.
BEGIN;

DROP TABLE IF EXISTS staging_reviews, staging_payments, staging_items, staging_products, staging_sellers, staging_geolocation, staging_orders, staging_customers, staging_category_translation CASCADE;

CREATE TABLE IF NOT EXISTS public.staging_category_translation
(
    product_category_name text COLLATE pg_catalog."default",
    product_category_name_english text COLLATE pg_catalog."default"
);

CREATE TABLE IF NOT EXISTS public.staging_customers
(
    customer_id text COLLATE pg_catalog."default" NOT NULL,
    customer_unique_id text COLLATE pg_catalog."default" NOT NULL,
    customer_zip_code_prefix bigint,
    customer_city text COLLATE pg_catalog."default",
    customer_state text COLLATE pg_catalog."default",
    PRIMARY KEY (customer_id)
);

CREATE TABLE IF NOT EXISTS public.staging_orders
(
    order_id text COLLATE pg_catalog."default" NOT NULL,
    customer_id text COLLATE pg_catalog."default" NOT NULL,
    order_status text COLLATE pg_catalog."default",
    order_purchase_timestamp text COLLATE pg_catalog."default",
    order_approved_at text COLLATE pg_catalog."default",
    order_delivered_carrier_date text COLLATE pg_catalog."default",
    order_delivered_customer_date text COLLATE pg_catalog."default",
    order_estimated_delivery_date text COLLATE pg_catalog."default",
    PRIMARY KEY (order_id)
);

CREATE TABLE IF NOT EXISTS public.staging_geolocation
(
    geolocation_zip_code_prefix bigint,
    geolocation_lat double precision,
    geolocation_lng double precision,
    geolocation_city text COLLATE pg_catalog."default",
    geolocation_state text COLLATE pg_catalog."default"
);

CREATE TABLE IF NOT EXISTS public.staging_items
(
    order_id text COLLATE pg_catalog."default" NOT NULL,
    order_item_id bigint NOT NULL,
    product_id text COLLATE pg_catalog."default" NOT NULL,
    seller_id text COLLATE pg_catalog."default" NOT NULL,
    shipping_limit_date text COLLATE pg_catalog."default",
    price double precision,
    freight_value double precision,
    PRIMARY KEY (order_id, order_item_id, product_id, seller_id)
);

CREATE TABLE IF NOT EXISTS public.staging_payments
(
    order_id text COLLATE pg_catalog."default" NOT NULL,
    payment_sequential bigint NOT NULL,
    payment_type text COLLATE pg_catalog."default",
    payment_installments bigint,
    payment_value double precision,
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE IF NOT EXISTS public.staging_products
(
    product_id text COLLATE pg_catalog."default" NOT NULL,
    product_category_name text COLLATE pg_catalog."default",
    product_name_lenght double precision,
    product_description_lenght double precision,
    product_photos_qty double precision,
    product_weight_g double precision,
    product_length_cm double precision,
    product_height_cm double precision,
    product_width_cm double precision,
    PRIMARY KEY (product_id)
);

CREATE TABLE IF NOT EXISTS public.staging_reviews
(
    review_id text COLLATE pg_catalog."default" NOT NULL,
    order_id text COLLATE pg_catalog."default" NOT NULL,
    review_score bigint,
    review_comment_title text COLLATE pg_catalog."default",
    review_comment_message text COLLATE pg_catalog."default",
    review_creation_date text COLLATE pg_catalog."default",
    review_answer_timestamp text COLLATE pg_catalog."default",
    PRIMARY KEY (review_id, order_id)
);

CREATE TABLE IF NOT EXISTS public.staging_sellers
(
    seller_id text COLLATE pg_catalog."default" NOT NULL,
    seller_zip_code_prefix bigint,
    seller_city text COLLATE pg_catalog."default",
    seller_state text COLLATE pg_catalog."default",
    PRIMARY KEY (seller_id)
);

ALTER TABLE IF EXISTS public.staging_orders
    ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id)
    REFERENCES public.staging_customers (customer_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.staging_items
    ADD CONSTRAINT order_id FOREIGN KEY (order_id)
    REFERENCES public.staging_orders (order_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.staging_items
    ADD CONSTRAINT product_id FOREIGN KEY (product_id)
    REFERENCES public.staging_products (product_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.staging_items
    ADD CONSTRAINT seller_id FOREIGN KEY (seller_id)
    REFERENCES public.staging_sellers (seller_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.staging_payments
    ADD CONSTRAINT order_id FOREIGN KEY (order_id)
    REFERENCES public.staging_orders (order_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.staging_reviews
    ADD CONSTRAINT order_id FOREIGN KEY (order_id)
    REFERENCES public.staging_orders (order_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

END;