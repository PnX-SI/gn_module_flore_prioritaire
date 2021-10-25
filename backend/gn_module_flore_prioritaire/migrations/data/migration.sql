INSERT INTO pr_priority_flora.t_zprospect (
    indexzp, date_min, date_max, topo_valid, initial_insert,
    cd_nom, id_dataset, unique_id_sinp_zp, geom_local,
    geom_4326, geom_point_4326
)
SELECT 
indexzp,  dateobs, dateobs, topo_valid, saisie_initiale,
cd_nom, id_lot, unique_id_sinp_grp, the_geom_local, st_transform(geom_mixte_3857, 4326),
st_transform(geom_point_3857, 4326)
FROM v1_florepatri.t_zprospection
WHERE supprime = 'false';
;

INSERT INTO pr_priority_flora.cor_zp_obs (indexzp, id_role)
SELECT obs.indexzp, codeobs
FROM v1_florepatri.cor_zp_obs obs
JOIN pr_priority_flora.t_zprospect z on z.indexzp = obs.indexzp -- join to remove supprime=false
;

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
    unique_id_sinp_ap, 
    geom_local, 
    geom_4326, 
    geom_point_4326
)
SELECT
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
st_centroid(
    st_transform(the_geom_3857, 4326)
)
FROM v1_florepatri.t_apresence a
JOIN pr_priority_flora.t_zprospect z ON z.indexzp = a.indexzp
;

INSERT INTO pr_priority_flora.cor_ap_perturb 
SELECT indexzp, id_nomenclature, NULL as pres_effective
FROM v1_florepatri.cor_ap_perturb cor 
JOIN v1_florepatri.t_zprospection z on z.indexzp = cor.indexzp
JOIN v1_florepatri.bib_perturbations b ON b.code_per = cor.code_per
JOIN ref_nomenclatures.t_nomenclatures t ON t.label_default = b.description
JOIN ref_nomenclatures.bib_nomenclatures_types bib ON bib.id_type = t.id_type AND bib.mnemonique = 'TYPE_PERTURBATION';
WHERE z.supprime = 'false';



-- TODO physinomie 
insert into taxonomie.bib_attributs (nom_attribut, label_attribut, obligatoire, desc_attribut, type_attribut,type_widget, id_theme, liste_valeur_attribut)
select 'physionomie','Physionomie','false','Physionomie principale du taxon','text','textarea',1,'{"values":[' || string_agg ('"' || ph.nom_physionomie || '"',',') || ']}' 
from v1_florepatri.bib_physionomies ph; 

insert into taxonomie.cor_taxon_attribut (cd_ref, valeur_attribut, id_attribut)
select 
    distinct tx.cd_ref, 
    string_agg(bp.nom_physionomie, '&') as valeur_atrribut, 
    (SELECT id_attribut FROM taxonomie.bib_attributs WHERE nom_attribut = 'physionomie')
from v1_florepatri.cor_ap_physionomie cap
join v1_florepatri.t_apresence ta on ta.indexap = cap.indexap
join v1_florepatri.t_zprospection tz on tz.indexzp = ta.indexzp
join taxonomie.taxref tx on tx.cd_nom = tz.cd_nom
join v1_florepatri.bib_physionomies bp on bp.id_physionomie = cap.id_physionomie
group by tx.cd_ref;
