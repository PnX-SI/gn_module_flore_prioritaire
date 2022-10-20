# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [2.1.0] - 2022-10-20

⚠️ All changes between v2.0.0 and v2.1.0 require uninstalling and reinstalling the module.
Run the v1 to v2 data migration script again.

#### 🚀 Added

- Added icons to form controls and detail pages.
- Added helper tooltips on forms controls.
- Added triggers to insert, update or delete observations in the Synthese module database tables.
- Added triggers to history insert, update or delete actions on the database `t_zprospect` and `t_apresence` tables.
- Added GPX file loader in the ZP and AP forms maps.
- All models classes show their attributes and values when we use `print()` for their debug.
- ZP list view store filters values between accesses.

### 🔄 Changed

- Improved the names of web services functions.
- Improved the naming of configuration parameters.
- Automatically added default values for `date_max` and `initial_insert` of prospecting zone.
- SRID for module local geometry fields will be read from the data returned by the database.
- Ordered incline nomenclature values.
- Seted observers field as mandatory on ZP form.
- Installation guide is now more detailed. The commands to install and vectorize the DEM are indicated.
- Updated module schema to improve compatibility for migration from v1 of this module.
- Improved migration script, added data to new fields (physiognomies, habitat status...).
- Used injection token for module configuration parameters in views.
- In AP form, the area field is now required and enabled when Point geometry is used.
- Form AP contains new controls and new fieldsets (physiognomies, habitat status...).
- AP list view show frequency, favorable status percent, surface and all AP infos in each expanded row section.
- ZP list view show surface and AP count.

### 🐛 Fixed

- Fixed `insert_zp()`, `insert_ap()` database function : generate `geom_point_4326` value.
- Fixed multiple extenssions syntax used in `.editorconfig` file.
- Fixed module code letters case in web services permissions checks.
- Fixed duplicate geometry added on map when editing a ZP or AP.
- Fix of rights user management in list of ZP.
- Fix triggers that generate ZP and AP area value. We only set the area if it is null.
- Fix enabling of area field and save button for AP form when editing.
- Fixed duplicate organisms names in ZP list.

### 🗑 Removed

- Remove of square draw tool on map.

## [2.0.0] - 2022-09-08

### 🚀 Added

- First release.
- Packaged module for GeoNature 2.9.2
- Giant code refactoring.
- Interface is now usable and has been improved.
- Migration script from GeoNature v1 Priority Flora module get all old data (use of `additional_data` fields).
- Web services are now more REST oriented.
- Database has been reviewed and improved.
- Add database MPD image and a Collection of Postman web services.
