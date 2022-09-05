# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased

### Added

- Add icons to form controls and detail pages
- Add helper tooltips on form controls
- Add triggers to insert, update or delete observations in Synthese module database tables.
- Add triggers to history insert, update or delete actions on t_zprospect and t_apresence database tables.

### Changed

- Improve the names of web services functions
- Improve the naming of configuration parameters
- Automatically add default values for date_max and initial_insert of prospect zone.
- SRID for module local geometry fields will be read from the data returned by the database.

### Fixed

- Fix insert_zp(), insert_ap() database function : generate geom_point_4326 value.
- Fix module code letters case in web services permissions checks
###

## [1.0.0] - 2022-08-24

### Added

- First release.
- Packaged module for GeoNature 2.9.2
- Giant code refactoring.
- Interface is now usable and has been improved.
- Migration script from GeoNature v1 Priority Flora module get all old data (use of `additional_data` fields).
- Web services are now more REST oriented.
- Database has been reviewed and improved.
- Add database MPD image and a Collection of Postman web services.
