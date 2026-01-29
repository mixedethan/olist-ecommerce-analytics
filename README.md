0# Olist E-Commerce Analytics

Olist is a Brazilian e-commerce marketplace connecting sellers to customers. We want to understand revenue performance, customer behavior, delivery reliability, and seller quality in order to improve both retention and operational efficiency

### Project Goals
1. Build a production style data pipeline (AWS S3 -> RDS PostgreSQL).
2. Create reliable business metrics using SQL analytics.
3. Identify revenue drivers and at-risk customer sgements.
4. Develop a seller performance scorecard to guide operational prioritization.
5. Apply unsupervised learning to customer segmentation.

### Tech Stacks
- AWS S3 - raw storage
- AWS RDS (PostgreSQL) - analytics database
- Python - ETL and modeling
- SQL - analytics & KPIs
- Tableau - visualization

### Data Flow
Raw CSVs -> AWS S3 -> Python ETL -> AWS RDS PostgreSQL -> SQL -> Tableau/Modeling