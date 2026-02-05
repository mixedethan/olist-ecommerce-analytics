# Olist E-Commerce Analytics

Olist is a Brazilian e-commerce marketplace connecting sellers to customers. The goal of this project is to better understand our business, revenue performance, customer behavior, delivery reliability, and seller quality in order to improve both retention and operational efficiency.

### Questions
1. What is the distribution of customers with multiple orders? 5+ orders? 10+ orders?
2. Where are our customer geographically distributed?
3. How often do orders contain more then one item?
4. How often do customers pay in installments? Distribution of installments?
5. What is the distribution of payments values? How much to customers spend on average?
6. What is the distribution of the difference in time between when a product is ordered and when it arrived to the customer? On average, how long does the logistic partner take?
7. What is the distribution of our product categories? What is the distribution of product's sizes?

### Project Goals
1. Build a production-style data pipeline (AWS S3 -> RDS PostgreSQL -> Tableau).
2. Create reliable business metrics using SQL analytics and Tableau visualizations.

#### Future Goals
- [ ] Develop a seller performance scorecard.
- [ ] Apply unsupervised learning (clustering) to both customer and seller segmentation.
- [ ] Translate and categorize (sentiment analysis) reviews in order to better understand customer feedback. Feature extraction to identify specific themes contained in the reviews.

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