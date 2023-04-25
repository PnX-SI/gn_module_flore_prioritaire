-------------------------------------------------------------------------
-- COMMONS : create PRIORITY_FLORA module
-------------------------------------------------------------------------

UPDATE gn_commons.t_modules
SET
  module_label = 'Bilan stationnel',
  module_picto = 'fa-pagelines',
  module_desc = 'Module de Suivi de la flore prioritaire d''un territoire.',
  module_doc_url = 'https://github.com/PnX-SI/gn_module_flore_prioritaire'
WHERE module_code = 'PRIORITY_FLORA' ;

INSERT INTO gn_synthese.t_sources
(name_source, desc_source, entity_source_pk_field, id_module)
VALUES(
  'Bilan stationnel v2', 
  'Données issues du module bilan stationnel v2',
  'pr_priority_flora.t_apresence.id_zp', 
  (select id_module FROM gn_commons.t_modules where module_code = 'PRIORITY_FLORA')
);


------------------------------------------------------------------------
-- Nomenclature: Type de pente
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (
  mnemonique,
  label_default,
  definition_default,
  label_fr,
  definition_fr,
  source
) VALUES (
  'INCLINE_TYPE',
  'Type de pente',
  'Nomenclature des types de pentes',
  'Type de pentes',
  'Nomenclatures des types de pentes.',
  'PNE'
);


------------------------------------------------------------------------
-- Nomenclature: Physionomies
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (
  mnemonique,
  label_default,
  definition_default,
  label_fr,
  definition_fr,
  source
) VALUES (
  'PHYSIOGNOMY_TYPE',
  'Type de physionomie',
  'Nomenclature des physionomies.',
  'Type de physionomie',
  'Nomenclature des physionomies.',
  'CBNA'
);


------------------------------------------------------------------------
-- Nomenclature: État de conservation de l'habitat
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (
  mnemonique,
  label_default,
  definition_default,
  label_fr,
  definition_fr,
  source
) VALUES (
  'HABITAT_STATUS',
  'Type d''etat d''habitat',
  'Nomenclature des types d''états d''habitat',
  'Type d''état d''habitat',
  'Nomenclature des type d''états d''habitat',
  'CBNA'
);


------------------------------------------------------------------------
-- Nomenclature: Type de menace
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (
  mnemonique,
  label_default,
  definition_default,
  label_fr,
  definition_fr,
  source
) VALUES (
  'THREAT_LEVEL',
  'Niveau de menace',
  'Nomenclature des niveaux de menace ou perturbation d''une aire de présence.',
  'Niveau de menace',
  'Nomenclature des niveaux de menace ou perturbation d''une aire de présence.',
  'CBNA'
);


------------------------------------------------------------------------
-- Nomenclature: Type de phénologie
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (
  mnemonique,
  label_default,
  definition_default,
  label_fr,
  definition_fr,
  source
) VALUES (
  'PHENOLOGY_TYPE',
  'Type de phénologie',
  'Nomenclature des types de phénologies',
  'Type de phénologies',
  'Nomenclatures des types de phénologies.',
  'CBNA'
);


------------------------------------------------------------------------
-- Nomenclature: Méthode de la fréquence
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (
  mnemonique,
  label_default,
  definition_default,
  label_fr,
  definition_fr,
  source
) VALUES (
  'FREQUENCY_METHOD',
  'Méthode de la fréquence',
  'Méthode utilisée pour calculer la fréquence.',
  'Méthode de la fréquence',
  'Méthode utilisée pour calculer la fréquence.',
  'CBNA'
);


------------------------------------------------------------------------
-- Nomenclature: Type de comptage
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (
  mnemonique,
  label_default,
  definition_default,
  label_fr,
  definition_fr,
  source
) VALUES (
  'COUNTING_TYPE',
  'Type de comptage',
  'Nomenclature des types de comptage des taxons présent dans une surface donnée.',
  'Type de comptage',
  'Nomenclature des types de comptage des taxons présent dans une surface donnée.',
  'CBNA'
);

