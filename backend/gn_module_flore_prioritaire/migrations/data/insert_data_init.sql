--insérer les zones de prospection

INSERT INTO priority_flora.t_zprospect(indexzp, date_min, date_max, topo_valid, initial_insert, srid_design, cd_nom, geom_local, geom_4326, geom_point_4326)
SELECT indexzp,dateobs,dateobs,topo_valid,saisie_initiale,srid_dessin,cd_nom, the_geom_2154, ST_Transform(geom_point_3857,3857,4326), ST_Transform(geom_mixte_3857,3857,4326)
FROM OLD_DATABASE_SCHEMA.OLD_DATABASE_TABLE;

--insérer correspondance entre zp et observateurs

INSERT INTO priority_flora.cor_zp_obs(indexzp,codeobs)
SELECT indexzp,codeobs FROM appli_flore.cor_zp_obs;

--MAJ du champ observateurs dans la table cor_zp_obs (A VOIR SI NECESSAIRE!!!)

UPDATE cor_zp_obs SET codeobs=SELECT id_role FROM t_roles WHERE t_roles.anc_id_role=cor_zp_obs.codeobs;

--insérer les aires de présence

INSERT INTO priority_flora.t_apresence(indexap, area, frequency, topo_valid, altitude_min, altitude_max, nb_transects_frequency, nb_points_frequency, nb_contacts_frequency, nb_plots_count, area_plots_count, comment, step_length, indexzp, 
            id_nomenclatures_pente, id_nomenclatures_count_method, id_nomenclatures_freq_method, id_nomenclatures_phenology, id_history_action, nb_sterile_plots, nb_fertile_plots, total_sterile, total_fertile, unique_id_sinp_zp, geom_local, geom_4326)
SELECT indexap, surfaceap, frequenceap, topo_valid, altitude_retenue, altitude_retenue, nb_transects_frequence, nb_points_frequence, nb_contacts_frequence, nb_placettes_comptage, surface_placette_comptage, remarques, longueur_pas, indexzp,
,,,,,effectif_placettes_steriles,effectif_placettes_fertiles,total_steriles,total_fertiles,,the_geom_2154,ST_Transform(geom_3857,3857,4326) 
FROM OLD_DATABASE_SCHEMA.OLD_DATABASE_TABLE;
