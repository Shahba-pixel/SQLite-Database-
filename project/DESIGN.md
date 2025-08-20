# Design Document

By Abdullah Shahba

Video overview: <https://www.youtube.com/watch?v=SH0GVoVA7R8>

## Scope

This database facilitates the logging, analysis, and exploration of scuba diving activities. It supports tracking dive metrics, marine life sightings, diver participation, and environmental conditions. The schema is designed to be normalized, analytics-ready, and extensible for future enhancements.


* Dive logs with depth, duration, and subjective ratings
* Locations with GPS and hazard metadata
* Divers and their certifications
* Species sightings with behavioral notes
* Equipment usage and maintenance tracking
* Environmental conditions per dive
Out of scope are elements like 

Commercial pricing, dive packages, or financial transactions

Certification validation against external agencies

Real-time data syncing from dive computers

Multi-user authentication or role-based access

## Functional Requirements
Users Should Be Able To:
* Log new dives with detailed metrics

* Track which species were seen on each dive

* Associate divers and equipment with specific dives

* Query dives by location, rating, or biodiversity

* Analyze gear usage and servicing needs

* View environmental conditions per site
Beyond Scope:
Real-time data syncing from dive computers
Mobile app interface or GPS tracking
Automated species recognition from photos
Multi-user authentication or permissions
## Representation

Entities are captured in SQLite tables with the following schema.

### Entities

### Dives 
dive_id, date, location_id, depth_max, depth_avg, duration, temperature, visibility, dive_type, dive_rating, notes Types: INTEGER, TEXT, REAL Constraints: Primary key on dive_id, foreign key to locations Reasoning: Captures core dive metrics and links to location for spatial analysis.
### Locations 
location_id, name, country, gps_lat, gps_long, site_type, hazards Types: TEXT, REAL Constraints: Primary key on location_id Reasoning: Enables geo-based queries and hazard tracking.
### Divers 
diver_id, name, certification_level, agency, years_experience Types: TEXT, INTEGER Constraints: Primary key on diver_id Reasoning: Supports multi-diver logging and skill-based filtering.
### Species 
species_id, common_name, scientific_name, category, conservation_status Types: TEXT Constraints: Primary key on species_id Reasoning: Enables biodiversity tracking and conservation analysis.
### Equipment 
equipment_id, type, brand, model, last_service_date Types: TEXT, DATE Constraints: Primary key on equipment_id Reasoning: Tracks gear inventory and maintenance.
### Conditions 
dive_id, location_id, weather, current, tide, entry_type Types: TEXT Constraints: Primary key on dive_id, foreign key to locations Reasoning: Captures environmental context for each dive.

### Relationships
[ER Diagram](ERD.png)

One-to-many: locations → dives

One-to-many: divers → dives

Many-to-many: dives ↔ equipment via dive_equipment

Many-to-many: dives ↔ species via sightings

## Optimizations

* equipment_usage_summary
Aggregates gear usage metrics, including total dives, average depth, and last used date. Useful for operational planning and maintenance prioritization.
* dive summary
Quickly filter dives by diver or location

* log sighting notes
-- Trigger to automatically log sighting notes from a dive into the sighting_log table

## Limitations
No real-time data: Dive logs must be entered manually or imported from CSV
Limited media support: Photo URLs are stored but not managed or validated
No user authentication: All data is assumed to be entered by a single user
Environmental data is static: Weather, tide, and current are manually entered, not fetched live

## Future Enhancements

Add user authentication and role-based access

Expand schema to support dive center scheduling and business analytics