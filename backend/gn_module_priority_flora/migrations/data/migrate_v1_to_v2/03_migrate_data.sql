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

-- TODO :
-- 1. vérifier les noms des champs. !!L.87 + L.159 "cor_ap_perturb"!!
-- 2. ajouter des not exists pour éviter les erreurs d'insertion.
-- 3. analyser le contenu migré pour voir si on ne peut pas l'améliorer.
-- 4. lancer le script #2 02_migrate.sql et le corriger
-- 5. vérifier le bon fonctionne du module (front et back) avec les données => le corriger si erreurs...
-- 6. migrer dans branche refactor les modules SFT, SHT et enfin SHS.

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
    additional_data,
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
        json_build_object(
            'migrateOriginalInfos',
            json_build_object(
                'indexzp', mtz.indexzp
            )
        ),
        the_geom_2154,
        st_transform(geom_mixte_3857, 4326),
        st_transform(geom_point_3857, 4326)
    FROM migrate_v1_florepatri.t_zprospection AS mtz
    WHERE supprime = 'false'
        AND NOT EXISTS (
            SELECT 'X'
            FROM pr_priority_flora.t_zprospect AS tz
            WHERE tz.indexzp = mtz.indexzp
        )
    ;



\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Update sequence for "t_zprospect"'
SELECT setval(
    'pr_priority_flora.t_zprospect_indexzp_seq',
    (SELECT max(indexzp) FROM pr_priority_flora.t_zprospect),
    true
) ;


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "cor_zp_obs"'
WITH coresp AS (
	SELECT
        tr.id_role,
        CAST(tr.champs_addi-> 'migrateOriginalInfos' ->> 'roleId' AS INT) AS roleId
    from utilisateurs.t_roles AS tr
)

INSERT INTO pr_priority_flora.cor_zp_obs (
    indexzp,
    id_role
)
    SELECT
        mcor.indexzp,
		coresp.id_role
    FROM migrate_v1_florepatri.cor_zp_obs AS mcor
        JOIN migrate_v1_florepatri.t_zprospection AS tzp
            ON tzp.indexzp = mcor.indexzp
        JOIN coresp
        	ON coresp.roleId = mcor.codeobs
    WHERE tzp.supprime = 'false'
        AND NOT EXISTS (
            SELECT 'X'
            FROM pr_priority_flora.cor_zp_obs AS pf
            WHERE pf.indexzp = mcor.indexzp
                AND pf.id_role = mcor.codeobs
        )
    ;

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
    additional_data,
    geom_local,
    geom_4326,
    geom_point_4326
)
    SELECT
        mta.indexap,
        mta.surfaceap::FLOAT,
        mta.topo_valid,
        mta.altitude_retenue,
        mta.altitude_retenue,
        mta.frequenceap,
        mta.remarques,
        mta.indexzp,
        NULL, -- Pas de notion de pente
        ref_nomenclatures.get_id_nomenclature('FLORE_PATRI_METHODO_DENOM',mta.id_comptage_methodo::text), -- counting
        NULL,
        ref_nomenclatures.get_id_nomenclature('TYPE_PHENOLOGIE',mta.codepheno::text), -- counting
        NULL, -- id_history_action
        total_steriles+total_fertiles , --total_min
        total_steriles+total_fertiles, -- total max
        json_build_object(
            'migrateOriginalInfos',
            json_build_object(
                'indexap', mta.indexap,
                'nb_transects_ap', mta.nb_transects_frequence,
    	        'nb_points_ap', mta.nb_points_frequence,
    	        'nom_frequence_methodo', bfmn.nom_frequence_methodo_new,
                'frequence_ap', mta.frequenceap,
                'methode_comptage', bcm.nom_comptage_methodo,
                'nb_placettes_comptage', mta.nb_placettes_comptage,
                'surface_placette_comptage', mta.surface_placette_comptage,
    	        'nb_contacts_ap', mta.nb_contacts_frequence,
    	        'total_fertiles', mta.total_fertiles,
                'total_steriles', mta.total_steriles,
                'effectif_placettes_fertiles', mta.effectif_placettes_fertiles,
                'effectif_placettes_steriles', mta.effectif_placettes_steriles,
                'ap_topo_valid', mta.topo_valid,
                'zp_topo_valid', tz.topo_valid,
                'etat_conservation', bec.libelle,
                'conservation_commentaire', mta.conservation_commentaire,
                'pourcentage_ap_conservation_favorable', mta.pourcentage_ap_conservation_favorable, 
                'conservation_commentaire', mta.conservation_commentaire,
                'menace', bm.libelle,
                'pourcentage_ap_non_menacee', mta.pourcentage_ap_non_menacee,
                'pourcentage_ap_espace_protege_F', mta.pourcentage_ap_espace_protege_f, 
                'surface_ap_maitrisee_foncierement', mta.surface_ap_maitrisee_foncierement,
                'pourcentage_ap_maitrisee_foncierement', mta.pourcentage_ap_maitrisee_foncierement
            )
        ),
        mta.the_geom_2154,
        st_transform(mta.the_geom_3857, 4326),
        st_centroid(st_transform(mta.the_geom_3857, 4326))
    FROM migrate_v1_florepatri.t_apresence AS mta
    JOIN migrate_v1_florepatri.bib_comptages_methodo AS bcm
        ON bcm.id_comptage_methodo = mta.id_comptage_methodo
    JOIN migrate_v1_florepatri.t_zprospection AS tz
        ON tz.indexzp = mta.indexzp
    JOIN migrate_v1_florepatri.bib_etats_conservation AS bec 
        ON bec.idetatconservation = mta.idetatconservation
    JOIN migrate_v1_florepatri.bib_menaces AS bm
        ON bm.idmenace = mta.idmenace 
    JOIN migrate_v1_florepatri.bib_frequences_methodo_new AS bfmn
        ON bfmn.id_frequence_methodo_new = mta.id_frequence_methodo_new 
    WHERE mta.supprime = 'false'
        AND NOT EXISTS (
            SELECT 'X'
            FROM pr_priority_flora.t_apresence AS ta
            WHERE ta.indexap = mta.indexap
                AND ta.indexzp = mta.indexzp
        )
    ;

\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Update sequence for "t_apresence"'
SELECT setval(
    'pr_priority_flora.t_apresence_indexap_seq',
    (SELECT max(indexap) FROM pr_priority_flora.t_apresence),
    true
) ;


\echo '----------------------------------------------------------------------------'
\echo 'PRIORITY_FLORA => Insert data into "cor_ap_perturb"'
WITH nomenclature AS (
	select 
		id_nomenclature,
		b.codeper
	from ref_nomenclatures.t_nomenclatures AS tn
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
        NULL AS pres_effective

    FROM migrate_v1_florepatri.cor_ap_perturb AS mcor
        JOIN pr_priority_flora.t_apresence AS a
            ON a.indexap = mcor.indexap
        JOIN nomenclature AS n
        	ON n.codeper = mcor.codeper
	WHERE NOT EXISTS (
        SELECT 'X'
        FROM pr_priority_flora.cor_ap_perturb AS pf
        WHERE pf.indexap = mcor.indexap
            AND pf.id_nomenclature = n.id_nomenclature
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