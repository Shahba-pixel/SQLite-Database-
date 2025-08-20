-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- Logs each individual dive with core metrics and subjective notes.
-- Links to location and supports analytics like depth trends or dive ratings.
-- Dive logs with metrics and notes
-- Dive logs with metrics and notes
CREATE TABLE dives (
    dive_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    location_id INTEGER,
    diver_id INTEGER,  -- NEW: links to divers table
    depth_max REAL,
    duration INTEGER,
    temperature REAL,
    visibility REAL,
    dive_type TEXT,
    notes TEXT,
    sighting_notes TEXT,
    FOREIGN KEY (location_id) REFERENCES locations(location_id),
    FOREIGN KEY (diver_id) REFERENCES divers(diver_id)
);


-- Dive site metadata
CREATE TABLE locations (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    country TEXT,
    region TEXT,
    gps_lat REAL,
    gps_long REAL,
    site_type TEXT,
    hazards TEXT
);

-- Diver profiles
CREATE TABLE divers (
    diver_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    certification_level TEXT,
    agency TEXT,
    years_experience INTEGER
);

-- Marine species catalog
CREATE TABLE species (
    species_id INTEGER PRIMARY KEY AUTOINCREMENT,
    common_name TEXT,
    scientific_name TEXT,
    category TEXT,
    conservation_status TEXT
);

-- Species sightings per dive
CREATE TABLE sightings (
    sighting_id INTEGER PRIMARY KEY AUTOINCREMENT,
    dive_id INTEGER,
    species_id INTEGER,
    count INTEGER,
    behavior TEXT,
    photo_url TEXT
);

-- Gear inventory
CREATE TABLE equipment (
    equipment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT,
    brand TEXT,
    model TEXT,
    last_service_date TEXT
);

-- Gear usage per dive
CREATE TABLE dive_equipment (
    usage_id INTEGER PRIMARY KEY AUTOINCREMENT,
    dive_id INTEGER,
    equipment_id INTEGER,
    notes TEXT
);

-- Environmental conditions per dive
CREATE TABLE conditions (
    condition_id INTEGER PRIMARY KEY AUTOINCREMENT,
    dive_id INTEGER,
    location_id INTEGER,
    weather TEXT,
    current TEXT,
    tide TEXT,
    entry_type TEXT,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

--Speeds up location-based and time-based filtering.
--Useful for trend analysis by site or season.
CREATE INDEX "idx_dives_location_id" ON "dives" ("location_id");
CREATE INDEX "idx_dives_date" ON "dives" ("date");

--Helps filter divers by skill level or agency.
CREATE INDEX "idx_divers_certification" ON "divers" ("certification_level");

-- Creates a view that summarizes biodiversity by location.
CREATE VIEW "biodiversity_summary" AS
SELECT l.name AS location,
       s.common_name AS species,
       COUNT(*) AS sightings_count
FROM sightings si
JOIN dives d ON si.dive_id = d.dive_id
JOIN locations l ON d.location_id = l.location_id
JOIN species s ON si.species_id = s.species_id
GROUP BY l.name, s.common_name;

CREATE TABLE sighting_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    dive_id INTEGER NOT NULL,
    sighting_notes TEXT,
    timestamp TEXT,  -- Now populated from dives.date
    FOREIGN KEY (dive_id) REFERENCES dives(dive_id)
);

CREATE TRIGGER log_sighting_notes
AFTER INSERT ON dives
WHEN NEW.sighting_notes IS NOT NULL
BEGIN
    INSERT INTO sighting_log (dive_id, sighting_notes, timestamp)
    VALUES (NEW.dive_id, NEW.sighting_notes, NEW.date);
END;

--Summarizes how each equipment item is used across dives.
-- Useful for gear rotation, maintenance scheduling, and operational analytics.
CREATE VIEW equipment_usage_summary AS
SELECT
    e.equipment_id,
    e.type,
    e.brand,
    e.model,
    COUNT(de.dive_id) AS total_dives,
    MAX(d.date) AS last_used,
    AVG(d.depth_max) AS avg_depth_used,
    AVG(d.duration) AS avg_duration_used
FROM equipment e
JOIN dive_equipment de ON e.equipment_id = de.equipment_id
JOIN dives d ON de.dive_id = d.dive_id
GROUP BY e.equipment_id, e.type, e.brand, e.model
ORDER BY total_dives DESC;
