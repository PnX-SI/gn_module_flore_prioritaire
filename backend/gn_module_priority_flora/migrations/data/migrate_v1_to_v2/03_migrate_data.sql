-- Migrate data from v1_florepatri and utilisateurs
-- into GeoNature v2 Priority Flora module schema.
-- Usage:
--  1. go to sql directory: cd backend/gn_module_priority_flora/migrations/data/migrate_v1_to_v2
--  2. create foreign data table with script #1 :
--    export PGPASSWORD="<db_pass>"; \
--      psql -h "<db_host>" -U "<db_user>" -d "<db_name>" -f "01_create_fdw.sql"
--  3. migrate users with scripts #2 :
--    export PGPASSWORD="<db_pass>"; \
--      psql -h "<db_host>" -U "<db_user>" -d "<db_name>" -f "02_migrate_users.sql"
--  4. migrate data with scripts #3 :
--    export PGPASSWORD="<db_pass>"; \
--      psql -h "<db_host>" -U "<db_user>" -d "<db_name>" -f "03_migrate_data.sql"
--
-- where:
-- - <db_pass>: GeoNature v2 database user password.
-- - <db_host>: GeoNature v2 database host name. Ex.: "localhost".
-- - <db_user>: GeoNature v2 database user name with write access. Ex.: "geonatadmin".
-- - <db_name>: GeoNature v2 database name. Ex.: "geonature2db".

BEGIN;

-- insert missing nomenclatures
INSERT INTO ref_nomenclatures.t_nomenclatures
(
	id_type, 
	cd_nomenclature, 
	mnemonique, 
	label_default, 
	definition_default, 
	label_fr,
	definition_fr,
	"source",
	active
)
 select 
 ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),
 case 
 	when  starts_with(b.description, 'Avalanche : app')  then 'AvalAp'
 	else left(b.description, 4)
 end, 
 b.description,
 b.description, 
 concat(b.description, ' | ', b.classification), 
 b.description, 
 concat(b.description, ' | ', b.classification),
 'CBNA',
 true
 from v1_florepatri.bib_perturbations AS b
 left join ref_nomenclatures.t_nomenclatures AS tn  ON tn.label_default = b.description
 where label_default is null;

CREATE OR REPLACE FUNCTION pr_priority_flora.get_source_id()
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
    -- Function that return the id of the Source (gn_synthese.t_sources) of this module.
    -- USAGE: SELECT pr_priority_flora.get_source_id();
    DECLARE
        sourceId INTEGER;
    BEGIN
        SELECT id_source INTO sourceId
        FROM gn_synthese.t_sources s
        join gn_commons.t_modules m using(id_module)
        where m.module_code = 'PRIORITY_FLORA'
        LIMIT 1 ;

        RETURN sourceId ;
    END;
$function$
;

\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "t_zprospect"'

ALTER TABLE pr_priority_flora.t_zprospect DISABLE TRIGGER tri_change_meta_dates_zp ;


INSERT INTO pr_priority_flora.t_zprospect (
  id_dataset,
  cd_nom,
  date_min,
  date_max,
  geom_local,
  geom_4326,
  geom_point_4326,
  area,
  initial_insert,
  topo_valid,
  additional_data,
  meta_create_date,
  meta_update_date
)
 SELECT
    :id_dataset,
    cd_nom,
    dateobs,
    dateobs,
    st_transform(the_geom_3857, 2154),
    public.st_transform(the_geom_3857, 4326),
    public.st_transform(geom_point_3857, 4326),
    public.st_area(st_transform( the_geom_3857, 2154)),
    saisie_initiale,
    topo_valid,
    json_build_object(
      'migrateOriginalInfos',
      json_build_object(
        'indexZp', mtz.indexzp,
        'topoValid', mtz.topo_valid,
        'validation', mtz.validation,
        'erreurSignalee', mtz.erreur_signalee,
        'taxonSaisie', mtz.taxon_saisi,
        'idOrganisme', mtz.id_organisme
      )
    ),
    date_insert,
    date_update
  FROM v1_florepatri.t_zprospection AS mtz
  WHERE supprime = 'false'
    AND NOT EXISTS (
      SELECT 'X'
      FROM pr_priority_flora.t_zprospect AS tz
      WHERE CAST(tz.additional_data-> 'migrateOriginalInfos' ->> 'indexZp' AS BIGINT) = mtz.indexzp
    )
  ;


ALTER TABLE pr_priority_flora.t_zprospect ENABLE TRIGGER tri_change_meta_dates_zp ;


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "cor_zp_obs"'
INSERT INTO pr_priority_flora.cor_zp_obs (
  id_zp,
  id_role
)
  SELECT
    tz.id_zp,
    roles.id_role
  FROM v1_florepatri.cor_zp_obs AS mcor
    JOIN utilisateurs.t_roles roles
      ON roles.id_role = mcor.codeobs
    JOIN pr_priority_flora.t_zprospect AS tz
      ON CAST(tz.additional_data-> 'migrateOriginalInfos' ->> 'indexZp' AS BIGINT) = mcor.indexzp



\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "t_apresence"'

ALTER TABLE pr_priority_flora.t_apresence DISABLE TRIGGER tri_change_meta_dates_ap ;
INSERT INTO pr_priority_flora.t_apresence(
  id_zp,
  geom_local,
  geom_4326,
  geom_point_4326,
  area,
  altitude_min,
  altitude_max,
  id_nomenclature_phenology,
  id_nomenclature_frequency_method,
  frequency,
  id_nomenclature_counting,
  total_min,
  total_max,
  "comment",
  topo_valid,
  additional_data,
  meta_create_date,
  meta_update_date
)
  SELECT
    tz.id_zp,
    mta.the_geom_local,
    st_transform(mta.the_geom_3857, 4326),
    st_centroid(st_transform(mta.the_geom_3857, 4326)),
    mta.surfaceap::FLOAT,
    mta.altitude_retenue,
    mta.altitude_retenue,
    ref_nomenclatures.get_id_nomenclature('PHENOLOGY_TYPE', mta.codepheno::text),
    ref_nomenclatures.get_id_nomenclature('FREQUENCY_METHOD', mta.id_frequence_methodo_new::text),
    mta.frequenceap,
    ref_nomenclatures.get_id_nomenclature('COUNTING_TYPE', mta.id_comptage_methodo::text),
    mta.total_steriles + mta.total_fertiles , --total_min
    mta.total_steriles + mta.total_fertiles, -- total max
    mta.remarques,
    mta.topo_valid,
    json_build_object(
      'migrateOriginalInfos',
      json_build_object(
        'indexAp', mta.indexap,
        'insee', mta.insee,
        'nbTransectsAp', mta.nb_transects_frequence,
        'nbPointsAp', mta.nb_points_frequence,
        'nbContactsAp', mta.nb_contacts_frequence,
        'nbPlacettesComptage', mta.nb_placettes_comptage,
        'surfacePlacetteComptage', mta.surface_placette_comptage,
        'longueurPas', mta.longueur_pas,
        'effectifPlacettesSteriles', mta.effectif_placettes_steriles,
        'effectifPlacettesFertiles', mta.effectif_placettes_fertiles,
        'totalSteriles', mta.total_steriles,
        'totalFertiles', mta.total_fertiles
      )
    ) AS additional_data,
    mta.date_insert,
    mta.date_update
  FROM v1_florepatri.t_apresence AS mta
    INNER JOIN pr_priority_flora.t_zprospect AS tz
      ON CAST(tz.additional_data-> 'migrateOriginalInfos' ->> 'indexZp' AS BIGINT) = mta.indexzp
  WHERE mta.supprime = FALSE
    AND mta.the_geom_local  IS NOT null
--    AND NOT EXISTS (
--      SELECT 'X'
--      FROM pr_priority_flora.t_apresence AS ta
--      WHERE CAST(ta.additional_data-> 'migrateOriginalInfos' ->> 'indexAp' AS BIGINT) = mta.indexap
--    )
  ;

ALTER TABLE pr_priority_flora.t_apresence ENABLE TRIGGER tri_change_meta_dates_ap ;


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "cor_ap_perturbation"'


INSERT INTO pr_priority_flora.cor_ap_perturbation (
  id_ap,
  id_nomenclature,
  effective_presence
)

  SELECT
    a.id_ap,
    t.id_nomenclature,
    NULL
  FROM v1_florepatri.cor_ap_perturb AS mcor
    JOIN pr_priority_flora.t_apresence AS a
      ON CAST(a.additional_data-> 'migrateOriginalInfos' ->> 'indexAp' AS BIGINT) = mcor.indexap
    JOIN v1_florepatri.bib_perturbations per on per.codeper = mcor.codeper
    join ref_nomenclatures.t_nomenclatures t on t.label_default = per.description
    JOIN ref_nomenclatures.bib_nomenclatures_types AS bib
      ON (bib.id_type = t.id_type AND bib.mnemonique = 'TYPE_PERTURBATION')


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "cor_ap_physiognomy"'
INSERT INTO pr_priority_flora.cor_ap_physiognomy (
  id_ap,
  id_nomenclature
)
  SELECT
    a.id_ap,
    n.id_nomenclature
  FROM v1_florepatri.cor_ap_physionomie AS mcor
    JOIN pr_priority_flora.t_apresence AS a
      ON CAST(a.additional_data-> 'migrateOriginalInfos' ->> 'indexAp' AS BIGINT) = mcor.indexap
    JOIN v1_florepatri.bib_physionomies AS b on b.id_physionomie = mcor.id_physionomie
    join ref_nomenclatures.t_nomenclatures n on n.cd_nomenclature = b.code_physionomie
    JOIN ref_nomenclatures.bib_nomenclatures_types AS bib
      ON (bib.id_type = n.id_type AND bib.mnemonique = 'PHYSIOGNOMY_TYPE')

-- \echo '----------------------------------------------------------------------------'
-- \echo 'TAXONOMIE => Update sequence for "bib_attributs"'
-- SELECT setval(
--   'taxonomie.bib_attributs_id_attribut_seq',
--   (SELECT max(id_attribut) FROM taxonomie.bib_attributs),
--   true
-- ) ;

-- \echo '----------------------------------------------------------------------------'
-- \echo 'TAXONOMIE => Insert data into "bib_attributs"'
-- WITH attr_values AS (
-- 	SELECT '{"values":[' || string_agg ('"' || ph.nom_physionomie || '"',',') || ']}' AS attr_value
--   FROM v1_florepatri.bib_physionomies AS ph
-- )
-- INSERT INTO taxonomie.bib_attributs (
--   nom_attribut,
--   label_attribut,
--   obligatoire,
--   desc_attribut,
--   type_attribut,
--   type_widget,
--   id_theme,
--   liste_valeur_attribut
-- )
--   SELECT
--     'physionomie',
--     'Physionomie',
--     'false',
--     'Physionomie principale du taxon.',
--     'text',
--     'multiselect',
--     1,
--     av.attr_value
--   FROM attr_values AS av
--   WHERE NOT EXISTS (
--     SELECT 'X'
--     FROM taxonomie.bib_attributs AS ba
--     WHERE ba.nom_attribut = 'physionomie'
--   )
--   ;


-- \echo '----------------------------------------------------------------------------'
-- \echo 'TAXONOMIE => Insert data into "cor_taxon_attribut"'
-- INSERT INTO taxonomie.cor_taxon_attribut (
--   cd_ref,
--   valeur_attribut,
--   id_attribut
-- )
--   SELECT DISTINCT
--     tx.cd_ref,
--     string_agg(bp.nom_physionomie, ' & ') AS valeur_attribut,
--     (SELECT id_attribut FROM taxonomie.bib_attributs WHERE nom_attribut = 'physionomie')
--   FROM v1_florepatri.cor_ap_physionomie AS cap
--     JOIN v1_florepatri.t_apresence AS ta
--       ON ta.indexap = cap.indexap
--     JOIN v1_florepatri.t_zprospection AS tz
--       ON tz.indexzp = ta.indexzp
--     JOIN taxonomie.taxref AS tx
--       ON tx.cd_nom = tz.cd_nom
--     JOIN v1_florepatri.bib_physionomies AS bp
--       ON bp.id_physionomie = cap.id_physionomie
--   WHERE NOT EXISTS (
--     SELECT 'X'
--     FROM taxonomie.cor_taxon_attribut AS cor
--     WHERE cor.cd_ref = tx.cd_ref
--   )
--   GROUP BY tx.cd_ref ;

-- \echo '----------------------------------------------------------------------------'
-- \echo 'TAXONOMIE => Update sequence for "bib_listes"'
-- SELECT setval(
--   'taxonomie.bib_listes_id_liste_seq',
--   (SELECT max(id_liste) FROM taxonomie.bib_listes),
--   true
-- ) ;

-- \echo '----------------------------------------------------------------------------'
-- \echo 'TAXONOMIE => Insert data into "bib_listes"'
-- INSERT INTO taxonomie.bib_listes (
--   nom_liste,
--   desc_liste,
--   regne,
--   code_liste
-- ) VALUES (
--   'Priority Flora',
--   'Liste de taxons pour le module Priority Flora.',
--   'Plantae',
--   'PRIORITY_FLORA'
-- )
-- ON CONFLICT (nom_liste) DO NOTHING ;


-- \echo '----------------------------------------------------------------------------'
-- \echo 'TAXONOMIE => Insert taxon names into "bib_noms"'
-- INSERT INTO taxonomie.bib_noms (
--   cd_nom,
--   cd_ref,
--   nom_francais,
--   "comments"
-- )
-- 	SELECT
--     t.cd_nom,
--     t.cd_ref,
--     btf.francais,
--     'Imported by Priority Flora.'
--   FROM taxonomie.taxref  AS t
--     JOIN v1_florepatri.bib_taxons_fp AS btf
--         ON btf.cd_nom = t.cd_nom
--   WHERE NOT EXISTS (
--     SELECT 'X'
--     FROM taxonomie.bib_noms AS bn
--     WHERE bn.cd_nom = btf.cd_nom
--   ) ;


\echo '----------------------------------------------------------------------------'
\echo 'TAXONOMIE => Insert data into "cor_nom_liste"'
WITH code_liste AS (
  SELECT id_liste
  FROM taxonomie.bib_listes
  WHERE code_liste = 'PRIORITY_FLORA'
)
INSERT INTO taxonomie.cor_nom_liste (
  id_liste,
  id_nom
)
  SELECT
    cl.id_liste,
    b.id_nom
  FROM taxonomie.bib_noms AS b
    JOIN v1_florepatri.bib_taxons_fp AS t
      ON b.cd_nom = t.cd_nom,
    code_liste AS cl
  WHERE NOT EXISTS (
    SELECT 'X'
    FROM taxonomie.cor_nom_liste AS cnl, code_liste AS scl
    WHERE cnl.id_liste = scl.id_liste
      AND cnl.id_nom = b.id_nom
  ) ;


\echo '----------------------------------------------------------------------------'
\echo 'COMMIT if all goes well !'
COMMIT;
