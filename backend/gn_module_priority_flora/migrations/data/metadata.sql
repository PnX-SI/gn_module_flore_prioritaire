-----------------------------------------------------------------------
-- Utility functions
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.get_dataset_id()
    RETURNS INTEGER
    LANGUAGE plpgsql
    IMMUTABLE
AS
$function$
    -- Function that return the id of the Dataset (gn_meta.t_datasets) of this module.
    -- USAGE: SELECT pr_priority_flora.get_dataset_id();
    DECLARE
        datasetId INTEGER;
    BEGIN
        SELECT id_dataset INTO datasetId
        FROM gn_meta.t_datasets
        WHERE dataset_shortname = :metadataCode
        LIMIT 1 ;

        RETURN datasetId ;
    END;
$function$ ;


CREATE OR REPLACE FUNCTION pr_priority_flora.get_source_id()
    RETURNS INTEGER
    LANGUAGE plpgsql
    IMMUTABLE
AS
$function$
    -- Function that return the id of the Source (gn_synthese.t_sources) of this module.
    -- USAGE: SELECT pr_priority_flora.get_source_id();
    DECLARE
        sourceId INTEGER;
    BEGIN
        SELECT id_source INTO sourceId
        FROM gn_synthese.t_sources
        WHERE name_source = :metadataName
        LIMIT 1 ;

        RETURN sourceId ;
    END;
$function$ ;


----------------------------------------------------------------------------------------------------
-- Insertion du cadre d'acquisition dans t_acquisition_frameworks
----------------------------------------------------------------------------------------------------

INSERT INTO gn_meta.t_acquisition_frameworks (
    acquisition_framework_name,
    acquisition_framework_desc,
    id_nomenclature_territorial_level,
    keywords,
    id_nomenclature_financing_type,
    target_description,
    is_parent,
    acquisition_framework_start_date
) VALUES (
    :metadataName,
    'Cadre d''acquisition du module Priority Flora (aka Bilan Stationnel, Bilan Conservatoire Flore).',
    ref_nomenclatures.get_id_nomenclature('NIVEAU_TERRITORIAL', '4'),
    'flore, bilan stationnel, flore prioritaire',
    ref_nomenclatures.get_id_nomenclature('TYPE_FINANCEMENT', '1'),
    'Flore',
    false,
    NOW()
);

----------------------------------------------------------------------------------------------------
-- Insertion du jeu de données dans t_datasets
----------------------------------------------------------------------------------------------------
WITH pf_af_id AS (
    SELECT af.id_acquisition_framework
    FROM gn_meta.t_acquisition_frameworks AS af
    WHERE af.acquisition_framework_name = :metadataName
    ORDER BY af.meta_create_date DESC
    LIMIT 1
)
INSERT INTO gn_meta.t_datasets (
    id_acquisition_framework,
    dataset_name,
    dataset_shortname,
    dataset_desc,
    id_nomenclature_data_type,
    keywords,
    marine_domain,
    terrestrial_domain,
    id_nomenclature_dataset_objectif,
    id_nomenclature_collecting_method,
    id_nomenclature_data_origin,
    id_nomenclature_source_status,
    id_nomenclature_resource_type,
    active,
    meta_create_date
) VALUES (
    (SELECT id_acquisition_framework FROM pf_af_id),
    'Observations de ' || :metadataName,
    :metadataCode,
    'Données du module Priority Flora (aka Bilan Stationnel, Bilan Conservatoire Flore).',
    ref_nomenclatures.get_id_nomenclature('DATA_TYP', '1'),
    'flore, bilan stationnel, flore prioritaire',
    false,
    true,
    ref_nomenclatures.get_id_nomenclature('JDD_OBJECTIFS', '1.1'),
    ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL', '1'),
    ref_nomenclatures.get_id_nomenclature('DS_PUBLIQUE', 'Pu'),
    ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE', 'Te'),
    ref_nomenclatures.get_id_nomenclature('RESOURCE_TYP', '1'),
    true,
    NOW()
);

----------------------------------------------------------------------------------------------------
-- Insertion de la source dans t_sources
----------------------------------------------------------------------------------------------------

INSERT INTO gn_synthese.t_sources (
    name_source,
    desc_source
) VALUES (
    :metadataName,
    'Données du module Priority Flora (aka Bilan Stationnel, Bilan Conservatoire Flore).'
);
