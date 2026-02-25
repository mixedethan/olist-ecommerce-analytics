# Olist E-Commerce Seller Quality Assurance & Marketplace Health

Olist is a Brazilian e-commerce marketplace that relies on third-party sellers to fulfill customer orders. In these types of decentralized marketplaces, poor seller performance can damage the host platform's brand image. 

The goal of this project is to better understand seller performance, identify the different tiers of sellers, and design a "Seller Scorecard" to optimize the marketplace's health and improve customer retention.

## Executive Summary
WIP

### Questions
1. How can we identify under-performing sellers?
2. Which sellers account for the largest share of 1 star reviews? 
3. Is there a specific city/state that contains more under-performing sellers?
4. Do certain product categories have worse reviews than others?
5. Which sellers drive the highest revenue while maintaining 4.5+ review scores?
6. What percentage of total 1-star reviews are driven by the bottom 10% of sellers?
7. How does missing the 'seller_shipping_dealine' impact the final review score?
8. How much worse are review scored for late deliveries vs on-time deliveries?
9. Are there geographic clusters of underperformance?


### Project Goals
1. Build a production-style data pipeline (AWS S3 → RDS PostgreSQL → Tableau).
2. Create reliable seller KPIs using advanced SQL and Tableau visualizations.
3. Deploy an interactive Tableau dashboard allowing managers to actively filter and view sellers by performance tiers.

## Roadmap

### Phase 1 — Data Pipeline & Architecture (AWS → Postgres)
- [x] Upload raw CSVs in AWS S3
- [x] Develop ERD diagram as well as the actual database structure
- [x] Build Python ingestion pipeline (S3 → RDS Postgres)
- [x] Create DB schema + tables + keys and load data (00_olist_architecture.sql)

### Phase 2 — Data Exploration, Cleaning, & Feature Engineering (staging schema → cleaning schema)
- [x] Define the order of data cleaning based on table dependencies
- [x] Establish 'cleaning' and 'analysis' schema and define cleaning tools (01_setup.sql)
- [x] Explore tables for data types, inconsistencies, duplicates, nulls, and unique traits
- [x] Clean tables via standardization, deduplication, and handling nulls (03_cleanse_entities.sql).
- [x] Derive new features based on existing ones (delivery_lead_time, delta_estimated_actual, days_late, etc.)

### Phase 3 — Seller Overview & KPIs
- [x] Create a single Sellers KPI analysis view that maps each order to seller(s) (joins orders ↔ items ↔ sellers)
    - [x]Baseline seller volume, seller revenue, and review performance
    - [x] Shipping & delivery performance: late delivery rate (estimated vs delivered), avg delivery_lead_time, shipping-deadline misses
- [ ] Segment results by category and geography (category, city/state, lat/long)

### Phase 4 — Define the Seller Scorecard (SQL metrics → Tableau score)
- [ ] Choose final KPI definitions + thresholds (e.g., 1-star rate, late rate, GMV, volume, lead time)
- [ ] Build a final curated dataset for Tableau (one row per seller with all KPIs)
- [ ] Define tier logic (Excellent / Good / Watchlist / Toxic) and document it in the README

### Phase 5 — Tableau Dashboard (Seller Scorecard)
- [ ] Publish Seller Scorecard dashboard (filters: tier, category, state/city, volume, revenue)
- [ ] Add drilldowns: seller profile page + trend views (monthly performance)
- [ ] Add “Top offenders” and “High value / high quality” seller lists


#### Future Goals
- [ ] Apply unsupervised learning (clustering) to both customer and seller segmentation.
- [ ] Translate and categorize (sentiment analysis) reviews in order to better understand customer feedback. Feature extraction to identify specific themes contained in the reviews.

### Tech Stacks
- AWS S3 - raw storage
- AWS RDS (PostgreSQL) - analytics database
- Python - ETL and modeling
- SQL - analytics & KPIs
- Tableau - visualization
- ADD dbt

### Data Flow
Raw CSVs → AWS S3 → Python ETL (Schema-on-Write) → AWS RDS → PostgreSQL → Tableau/Modeling

### ERD Diagram
![ERD Diagram](https://github.com/mixedethan/olist-ecommerce-analytics/blob/ca4120b8c18dbe21b2260e37bf6968148852854e/docs/olist-erd.png)

### Results & Business Recommendation
