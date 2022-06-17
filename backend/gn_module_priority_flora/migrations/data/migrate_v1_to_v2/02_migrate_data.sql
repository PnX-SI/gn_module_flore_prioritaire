-- Migrate data from migrate_v1_florepatri and migrate_v1_utilisateurs
-- into GeoNature v2 Priority Flora module schema.
-- Usage:
--  1. go to sql directory: cd backend/gn_module_priority_flora/migrations/data/migrate_v1_to_v2
--  2. migrate data with scripts #2 :
--    export PGPASSWORD="<db_pass>"; psql -h "<db_host>" -U "<db_user>" -d "<db_name>" -f "02_migrate_data.sql"
--
-- where:
-- - <db_pass>: GeoNature v2 database user password.
-- - <db_host>: GeoNature v2 database host name. Ex.: "localhost".
-- - <db_user>: GeoNature v2 database user name with write access. Ex.: "geonatadmin".
-- - <db_name>: GeoNature v2 database name. Ex.: "geonature2db".

BEGIN;

\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "t_zprospect"'
INSERT INTO pr_priority_flora.t_zprospect (
    indexzp,
    date_min,
    date_max,
    topo_valid,
    initial_insert,
    cd_nom,
    id_dataset,
    unique_id_sinp_zp,
    geom_local,
    geom_4326,
    geom_point_4326
)
    SELECT
        indexzp,
        dateobs,
        dateobs,
        topo_valid,
        saisie_initiale,
        cd_nom,
        id_lot,
        unique_id_sinp_grp,
        the_geom_local,
        st_transform(geom_mixte_3857, 4326),
        st_transform(geom_point_3857, 4326)
    FROM v1_florepatri.t_zprospection
    WHERE supprime = 'false' ;


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Update sequence for "t_zprospect"'
SELECT setval(
    'pr_priority_flora.t_zprospect_indexzp_seq',
    (SELECT max(indexzp) FROM pr_priority_flora.t_zprospect),
    true
) ;


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "cor_zp_obs"'
INSERT INTO pr_priority_flora.cor_zp_obs (
    indexzp,
    id_role
)
    SELECT
        obs.indexzp,
        codeobs
    FROM v1_florepatri.cor_zp_obs AS obs
        JOIN pr_priority_flora.t_zprospect AS z
            ON z.indexzp = obs.indexzp ; -- join to remove supprime=false ;


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "t_apresence"'
INSERT INTO pr_priority_flora.t_apresence(
    indexap,
    area,
    topo_valid,
    altitude_min,
    altitude_max,
    frequency,
    "comment",
    indexzp,
    id_nomenclatures_pente,
    id_nomenclatures_counting,
    id_nomenclatures_habitat,
    id_nomenclatures_phenology,
    id_history_action,
    total_min,
    total_max,
    unique_id_sinp_ap,
    geom_local,
    geom_4326,
    geom_point_4326
)
    SELECT
        a.indexap,
        surfaceap::FLOAT,
        a.topo_valid,
        altitude_retenue,
        altitude_retenue,
        frequenceap,
        remarques,
        a.indexzp,
        NULL, -- Pas de notion de pente
        ref_nomenclatures.get_id_nomenclature('FLORE_PATRI_METHODO_DENOM',a.id_comptage_methodo::text), -- counting
        NULL,
        ref_nomenclatures.get_id_nomenclature('TYPE_PHENOLOGIE',a.codepheno::text), -- counting
        NULL, -- id_history_action
        total_steriles+total_fertiles , --total_min
        total_steriles+total_fertiles, -- total max
        unique_id_sinp_fp,
        the_geom_local,
        st_transform(the_geom_3857, 4326),
        st_centroid(st_transform(the_geom_3857, 4326))
    FROM v1_florepatri.t_apresence AS a
        JOIN pr_priority_flora.t_zprospect AS z
            ON z.indexzp = a.indexzp ;


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Update sequence for "t_apresence"'
SELECT setval(
    'pr_priority_flora.t_apresence_indexap_seq',
    (SELECT max(indexap) FROM pr_priority_flora.t_apresence),
    true
) ;


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "cor_ap_perturb"'
INSERT INTO pr_priority_flora.cor_ap_perturb
    SELECT
        a.indexap,
        id_nomenclature,
        NULL AS pres_effective
    FROM v1_florepatri.cor_ap_perturb AS cor
        JOIN pr_priority_flora.t_apresence AS a
            ON a.indexap = cor.indexap
        JOIN v1_florepatri.bib_perturbations AS b
            ON b.codeper = cor.codeper
        JOIN ref_nomenclatures.t_nomenclatures AS t
            ON t.label_default = b.description
        JOIN ref_nomenclatures.bib_nomenclatures_types AS bib
            ON (bib.id_type = t.id_type AND bib.mnemonique = 'TYPE_PERTURBATION') ;


\echo '----------------------------------------------------------------------------'
\echo 'TAXONOMIE => Insert data into "bib_attributs"'
INSERT INTO taxonomie.bib_attributs (
    nom_attribut,
    label_attribut,
    obligatoire,
    desc_attribut,
    type_attribut,
    type_widget,
    id_theme,
    liste_valeur_attribut
)
    SELECT
        'physionomie',
        'Physionomie',
        'false',
        'Physionomie principale du taxon',
        'text',
        'textarea',
        1,
        '{"values":[' || string_agg ('"' || ph.nom_physionomie || '"',',') || ']}'
    FROM v1_florepatri.bib_physionomies AS ph ;


\echo '----------------------------------------------------------------------------'
\echo 'TAXONOMIE => Insert data into "cor_taxon_attribut"'
INSERT INTO taxonomie.cor_taxon_attribut (
    cd_ref,
    valeur_attribut,
    id_attribut
)
    SELECT
        DISTINCT tx.cd_ref,
        string_agg(bp.nom_physionomie, '&') AS valeur_atrribut,
        (SELECT id_attribut FROM taxonomie.bib_attributs WHERE nom_attribut = 'physionomie')
    FROM v1_florepatri.cor_ap_physionomie AS cap
        JOIN v1_florepatri.t_apresence AS ta
            ON ta.indexap = cap.indexap
        JOIN v1_florepatri.t_zprospection AS tz
            ON tz.indexzp = ta.indexzp
        JOIN taxonomie.taxref AS tx
            ON tx.cd_nom = tz.cd_nom
        JOIN v1_florepatri.bib_physionomies AS bp
            ON bp.id_physionomie = cap.id_physionomie
    GROUP BY tx.cd_ref ;


\echo '----------------------------------------------------------------------------'
\echo 'TAXONOMIE => Insert data into "bib_listes"'
INSERT INTO taxonomie.bib_listes (
    nom_liste,
    desc_liste,
    code_liste
) VALUES(
    'Flore prioritaire',
    'Liste de taxon pour le module flore prioritaire',
    'FLORE_PRIO'
) ;


\echo '----------------------------------------------------------------------------'
\echo 'TAXONOMIE => Insert data into "bib_listes"'
INSERT INTO taxonomie.cor_nom_liste (
    id_liste,
    id_nom
)
SELECT
    (SELECT id_liste FROM taxonomie.bib_listes WHERE code_liste = 'FLORE_PRIO'),
    id_nom
FROM taxonomie.bib_noms AS b
    JOIN v1_florepatri.bib_taxons_fp AS t
        ON b.cd_nom = t.cd_nom ;


\echo '----------------------------------------------------------------------------'
\echo 'COMMIT if all goes well !'
COMMIT;
