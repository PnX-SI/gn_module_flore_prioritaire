# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.3.0] - 2024-08-20

#### 🚀 Added

- Compatibility with GeoNature 2.14
- Possibility of choosing the Dataset in the creation of ZP.
- Creation of datasets, acquisitions frameworks and taxa list is done in a separate Alembic branch (`priority_flora_sample`)
- The parameter for the list of taxa is no longer mandatory. By default, we query all Taxref. It can be restricted via the `id_taxon_list` parameter.
- Possibility to export prospect zones separately from presence areas

### 🐛 Fixed

- Fixed a redirection bug caused by bootstrap “tabs” on ZP info sheets and switching to Material tabs.
- Handle ZP and AP exports with a null value for geometry fields

### 🔄 Changed

- The field `id_source` used in trigger previously get from `__init__.py` is now get from module source code (via `gn_synthese.t_sources`).
- ⚠️ `code_taxon_list` parameter renamed `id_taxon_list` now, must be set with a value of the primary key (`id_liste`) of `taxonomie.bib_listes` table.

## [2.2.1] - 2023-11-15

### 🐛 Fixed

- Fixed use of datetime in export web service

## [2.2.0] - 2023-10-13

#### 🚀 Added

- Added a right management of this module in a section of the installation documentation.
- Added possibility to sort, select and rename export columns names.
- Added new stats webservice for Conservation Strategy module.

### 🐛 Fixed

- Fixed changelog text errors.
- Fixed migration script. We are now using the correct geometry field for the ZP geometry.
- Enable edit mode on the `pnx-leaflet-filelayer` component to avoid deletion of the GPX file when geometry is drawn.
- In the ZP map list view, organism filter no longer returns "Internal Server Error". Export is possible again.
- User SRID 4326 for GeoJson export.
- Added missing ZP and AP geometry fields in CSV export.

### 🔄 Changed

- In the ZP map list view, the taxon filter tooltip is now displayed above the filter.
- In the ZP details view, in expanded line section of the AP details, `NA` is displayed if no counting is being done.
- In the AP form view, the percentage label is dynamically changed from "Estimated frequency in %" to "Computed frequency in %" when the frequency method value is "Transect".
- Changed Prettier config. Trailing comma is not removed when compatible with ES5.
- Reformatted all frontend source code files with Prettier.
- Reformatted all backend source code files with Black.
- GeoJson export includes ZP geometries.
- Used english for export view fields.
- Improved debug for models DB classes with a parent class.

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
