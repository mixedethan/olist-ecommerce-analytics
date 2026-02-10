CREATE SCHEMA IF NOT EXISTS cleaning;

-- introduce an unaccent module to help standardize the location names
CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA staging;
SELECT * FROM pg_extension WHERE extname = 'unaccent';