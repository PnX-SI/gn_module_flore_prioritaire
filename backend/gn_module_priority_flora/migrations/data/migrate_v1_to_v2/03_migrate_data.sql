-- Migrate data from migrate_v1_florepatri and migrate_v1_utilisateurs
-- into GeoNature v2 Priority Flora module schema.
-- Usage:
--  1. go to sql directory: cd backend/gn_module_priority_flora/migrations/data/migrate_v1_to_v2
--  2. create foreign data table with script #1 :
--    export PGPASSWORD="<db_pass>"; psql -h "<db_host>" -U "<db_user>" -d "<db_name>" -f "01_create_fdw.sql"
--  3. migrate users with scripts #2 :
--    export PGPASSWORD="<db_pass>"; psql -h "<db_host>" -U "<db_user>" -d "<db_name>" -f "02_migrate_users.sql"
--  4. migrate data with scripts #3 :
--    export PGPASSWORD="<db_pass>"; psql -h "<db_host>" -U "<db_user>" -d "<db_name>" -f "03_migrate_data.sql"
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
    date_min,
    date_max,
    topo_valid,
    initial_insert,
    cd_nom,
    additional_data,
    geom_local,
    geom_4326,
    geom_point_4326,
    meta_create_date,
    meta_update_date
)
    SELECT
        dateobs,
        dateobs,
        topo_valid,
        saisie_initiale,
        cd_nom,
        json_build_object(
            'migrateOriginalInfos',
            json_build_object(
                'indexZp', mtz.indexzp,
                'topoValid', mtz.topo_valid,
                'validation', mtz.validation,
                'erreurSignalee', mtz.erreur_signalee,
                'taxonSaisie', mtz.taxon_saisi,
                'idOrganisme', mtz.id_organisme,
                'nomOrganisme', bo.nom_organisme
            )
        ),
        the_geom_2154,
        st_transform(geom_mixte_3857, 4326),
        st_transform(geom_point_3857, 4326),
        date_insert,
        date_update
    FROM migrate_v1_florepatri.t_zprospection AS mtz
        LEFT JOIN migrate_v1_utilisateurs.bib_organismes AS bo
            ON mtz.id_organisme = bo.id_organisme
    WHERE supprime = 'false'
        AND NOT EXISTS (
            SELECT 'X'
            FROM pr_priority_flora.t_zprospect AS tz
            WHERE CAST(tz.additional_data-> 'migrateOriginalInfos' ->> 'indexZp' AS BIGINT) = mtz.indexzp
        )
    ;


CREATE TRIGGER tri_meta_dates_change_zprospect BEFORE
INSERT OR UPDATE ON pr_priority_flora.t_zprospect
FOR EACH ROW EXECUTE FUNCTION fct_trg_meta_dates_change() ;


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "cor_zp_obs"'
WITH coresp AS (
	SELECT
        tr.id_role,
        CAST(tr.champs_addi-> 'migrateOriginalInfos' ->> 'roleId' AS BIGINT) AS roleId
    from utilisateurs.t_roles AS tr
)

INSERT INTO pr_priority_flora.cor_zp_obs (
    indexzp,
    id_role
)
    SELECT
        tz.indexzp,
		coresp.id_role
    FROM migrate_v1_florepatri.cor_zp_obs AS mcor
        JOIN migrate_v1_florepatri.t_zprospection AS tzp
            ON tzp.indexzp = mcor.indexzp
        JOIN coresp
        	ON coresp.roleId = mcor.codeobs
        JOIN pr_priority_flora.t_zprospect AS tz
            ON CAST(tz.additional_data-> 'migrateOriginalInfos' ->> 'indexZp' AS BIGINT) = mcor.indexzp
    WHERE tzp.supprime = 'false'
        AND NOT EXISTS (
            SELECT 'X'
            FROM pr_priority_flora.cor_zp_obs AS pf
            WHERE pf.indexzp = tz.indexzp
                AND pf.id_role = coresp.id_role
        )
    ;

\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "t_apresence"'
INSERT INTO pr_priority_flora.t_apresence(
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
    additional_data,
    geom_local,
    geom_4326,
    geom_point_4326,
    meta_create_date,
    meta_update_date
)
    SELECT
        mta.surfaceap::FLOAT,
        mta.topo_valid,
        mta.altitude_retenue,
        mta.altitude_retenue,
        mta.frequenceap,
        mta.remarques,
        tz.indexzp,
        NULL, -- Pas de notion de pente.
        ref_nomenclatures.get_id_nomenclature('TYPE_COMPTAGE', mta.id_comptage_methodo::text),
        NULL, -- Pas de notion d'habitat.
        ref_nomenclatures.get_id_nomenclature('TYPE_PHENOLOGIE', mta.codepheno::text),
        NULL, -- Pas de notion d'historique des actions.
        total_steriles + total_fertiles , --total_min
        total_steriles + total_fertiles, -- total max
        json_build_object(
            'migrateOriginalInfos',
            json_build_object(
                'indexAp', mta.indexap,
                'insee', mta.insee,
                'methodeFrequence', bfmn.nom_frequence_methodo_new,
                'nbTransectsAp', mta.nb_transects_frequence,
    	        'nbPointsAp', mta.nb_points_frequence,
    	        'nbContactsAp', mta.nb_contacts_frequence,
                'methodeComptage', bcm.nom_comptage_methodo,
                'nbPlacettesComptage', mta.nb_placettes_comptage,
                'surfacePlacetteComptage', mta.surface_placette_comptage,
                'longueurPas', mta.longueur_pas,
    	        'effectifPlacettesSteriles', mta.effectif_placettes_steriles,
                'effectifPlacettesFertiles', mta.effectif_placettes_fertiles,
                'totalSteriles', mta.total_steriles,
                'totalFertiles', mta.total_fertiles,
                'etatConservation', bec.libelle,
                'pourcentageApConservationFavorable', mta.pourcentage_ap_conservation_favorable,
                'conservationCommentaire', mta.conservation_commentaire,
                'menace', bm.libelle,
                'pourcentageApNonMenacee', mta.pourcentage_ap_non_menacee,
                'pourcentageApEspaceProtegeF', mta.pourcentage_ap_espace_protege_f,
                'surfaceApMaitriseeFoncierement', mta.surface_ap_maitrisee_foncierement,
                'pourcentageApMaitriseeFoncierement', mta.pourcentage_ap_maitrisee_foncierement,
                'dateSuivi', mta.date_suivi
            )
        ) AS additional_data,
        mta.the_geom_2154,
        st_transform(mta.the_geom_3857, 4326),
        st_centroid(st_transform(mta.the_geom_3857, 4326)),
        mta.date_insert,
        mta.date_update
    FROM migrate_v1_florepatri.t_apresence AS mta
        LEFT JOIN migrate_v1_florepatri.bib_comptages_methodo AS bcm
            ON bcm.id_comptage_methodo = mta.id_comptage_methodo
        LEFT JOIN migrate_v1_florepatri.bib_etats_conservation AS bec
            ON bec.idetatconservation = mta.idetatconservation
        LEFT JOIN migrate_v1_florepatri.bib_menaces AS bm
            ON bm.idmenace = mta.idmenace
        LEFT JOIN migrate_v1_florepatri.bib_frequences_methodo_new AS bfmn
            ON bfmn.id_frequence_methodo_new = mta.id_frequence_methodo_new
        JOIN pr_priority_flora.t_zprospect AS tz
            ON CAST(tz.additional_data-> 'migrateOriginalInfos' ->> 'indexZp' AS BIGINT) = mta.indexzp
    WHERE mta.supprime = 'false'
        AND NOT EXISTS (
            SELECT 'X'
            FROM pr_priority_flora.t_apresence AS ta
            WHERE CAST(ta.additional_data-> 'migrateOriginalInfos' ->> 'indexAp' AS BIGINT) = mta.indexap
        )
    ;

CREATE TRIGGER tri_meta_dates_change_apresence BEFORE
INSERT OR UPDATE ON pr_priority_flora.t_apresence
FOR EACH ROW EXECUTE FUNCTION fct_trg_meta_dates_change() ;


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "cor_ap_perturb"'
WITH nomenclature AS (
	SELECT
		id_nomenclature,
		b.codeper
	FROM ref_nomenclatures.t_nomenclatures AS tn
	    JOIN migrate_v1_florepatri.bib_perturbations AS b
	        ON tn.label_default = b.description
	    JOIN ref_nomenclatures.bib_nomenclatures_types AS bib
	    	ON (bib.id_type = tn.id_type AND bib.mnemonique = 'TYPE_PERTURBATION')
)
INSERT INTO pr_priority_flora.cor_ap_perturb (
    indexap,
    id_nomenclature,
    pres_effective
)
    SELECT
        a.indexap,
        n.id_nomenclature,
        NULL
    FROM migrate_v1_florepatri.cor_ap_perturb AS mcor
        JOIN pr_priority_flora.t_apresence AS a
            ON CAST(a.additional_data-> 'migrateOriginalInfos' ->> 'indexAp' AS BIGINT) = mcor.indexap
        JOIN nomenclature AS n
        	ON n.codeper = mcor.codeper
	WHERE NOT EXISTS (
        SELECT 'X'
        FROM pr_priority_flora.cor_ap_perturb AS cap
        WHERE cap.indexap = a.indexap
            AND cap.id_nomenclature = n.id_nomenclature
    ) ;

\echo '----------------------------------------------------------------------------'
\echo 'TAXONOMIE => Update sequence for "bib_attributs"'
SELECT setval(
    'taxonomie.bib_attributs_id_attribut_seq',
    (SELECT max(id_attribut) FROM taxonomie.bib_attributs),
    true
) ;

\echo '----------------------------------------------------------------------------'
\echo 'TAXONOMIE => Insert data into "bib_attributs"'
WITH attr_values AS (
	SELECT '{"values":[' || string_agg ('"' || ph.nom_physionomie || '"',',') || ']}' AS attr_value
    FROM migrate_v1_florepatri.bib_physionomies AS ph
)
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
        'Physionomie principale du taxon.',
        'text',
        'multiselect',
        1,
        av.attr_value
    FROM attr_values AS av
    WHERE NOT EXISTS (
            SELECT 'X'
            FROM taxonomie.bib_attributs AS ba
            WHERE ba.nom_attribut = 'physionomie'
        )
    ;


\echo '----------------------------------------------------------------------------'
\echo 'TAXONOMIE => Insert data into "cor_taxon_attribut"'
INSERT INTO taxonomie.cor_taxon_attribut (
    cd_ref,
    valeur_attribut,
    id_attribut
)
    SELECT DISTINCT
        tx.cd_ref,
        string_agg(bp.nom_physionomie, ' & ') AS valeur_attribut,
        (SELECT id_attribut FROM taxonomie.bib_attributs WHERE nom_attribut = 'physionomie')
    FROM migrate_v1_florepatri.cor_ap_physionomie AS cap
        JOIN migrate_v1_florepatri.t_apresence AS ta
            ON ta.indexap = cap.indexap
        JOIN migrate_v1_florepatri.t_zprospection AS tz
            ON tz.indexzp = ta.indexzp
        JOIN taxonomie.taxref AS tx
            ON tx.cd_nom = tz.cd_nom
        JOIN migrate_v1_florepatri.bib_physionomies AS bp
            ON bp.id_physionomie = cap.id_physionomie
    WHERE NOT EXISTS (
            SELECT 'X'
            FROM taxonomie.cor_taxon_attribut AS cor
            WHERE cor.cd_ref = tx.cd_ref
        )
    GROUP BY tx.cd_ref ;

\echo '----------------------------------------------------------------------------'
\echo 'TAXONOMIE => Update sequence for "bib_listes"'
SELECT setval(
    'taxonomie.bib_listes_id_liste_seq',
    (SELECT max(id_liste) FROM taxonomie.bib_listes),
    true
) ;

\echo '----------------------------------------------------------------------------'
\echo 'TAXONOMIE => Insert data into "bib_listes"'
INSERT INTO taxonomie.bib_listes (
    nom_liste,
    desc_liste,
    regne,
    code_liste
) VALUES (
    'Priority Flora',
    'Liste de taxons pour le module Priority Flora.',
    'Plantae',
    'PRIORITY_FLORA'
)
ON CONFLICT (nom_liste) DO NOTHING ;


\echo '----------------------------------------------------------------------------'
\echo 'TAXONOMIE => Insert taxon names into "bib_noms"'
    INSERT INTO taxonomie.bib_noms (
    cd_nom,
    cd_ref,
    nom_francais,
    "comments"
)

	SELECT
        t.cd_nom,
        t.cd_ref,
        btf.francais,
        'Imported by Priority Flora.'
    FROM taxonomie.taxref  AS t
        JOIN migrate_v1_florepatri.bib_taxons_fp AS btf
            ON btf.cd_nom = t.cd_nom
    WHERE NOT EXISTS (
            SELECT 'X'
            FROM taxonomie.bib_noms AS bn
            WHERE bn.cd_nom = btf.cd_nom
        )
    ;


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
        JOIN migrate_v1_florepatri.bib_taxons_fp AS t
            ON b.cd_nom = t.cd_nom,
        code_liste AS cl
    WHERE NOT EXISTS (
            SELECT 'X'
            FROM taxonomie.cor_nom_liste AS cnl, code_liste AS scl
            WHERE cnl.id_liste = scl.id_liste
                AND cnl.id_nom = b.id_nom
        )
    ;


\echo '----------------------------------------------------------------------------'
\echo 'COMMIT if all goes well !'
COMMIT;