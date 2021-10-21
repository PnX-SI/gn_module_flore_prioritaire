INSERT INTO pr_priority_flora.t_zprospect (
    indexzp, date_min, date_max, topo_valid, initial_insert,
    cd_nom, id_dataset, unique_id_sinp_zp, geom_local,
    geom_4326, geom_point_4326
)
SELECT 
indexzp,  dateobs, dateobs, topo_valid, saisie_initiale,
cd_nom, id_lot, unique_id_sinp_grp, the_geom_local, st_transform(the_geom_mixte_3857, 4326),
st_transform(the_geom_point_3857, 4326)
FROM v1_florepatri.t_zprospection;

INSERT INTO pr_priority_flora.cor_zp_obs (indexzp, id_role)
SELECT indexzp, codeobs
FROM v1_florepatri.indexzp;

INSERT INTO pr_priority_flora.t_apresence
(area, topo_valid, altitude_min, altitude_max, frequency, "comment", indexzp, id_nomenclatures_pente, id_nomenclatures_counting, id_nomenclatures_habitat, id_nomenclatures_phenology, id_history_action, total_min, total_max, unique_id_sinp_ap, geom_local, geom_4326, geom_point_4326)
SELECT
 surfaceap::FLOAT, topo_valid, altitude_retenue, altitude_saisie, frequenceap,
 indexzp,
 NULL, -- Pas de notion de pente  
 (SELECT id_nomenclature 
    FROM ref_nomenclatures.t_nomenclatures t
    JOIN v1_florepatri.bib_comptages_methodo m ON t.label_default = m.nom_comptage_methodo 
), -- counting
 NULL, 
  (SELECT id_nomenclature 
    FROM ref_nomenclatures.t_nomenclatures t
    JOIN v1_florepatri.bib_phenologies m ON t.label_default = m.pheno 
), -- pheno
NULL, -- id_history_action
NULL , --total_min
NULL, -- total max
unique_id_sinp_fp,
the_geom_local,
st_transform(the_geom_3857, 4326),
st_centroid(
    st_transform(the_geom_3857, 4326)
);

INSERT INTO pr_priority_flora.cor_zp_area
SELECT id_area, indexzp
FROM pr_priority_flora.t_zprospect t
JOIN ref_geo.l_areas l ON st_intersect(t.geom_local, l.geom)
WHERE t.enabled IS TRUE; 

INSERT INTO pr_priority_flora.cor_zp_area
SELECT id_area, indexzp
FROM pr_priority_flora.t_apresence t
JOIN ref_geo.l_areas l ON st_intersect(t.geom_local, l.geom)
WHERE t.enabled IS TRUE; 

INSERT INTO pr_priority_flora.cor_ap_perturb 
SELECT indexzp, id_nomenclature, NULL as pres_effective
FROM v1_florepatri.cor_ap_perturb cor 
JOIN v1_florepatri.bib_perturbations b ON b.code_per = cor.code_per
JOIN ref_nomenclatures.t_nomenclatures t ON t.label_default = b.description
JOIN ref_nomenclatures.bib_nomenclatures_types bib ON bib.id_type = t.id_type AND bib.mnemonique = 'TYPE_PERTURBATION';
