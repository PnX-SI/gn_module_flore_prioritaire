-----------------------------------------------------------------------
--Migration des données v1 vers v2 de la table des zones de prospection
-----------------------------------------------------------------------

INSERT INTO pr_priority_flora.t_zprospect(indexzp, date_min, date_max, topo_valid, initial_insert, cd_nom, geom_local, geom_4326, geom_point_4326)
SELECT indexzp, date_insert, date_insert, topo_valid, saisie_initiale, cd_nom, the_geom_2154, st_transform(the_geom_2154,4326), st_transform(geom_point_3857,4326)
FROM florepatri.t_zprospection
WHERE supprime='false';

---------------------------------------------------------------------
--Migration des données v1 vers v2 de la table des aires de présence
---------------------------------------------------------------------

INSERT INTO pr_priority_flora.t_apresence (indexap, area, topo_valid, altitude_min, altitude_max, frequency, comment, indexzp, id_nomenclatures_phenology, total_min, total_max, geom_local, geom_4326, geom_point_4326)
SELECT indexap, surfaceap, topo_valid, altitude_sig, altitude_sig, frequenceap, 'Remarques : ' || COALESCE(remarques,'none'), indexzp, ref_nomenclatures.get_id_nomenclature('TYPE_PHENOLOGIE'::text,t_apresence.codepheno::text),(total_steriles+total_fertiles) as total_min,(total_steriles+total_fertiles) as total_max,the_geom_2154, st_transform(the_geom_2154,4326), st_transform(the_geom_3857,4326)
FROM florepatri.t_apresence
WHERE supprime='false';

------------------------------------------------------------------------------------------------------------
--Migration des données v1 vers v2 de la table de correspondance des zp avec les observateurs correspondants
------------------------------------------------------------------------------------------------------------ 

INSERT INTO pr_priority_flora.cor_zp_obs(indexzp,id_role)
SELECT cor_zp_obs.indexzp,cor_zp_obs.codeobs
FROM florepatri.cor_zp_obs cob JOIN florepatri.t_zprospection tzp ON tzp.indexzp=cob.indexzp
WHERE tzp.supprime='false';

--------------------------------------------------------------------------------------------------------------
--Migration des données v1 vers v2 de la table de correspondance des ap avec les perturbations correspondantes
--------------------------------------------------------------------------------------------------------------

INSERT INTO pr_priority_flora.cor_ap_perturb(indexap,effective,id_nomenclature)
SELECT indexap,'true',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION'::text,cor_ap_perturb.codeper::text)
FROM florepatri.cor_ap_perturb cap JOIN florepatri.t_apresence tap ON tap.indexap=cap.indexap
WHERE tap.supprime='false';

---------------------------------------------------------------------------
--Insertion de l'attribut physionomie dans la table taxonomie.bib_attributs
---------------------------------------------------------------------------

insert into taxonomie.bib_attributs (nom_attribut, label_attribut, obligatoire, desc_attribut, type_attribut,type_widget, id_theme, liste_valeur_attribut)
select 'physionomie','Physionomie','false','Physionomie principale du taxon','text','textarea',1,'{"values":[' || string_agg ('"' || ph.nom_physionomie || '"',',') || ']}' from florepatri.bib_physionomies ph; 

----------------------------------------------------------------------------------------
--Fonction pour récupérer l'ID de l'attribut à partir du nom dans la table bib_attributs
----------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION taxonomie.get_id_attribut(myname character varying)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
--Function which return the id_attribut from the attribute name of bib_attributs
DECLARE theidattribute character varying;
  BEGIN
SELECT INTO theidattribute id_attribut FROM taxonomie.bib_attributs WHERE nom_attribut = myname;
return theidattribute;
  END;
$function$
;

-----------------------------------------------------------------------
--Insertion des physionomies par taxon dans la table cor_taxon_attribut
-----------------------------------------------------------------------

insert into taxonomie.cor_taxon_attribut (cd_ref, valeur_attribut, id_attribut)
select distinct tx.cd_ref, string_agg(bp.nom_physionomie, '&') as valeur_atrribut, taxonomie.get_id_attribut('physionomie') 
from florepatri.cor_ap_physionomie cap
join florepatri.t_apresence ta on ta.indexap = cap.indexap
join florepatri.t_zprospection tz on tz.indexzp = ta.indexzp
join taxonomie.taxref tx on tx.cd_nom = tz.cd_nom
join florepatri.bib_physionomies bp on bp.id_physionomie = cap.id_physionomie
group by tx.cd_ref;


