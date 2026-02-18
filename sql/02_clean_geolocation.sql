				-- staging_geolocation -> cleaning_geolocation --
-- all values
SELECT *
FROM staging.staging_geolocation;

-- distinct cities
SELECT DISTINCT geolocation_city
FROM staging.staging_geolocation;

-- distinct states
SELECT DISTINCT geolocation_state
FROM staging.staging_geolocation;

-- our final view
CREATE OR REPLACE VIEW cleaning.cleaning_geolocation AS
SELECT
	geolocation_zip_code_prefix AS zip_code,
	AVG(geolocation_lat) AS lat, -- eliminate the need for multiple coords for a single zip code
	AVG(geolocation_lng) AS long,
	staging.UNACCENT(UPPER(MAX(geolocation_city))) AS city, -- arbitrarily choose a city name and remove accents for consistency
	UPPER(MAX(geolocation_state)) AS state
FROM staging.staging_geolocation
GROUP BY geolocation_zip_code_prefix;

SELECT *
FROM cleaning.cleaning_geolocation;