-- View gear usage summary (already defined as a view)
SELECT * FROM equipment_usage_summary;

-- List species observed in each dive with count and behavior
SELECT dives.date, species.common_name, sightings.count, sightings.behavior
    FROM sightings
    JOIN species ON sightings.species_id = species.species_id
    JOIN dives ON sightings.dive_id = dives.dive_id;

-- Show gear usage per dive, including equipment type and notes
SELECT dives.date, equipment.type, dive_equipment.notes

 -- Count total number of divers by certification level
SELECT certification_level, COUNT(*) AS diver_count
   FROM divers
 GROUP BY certification_level;

 -- List all dives with diver name, location, and date
 SELECT divers.name, locations.name AS location, dives.date
    FROM dives
    JOIN divers ON dives.diver_id = divers.diver_id
    JOIN locations ON dives.location_id = locations.location_id;