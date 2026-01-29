# Olist E-Commerce Analytics

Olist is a Brazilian e-commerce marketplace connecting sellers to customers. The goal of this project is to understand revenue performance, customer behavior, delivery reliability, and seller quality in order to improve both retention and operational efficiency.

### Project Goals
1. Build a production-style data pipeline (AWS S3 -> RDS PostgreSQL -> Tableau).
2. Create reliable business metrics using SQL analytics.

#### Future Goals
- [ ] Develop a seller performance scorecard to guide operational prioritization.
- [ ] Apply unsupervised learning to customer segmentation to identify at-risk customer segments.

### Tech Stacks
- AWS S3 - raw storage
- AWS RDS (PostgreSQL) - analytics database
- Python - ETL and modeling
- SQL - analytics & KPIs
- Tableau - visualizations

### Data Flow
Raw CSVs -> AWS S3 -> Python ETL (Schema-on-Write) -> AWS RDS -> PostgreSQL -> Tableau/Modeling

### ERD Diagram
![ERD Diagram](https://github.com/mixedethan/olist-ecommerce-analytics/blob/ca4120b8c18dbe21b2260e37bf6968148852854e/docs/olist-erd.png)