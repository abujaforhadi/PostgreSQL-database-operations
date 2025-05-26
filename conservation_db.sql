-- Active: 1747412849250@@127.0.0.1@5432CREATE DATABASE conservation_db;
-- create DATABASE conservation_db;
CREATE Table rangers (
    ranger_id SERIAL PRIMARY KEY NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL

)
-- Create the conservation database and tables for rangers, species, and sightings
CREATE TABLE species(
species_id SERIAL PRIMARY KEY NOT NULL,
common_name VARCHAR (50),
scientific_name VARCHAR (50) ,
discovery_date DATE,
conservation_status VARCHAR(50) NOT NULL
)
-- Create the sightings table with foreign keys referencing rangers and species
CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY NOT NULL,
    ranger_id INT NOT NULL,
    species_id INT NOT NULL,
    sighting_date TIMESTAMP NOT NULL,
    "location" VARCHAR(100) NOT NULL,
    notes VARCHAR(255),
    FOREIGN KEY (ranger_id) REFERENCES rangers(ranger_id),
    FOREIGN KEY (species_id) REFERENCES species(species_id)
);

-- Insert initial data into the rangers table
INSERT INTO rangers("name", region) 
VALUES 
('Alice Gree', 'Northern Hills'),
('Bob White', 'River Delta'),
('Carol King', 'Mountain Range');

SELECT * FROM rangers;
-- -- Insert initial data into the species table
INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status)
VALUES
('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

SELECT * FROM species;
  -- Insert initial data into the sightings table
INSERT INTO sightings ( species_id,ranger_id,  "location",sighting_date, notes)
VALUES
(1,1,'Peak Ridge','2024-05-10 07:45:00',' Camera trap image captured'),
(2,2,'Bankwood Area','2024-05-12 16:20:00','Juvenile seen'),
(3,3,' Bamboo Grove East','2024-05-15 09:10:00','Feeding observed'),
(1,2,'Snowfall Pass','2024-05-18 18:30:00',NULL)

SELECT * FROM sightings;

-- Register a new ranger with provided data with name = 'Derek Fox' and region = 'Coastal Plains'
INSERT INTO rangers("name", region)
VALUES 
('Derek Fox', 'Coastal Plains');

-- Count unique species ever sighted.
SELECT COUNT(DISTINCT species_id) AS unique_species_count
FROM sightings;

-- Find all sightings where the location includes "Pass".
SELECT * 
FROM sightings
WHERE "location" LIKE '%Pass%';

-- List each ranger's name and their total number of sightings.
SELECT "name", COUNT(sighting_id) AS total_sightings
FROM rangers, sightings
WHERE rangers.ranger_id = sightings.ranger_id
GROUP BY "name";

-- List species that have never been sighted.

SELECT species.common_name
FROM species
LEFT JOIN sightings  ON species.species_id = sightings.species_id
WHERE sightings.species_id IS NULL;

-- Show the most recent 2 sightings.
-- Show the most recent 2 sightings.
SELECT 
  species.common_name, 
  sightings.sighting_date, 
  rangers.name
FROM sightings
JOIN species ON sightings.species_id = species.species_id
JOIN rangers ON sightings.ranger_id = rangers.ranger_id
ORDER BY sightings.sighting_date DESC
LIMIT 2;

-- Update all species discovered before year 1800 to have status 'Historic'.

UPDATE species
SET conservation_status = 'Historic'
WHERE discovery_date < '1800-01-01';

--  Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'.

-- Morning: before 12 PM
-- Afternoon: 12 PM–5 PM
-- Evening: after 5 PM
SELECT 
  sightings.sighting_id,
  CASE 
    WHEN EXTRACT(HOUR FROM sightings.sighting_date) < 12 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM sightings.sighting_date) < 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS time_of_day
FROM sightings
JOIN species ON sightings.species_id = species.species_id
JOIN rangers ON sightings.ranger_id = rangers.ranger_id
ORDER BY sightings.sighting_date;

-- Delete rangers who have never sighted any species
DELETE FROM rangers
WHERE ranger_id NOT IN (
    SELECT DISTINCT ranger_id
    FROM sightings
);
