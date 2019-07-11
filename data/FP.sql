SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE SCHEMA pr_priority_flora;

SET search_path = pr_priority_flora, pg_catalog, public;

SET default_with_oids = false;

----------------------------------------------------------------------------------------------------
-- Insertion du cadre d'acquisition dans t_acquisition_frameworks
----------------------------------------------------------------------------------------------------

INSERT INTO gn_meta.t_acquisition_frameworks
(acquisition_framework_name, acquisition_framework_desc, id_nomenclature_territorial_level, territory_desc, keywords, id_nomenclature_financing_type, target_description, ecologic_or_geologic_target, acquisition_framework_parent_id, is_parent, acquisition_framework_start_date, acquisition_framework_end_date, meta_create_date, meta_update_date)
VALUES('', '', ref_nomenclatures.get_default_nomenclature_value('NIVEAU_TERRITORIAL'::character varying), '', '', ref_nomenclatures.get_default_nomenclature_value('TYPE_FINANCEMENT'::character varying), '', '', 0, false, '', '', '', '');

----------------------------------------------------------------------------------------------------
-- Insertion du jeu de données BCF dans t_datasets
----------------------------------------------------------------------------------------------------
WITH max_acquisition_framework AS (
    SELECT MAX(t_acquisition_frameworks.id_acquisition_framework) as id_acquisition_framework FROM gn_meta.t_acquisition_frameworks 
) 

INSERT INTO gn_meta.t_datasets
( id_acquisition_framework, dataset_name, dataset_shortname, dataset_desc, id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, id_nomenclature_dataset_objectif, bbox_west, bbox_east, bbox_south, bbox_north, id_nomenclature_collecting_method, id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, default_validity, active, meta_create_date, meta_update_date)
VALUES(max_acquisition_framework.id_acquisition_framework, 'Bilan Conservatoire Flore', 'BCF', 'Bilan Conservatoire Flore', ref_nomenclatures.get_default_nomenclature_value('DATA_TYP'::character varying), '', false, false, ref_nomenclatures.get_default_nomenclature_value('JDD_OBJECTIFS'::character varying), 0, 0, 0, 0, ref_nomenclatures.get_default_nomenclature_value('METHO_RECUEIL'::character varying), ref_nomenclatures.get_default_nomenclature_value('DS_PUBLIQUE'::character varying), ref_nomenclatures.get_default_nomenclature_value('STATUT_SOURCE'::character varying), ref_nomenclatures.get_default_nomenclature_value('RESOURCE_TYP'::character varying), false, true, '', '');

----------------------------------------------------------------------------------------------------
-- Insertion de la source dans t_sources
----------------------------------------------------------------------------------------------------

INSERT INTO gn_synthese.t_sources
(name_source, desc_source, entity_source_pk_field, url_source, validable, meta_create_date, meta_update_date)
VALUES('', '', '', '', true, now(), now());

------------------------------------------------------------
-- Table: t_zprospect
------------------------------------------------------------

CREATE TABLE pr_priority_flora.t_zprospect(
	indexzp             bigserial NOT NULL,
	date_min            DATE,
	date_max            DATE,
	topo_valid          BOOLEAN,
	initial_insert      VARCHAR (20),
	cd_nom		          INT,
	id_dataset          INT,
	unique_id_sinp_zp   UUID DEFAULT public.uuid_generate_v4(),
	geom_local          geometry(Geometry,2154),
	geom_4326           geometry(Geometry,4326),
	geom_point_4326     geometry(Point,4326),
	
  CONSTRAINT pk_t_zprospect PRIMARY KEY (indexzp),
	CONSTRAINT fk_t_zprospect_taxref FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_t_apresence_t_datasets FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);

------------------------------------------------------------
-- Table: cor_zp_obs
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_zp_obs(
	indexzp   BIGINT  NOT NULL,
	id_role   INT  NOT NULL,
	
	CONSTRAINT pk_cor_zp_obs PRIMARY KEY (indexzp,id_role),
	CONSTRAINT fk_cor_zp_obs_t_zprospect FOREIGN KEY (indexzp) REFERENCES pr_priority_flora.t_zprospect(indexzp) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_cor_zp_obs_t_roles FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
------------------------------------------------------------
-- Table: t_apresence
------------------------------------------------------------

CREATE TABLE pr_priority_flora.t_apresence(
	indexap                                           bigserial NOT NULL,
	area                                              FLOAT,
	topo_valid                                        BOOLEAN,
	altitude_min                                      INT DEFAULT 0,
	altitude_max                                      INT DEFAULT 0,
  frequency                                         FLOAT,
	comment                                           VARCHAR (10000),
	indexzp						  					  BIGINT,
	id_nomenclatures_counting			  		      INT,
	id_nomenclatures_habitat			  		      INT,
	id_nomenclatures_phenology			  			  INT,
	total_min                                         INT,
	total_max                                         INT,
	unique_id_sinp_ap                                 UUID DEFAULT public.uuid_generate_v4(),
	geom_local                                        geometry(Geometry,2154),
	geom_4326                                         geometry(Geometry,4326),
	geom_point_4326                                   geometry(Point,4326),
	
  CONSTRAINT pk_t_apresence PRIMARY KEY (indexap),
	CONSTRAINT fk_t_apresence_t_zprospect FOREIGN KEY (indexzp) REFERENCES pr_priority_flora.t_zprospect(indexzp) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_counting FOREIGN KEY (id_nomenclatures_counting) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_habitat FOREIGN KEY (id_nomenclatures_habitat) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_phenology FOREIGN KEY (id_nomenclatures_phenology) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);

------------------------------------------------------------
-- Table: cor_zp_area
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_zp_area(
	id_area   INT  NOT NULL,
	indexzp   BIGINT  NOT NULL,
	
	CONSTRAINT pk_cor_zp_area PRIMARY KEY (id_area,indexzp),
	CONSTRAINT fk_cor_zp_area_l_areas FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_cor_zp_area_t_zprospect FOREIGN KEY (indexzp) REFERENCES pr_priority_flora.t_zprospect(indexzp) ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);

------------------------------------------------------------
-- Table: cor_ap_area
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_ap_area(
	id_area   INT  NOT NULL,
	indexap   BIGINT  NOT NULL,
	
	CONSTRAINT pk_cor_ap_area PRIMARY KEY (id_area,indexap),
	CONSTRAINT fk_cor_ap_area_l_areas FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_cor_ap_area_t_apresence FOREIGN KEY (indexap) REFERENCES pr_priority_flora.t_apresence(indexap) ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);

------------------------------------------------------------
-- Table: cor_ap_perturb
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_ap_perturb(
	indexap           BIGINT  NOT NULL,
	id_nomenclature   INT  NOT NULL,
	effective		BOOLEAN,	

	CONSTRAINT pk_cor_ap_perturb PRIMARY KEY (indexap,id_nomenclature),
	CONSTRAINT fk_cor_ap_perturb_t_apresence FOREIGN KEY (indexap) REFERENCES pr_priority_flora.t_apresence(indexap) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_cor_ap_perturb_t_nomenclatures FOREIGN KEY (id_nomenclature) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);

----------------------------------------------------------------------------------------------------
-- Insertion de la table t_zprospect dans bib_tables_location
----------------------------------------------------------------------------------------------------

INSERT INTO gn_commons.bib_tables_location
(table_desc, schema_name, table_name, pk_field, uuid_field_name)
VALUES('Table centralisant les zones de prospection', 'pr_priority_flora', 't_zprospect', 'indexzp', 'unique_id_sinp_zp');

------------------------------------------------------------------------------------
-- Trigger: Lancement actualisation de la table t_validations suite à l'ajout de ZP
------------------------------------------------------------------------------------

CREATE TRIGGER tri_insert_default_validation_status
  AFTER INSERT
  ON t_zprospect
  FOR EACH ROW
  EXECUTE PROCEDURE gn_commons.fct_trg_add_default_validation_status();

------------------------------------------------------------
-- Fonction Trigger: actualisation de cor_ap_area
------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.fct_trg_cor_ap_area()
  RETURNS trigger AS
$BODY$
BEGIN

	DELETE FROM pr_priority_flora.cor_ap_area WHERE indexap = NEW.indexap;
	INSERT INTO pr_priority_flora.cor_ap_area (indexap,id_area)
	SELECT NEW.indexap as indexap, (ref_geo.fct_get_area_intersection(NEW.geom_local)).id_area as id_area;

  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

------------------------------------------------------------
-- Fonction Trigger: actualisation de cor_zp_area
------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.fct_trg_cor_zp_area()
  RETURNS trigger AS
$BODY$
BEGIN

	DELETE FROM pr_priority_flora.cor_zp_area WHERE indexzp = NEW.indexzp;
	INSERT INTO pr_priority_flora.cor_zp_area (indexzp,id_area)
	SELECT NEW.indexzp as indexzp, (ref_geo.fct_get_area_intersection(NEW.geom_local)).id_area as id_area;

  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

------------------------------------------------------------------
-- Trigger: Lancement actualisation de cor_zp_area sut t_zprospect
------------------------------------------------------------------

CREATE TRIGGER trg_cor_zp_area
  AFTER INSERT OR UPDATE OF geom_4326
  ON pr_priority_flora.t_zprospect
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.fct_trg_cor_zp_area();

------------------------------------------------------------------
-- Trigger: Lancement actualisation de cor_ap_area sur t_apresence
------------------------------------------------------------------

CREATE TRIGGER trg_cor_ap_area
  AFTER INSERT OR UPDATE OF geom_4326
  ON pr_priority_flora.t_apresence
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.fct_trg_cor_ap_area();

-----------------------------------------------------------------------
-- Fonction Trigger: actualisation des champs geom_local
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.insert_zp()
  RETURNS trigger AS
$BODY$
DECLARE

BEGIN

IF new.indexzp in (SELECT indexzp FROM pr_priority_flora.t_zprospect) THEN
	RETURN NULL;
ELSE

    new.geom_local = public.st_transform(new.geom_4326,2154);
    new.geom_point_4326 = public.ST_pointonsurface(new.geom_4326);
		
	RETURN NEW;
END IF;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-----------------------------------------------------------------------
-- Fonction Trigger: actualisation du champ geom_local et de la surface 
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.insert_ap()
  RETURNS trigger AS
$BODY$

BEGIN

IF new.indexap in (SELECT indexap FROM pr_priority_flora.t_apresence) THEN
	RETURN NULL;
ELSE

		new.geom_local = public.st_transform(new.geom_4326,2154);
    new.geom_point_4326 = public.ST_pointonsurface(new.geom_4326);
		new.area = public.st_area(new.geom_local);
	RETURN NEW;
END IF;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-----------------------------------------------------------------------------------------
-- Trigger: Lancement actualisation des champs geom_local sur t_zprospect
-----------------------------------------------------------------------------------------

CREATE TRIGGER tri_insert_zp
  BEFORE INSERT
  ON pr_priority_flora.t_zprospect
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.insert_zp();

------------------------------------------------------------------------
-- Trigger: Lancement actualisation du champ geom_local sur t_apresence
------------------------------------------------------------------------

CREATE TRIGGER tri_insert_ap
  BEFORE INSERT
  ON pr_priority_flora.t_apresence
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.insert_ap();

------------------------------------------------------------------------
-- Trigger: Lancement de l'historisation de la table t_apresence
------------------------------------------------------------------------
CREATE TRIGGER tri_log_changes_t_apresence
  AFTER INSERT OR UPDATE OR DELETE
  ON t_apresence
  FOR EACH ROW
  EXECUTE PROCEDURE gn_commons.fct_trg_log_changes();

------------------------------------------------------------------------
-- Trigger: Lancement de l'historisation de la table t_zprospect
------------------------------------------------------------------------

CREATE TRIGGER tri_log_changes_t_zprospect
  AFTER INSERT OR UPDATE OR DELETE
  ON t_zprospect
  FOR EACH ROW
  EXECUTE PROCEDURE gn_commons.fct_trg_log_changes();

------------------------------------------------------------------------
-- Trigger: Lancement de l'historisation de la table cor_zp_obs
------------------------------------------------------------------------

CREATE TRIGGER tri_log_changes_cor_zp_obs
  AFTER INSERT OR UPDATE OR DELETE
  ON cor_zp_obs
  FOR EACH ROW
  EXECUTE PROCEDURE gn_commons.fct_trg_log_changes();

------------------------------------------------------------------------
-- Trigger: Lancement de l'historisation de la table cor_ap_perturb
------------------------------------------------------------------------

CREATE TRIGGER tri_log_changes_cor_ap_perturb
  AFTER INSERT OR UPDATE OR DELETE
  ON cor_ap_perturb
  FOR EACH ROW
  EXECUTE PROCEDURE gn_commons.fct_trg_log_changes();

------------------------------------
-- Vue: Création de la vue d'export
------------------------------------

DROP VIEW pr_priority_flora.export_ap;

CREATE OR REPLACE VIEW pr_priority_flora.export_ap AS 
WITH
    observers AS(
SELECT 
    tzp.indexzp,
    string_agg(roles.nom_role::text || ' ' ||  roles.prenom_role::text, ', ') AS observateurs,
    string_agg(orga.nom_organisme, ', ') AS organisme
FROM pr_priority_flora.t_zprospect tzp
JOIN pr_priority_flora.cor_zp_obs observer ON observer.indexzp = tzp.indexzp
JOIN utilisateurs.t_roles roles ON roles.id_role = observer.id_role
join utilisateurs.bib_organismes orga on orga.id_organisme = roles.id_organisme
GROUP BY tzp.indexzp, roles.id_organisme
),
perturbations AS(
SELECT 
    tap.indexap,
    string_agg(n.label_default, ',') AS label_perturbation
FROM pr_priority_flora.t_apresence tap
JOIN pr_priority_flora.cor_ap_perturb p ON tap.indexap = p.indexap
JOIN ref_nomenclatures.t_nomenclatures n ON p.id_nomenclature = n.id_nomenclature
GROUP BY tap.indexap
),
area AS(
SELECT tzp.indexzp,
       string_agg(a.area_name::text, ','::text) AS area_name
FROM pr_priority_flora.t_zprospect tzp
JOIN pr_priority_flora.cor_zp_area zpa ON tzp.indexzp = zpa.indexzp
JOIN ref_geo.l_areas a ON zpa.id_area = a.id_area
GROUP BY tzp.indexzp
)

SELECT ap.indexap AS indexap,
				taxon.nom_valide AS nom_valide,
    		taxon.cd_nom AS cd_nom,
				ap.altitude_min AS altitude_min,
 				ap.altitude_max AS altitude_max,
 				ap.frequency AS frequency,
 				ap.comment AS comment,
				ref_nomenclatures.get_nomenclature_label(ap.id_nomenclatures_counting) as counting,
				ap.total_min AS total_min,
				ap.total_max AS total_max,
				ref_nomenclatures.get_nomenclature_label(ap.id_nomenclatures_habitat) as habitat,
				ref_nomenclatures.get_nomenclature_label(ap.id_nomenclatures_phenology) as pheno, 
    		per.label_perturbation AS label_perturbation,
    		obs.observateurs AS observateurs,
    		obs.organisme AS organisme,
    		area.area_name AS area_name,
				ap.geom_4326 AS geom_local
  FROM pr_priority_flora.t_apresence ap
     LEFT JOIN pr_priority_flora.t_zprospect z ON z.indexzp = ap.indexzp
     LEFT JOIN observers obs ON obs.indexzp = z.indexzp
     LEFT JOIN area ON area.indexzp = z.indexzp
     LEFT JOIN perturbations per ON per.indexap = ap.indexap
     LEFT JOIN taxonomie.taxref taxon ON taxon.cd_nom = z.cd_nom;

-----------------------------------------------------------------------
-- Fonction Trigger: suppression de l'ap dans la synthèse 
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.delete_synthese_ap()
  RETURNS trigger AS
$BODY$
--il n'y a pas de trigger delete sur la table t_zprospection parce qu'il y a un delete cascade dans la fk indexzp de t_apresence
--donc si on supprime la zp, on supprime sa ou ces ap et donc ce trigger sera déclanché et fera le ménage dans la table gn_synthese.synthese
DECLARE 
  mazp RECORD;
BEGIN
  --on fait le delete dans gn_synthese.synthese
  DELETE FROM gn_synthese.synthese 
  WHERE id_source = (SELECT id_source FROM gn_synthese.t_sources WHERE name_source ILIKE 'Bilan Conservatoire Flore') 
  AND entity_source_pk_value = CAST(old.indexap AS VARCHAR);
	RETURN old; 			
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

-----------------------------------------------------------------------
-- Fonction Trigger: mise à jour de cor_zp_obs dans la synthèse 
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.update_synthese_cor_zp_obs()
  RETURNS trigger AS
$BODY$
DECLARE 
  mesap RECORD;
  theidsynthese INTEGER;
  theobservers VARCHAR;
BEGIN
  --Récupération de la liste des observateurs	
  --ici on va mettre à jour l'enregistrement dans synthese autant de fois qu'on insert dans cette table
	SELECT INTO theobservers array_to_string(array_agg(r.prenom_role || ' ' || r.nom_role), ', ') AS observateurs 
  FROM pr_priority_flora.cor_zp_obs c
  JOIN utilisateurs.t_roles r ON r.id_role = c.id_role
  JOIN pr_priority_flora.t_zprospect zp ON zp.indexzp = c.indexzp
  WHERE c.indexzp = new.indexzp;
  --on boucle sur tous les enregistrements de la zp
  --si la zp est sans ap, la boucle ne se fait pas
  FOR mesap IN SELECT ap.indexap FROM pr_priority_flora.t_zprospect zp JOIN pr_priority_flora.t_apresence ap ON ap.indexzp = zp.indexzp WHERE ap.indexzp = new.indexzp  LOOP
    -- on récupére l'id_synthese
    SELECT INTO theidsynthese id_synthese 
    FROM gn_synthese.synthese
    WHERE id_source = (SELECT id_source FROM gn_synthese.t_sources WHERE name_source ILIKE 'Bilan Conservatoire Flore') 
    AND entity_source_pk_value = CAST(mesap.indexap AS VARCHAR);
    --on fait le update du champ observateurs dans synthese
    UPDATE gn_synthese.synthese
    SET 
      observers = theobservers,
      determiner = theobservers,
      last_action = 'u'
    WHERE id_synthese = theidsynthese;
    INSERT INTO gn_synthese.cor_observer_synthese (id_synthese, id_role) VALUES(theidsynthese, new.id_role);
  END LOOP;
	RETURN NEW; 			
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

-----------------------------------------------------------------------
-- Fonction Trigger: insertion de l'ap dans la synthèse 
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.insert_synthese_ap()
  RETURNS trigger AS
$BODY$
DECLARE
  thezp RECORD;
  theobservers VARCHAR;
	thecomptagemethodo INTEGER;
  thetaxrefversion VARCHAR;
	thestadevie INTEGER;
  --theidprecision INTEGER;
BEGIN
  SELECT INTO thezp * FROM pr_priority_flora.t_zprospect WHERE indexzp = new.indexzp;
  
  --Récupération des données dans la table t_zprospect et de la liste des observateurs 
  SELECT INTO theobservers array_to_string(array_agg(r.prenom_role || ' ' || r.nom_role), ', ') AS observateurs 
  FROM pr_priority_flora.cor_zp_obs c
  JOIN utilisateurs.t_roles r ON r.id_role = c.id_role
  JOIN pr_priority_flora.t_zprospect zp ON zp.indexzp = c.indexzp
  WHERE c.indexzp = new.indexzp;

	--Récupération du stade de vie
    IF (new.id_nomenclatures_phenology) THEN 
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','132') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','128') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','129') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','127') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','130') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','132') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','19') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','131') INTO thestadevie;
    ELSE
      SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','0') INTO thestadevie;
    END IF;

	--Récupération de la méthode de comptage
    IF (new.id_nomenclatures_counting) THEN 
	    SELECT ref_nomenclatures.get_id_nomenclature('TYP_DENBR','Co') INTO thecomptagemethodo;
    ELSIF (new.id_nomenclatures_counting) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('TYP_DENBR','Ca') INTO thecomptagemethodo;
    ELSE
      SELECT ref_nomenclatures.get_id_nomenclature('TYP_DENBR','NSP') INTO thecomptagemethodo;
    END IF;

  --Récupération de la version taxref
    SELECT parameter_value INTO thetaxrefversion FROM gn_commons.t_parameters WHERE parameter_name = 'taxref_version';
  
	INSERT INTO gn_synthese.synthese
    (
      unique_id_sinp,
      unique_id_sinp_grp,
      id_source,
      entity_source_pk_value,
      id_dataset,
      id_nomenclature_geo_object_nature,
      id_nomenclature_grp_typ,
      id_nomenclature_obs_meth,
      id_nomenclature_bio_status,
      id_nomenclature_bio_condition,
      id_nomenclature_naturalness,
      id_nomenclature_exist_proof,
      id_nomenclature_diffusion_level,
      id_nomenclature_life_stage,
      id_nomenclature_sex,
      id_nomenclature_obj_count,
      id_nomenclature_type_count,
      id_nomenclature_sensitivity,
      id_nomenclature_observation_status,
      id_nomenclature_blurring,
      id_nomenclature_source_status,
      id_nomenclature_info_geo_type,
      count_min,
      count_max,
      cd_nom,
      nom_cite,
      meta_v_taxref,
      altitude_min,
      altitude_max,
      the_geom_4326, 		--EPSG 4326
      the_geom_point, 	--EPSG 4326
      the_geom_local, 	--EPSG 2154
      date_min,
      date_max,
      observers,
      determiner,
      comment_description,
      last_action
    )
    VALUES
    ( 
      new.unique_id_sinp_ap,
      thezp.unique_id_sinp_zp,
      104, --TODO 104 = PNE
      new.indexap,
      thezp.id_dataset,
      ref_nomenclatures.get_id_nomenclature('NAT_OBJ_GEO','In'),
      ref_nomenclatures.get_id_nomenclature('TYP_GRP','OBS'),
      ref_nomenclatures.get_id_nomenclature('METH_OBS','0'),
      ref_nomenclatures.get_id_nomenclature('STATUT_BIO','12'),
      ref_nomenclatures.get_id_nomenclature('ETA_BIO','2'),
      ref_nomenclatures.get_id_nomenclature('NATURALITE','1'),
      ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST','2'),
      ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','5'),
      thestadevie,
      ref_nomenclatures.get_id_nomenclature('SEXE','6'),
      ref_nomenclatures.get_id_nomenclature('OBJ_DENBR','NSP'),
      thecomptagemethodo,
      NULL,--todo sensitivity
      ref_nomenclatures.get_id_nomenclature('STATUT_OBS','Pr'),
      ref_nomenclatures.get_id_nomenclature('DEE_FLOU','NON'),
      ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE','Te'),
      ref_nomenclatures.get_id_nomenclature('TYP_INF_GEO','1'),
      new.total_min,--count_min
      new.total_max,--count_max
      thezp.cd_nom,
      COALESCE(thezp.initial_insert,'non disponible'),
      thetaxrefversion,
      new.altitude_min,--altitude_min
      new.altitude_max,--altitude_max
      new.geom_4326,
      new.geom_point_4326,
      new.the_geom_local,
      thezp.date_min,--date_min
      thezp.date_max,--date_max
      theobservers,--observers
      theobservers,--determiner
      new.comment,
      'c'
    );
  RETURN NEW;       
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

-----------------------------------------------------------------------
-- Fonction Trigger: mise à jour de l'ap dans la synthèse 
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.update_synthese_ap()
  RETURNS trigger AS
$BODY$
DECLARE
	thecomptagemethodo INTEGER;
  thestadevie INTEGER;
  --theidprecision integer;
BEGIN
  --On ne fait qq chose que si l'un des champs de la table t_apresence concerné dans gn_synthese.synthese a changé
  IF (
    new.indexap <> old.indexap 
    OR new.unique_id_sinp_ap <> old.unique_id_sinp_ap 
    OR new.id_nomenclatures_phenology <> old.id_nomenclatures_phenology
    OR new.indexzp <> old.indexzp 
    OR ((new.altitude_min <> old.altitude_min) OR (new.altitude_min is null and old.altitude_min is NOT NULL) OR (new.altitude_min is NOT NULL and old.altitude_min is null))
    OR ((new.altitude_max <> old.altitude_max) OR (new.altitude_max is null and old.altitude_max is NOT NULL) OR (new.altitude_max is NOT NULL and old.altitude_max is null))
		OR ((new.comment <> old.comment) OR (new.comment is null and old.comment is NOT NULL) OR (new.comment is NOT NULL and old.comment is null))
    OR new.id_nomenclatures_counting <> old.id_nomenclatures_counting 
    OR new.total_min <> old.total_min 
    OR new.total_max <> old.total_max 
    OR (NOT public.st_equals(new.geom_local,old.geom_local) OR NOT public.st_equals(new.geom_4326,old.geom_4326) OR NOT public.st_equals(new.geom_point_4326,old.geom_point_4326))
  ) THEN
	--Récupération du stade de vie
    IF (new.id_nomenclatures_phenology) THEN 
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','132') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','128') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','129') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','127') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','130') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','132') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','19') INTO thestadevie;
    ELSIF (new.id_nomenclatures_phenology) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','131') INTO thestadevie;
    ELSE
      SELECT ref_nomenclatures.get_id_nomenclature('STADE_VIE','0') INTO thestadevie;
    END IF;

	--Récupération de la méthode de comptage
    IF (new.id_nomenclatures_counting) THEN 
	    SELECT ref_nomenclatures.get_id_nomenclature('TYP_DENBR','Co') INTO thecomptagemethodo;
    ELSIF (new.id_nomenclatures_counting) THEN
	    SELECT ref_nomenclatures.get_id_nomenclature('TYP_DENBR','Ca') INTO thecomptagemethodo;
    ELSE
      SELECT ref_nomenclatures.get_id_nomenclature('TYP_DENBR','NSP') INTO thecomptagemethodo;
    END IF;

    UPDATE gn_synthese.synthese
    SET 
      --id_precision = monidprecision,
      entity_source_pk_value = new.indexap,
      unique_id_sinp = new.unique_id_sinp_ap,
      id_nomenclature_type_count = thecomptagemethodo,
      id_nomenclature_life_stage = thestadevie,
      altitude_min = new.altitude_min,
      altitude_max = new.altitude_max,
      count_min = new.total_min,
      count_max = new.total_max,
      comment_description = new.comment,
      last_action = 'u',
      the_geom_4326 = new.geom_4326,
      the_geom_local = new.geom_local,
      the_geom_point = new.geom_point_4326
    WHERE id_source = (SELECT id_source FROM gn_synthese.t_sources WHERE name_source ILIKE 'Bilan Conservatoire Flore') 
    AND entity_source_pk_value = CAST(old.indexap AS VARCHAR);
  END IF;
  RETURN NEW;       
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

-----------------------------------------------------------------------
-- Fonction Trigger: mise à jour de la zp dans la synthèse 
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.update_synthese_zp()
  RETURNS trigger AS
$BODY$
DECLARE 
  mesap RECORD;
  thetaxon VARCHAR;
BEGIN
  FOR mesap IN SELECT ap.indexap FROM pr_priority_flora.t_zprospect zp JOIN pr_priority_flora.t_apresence ap ON ap.indexzp = zp.indexzp WHERE ap.indexzp = new.indexzp  LOOP
    --On ne fait qq chose que si l'un des champs de la table t_zprospect concerné dans synthese a changé
    IF (
            new.indexzp <> old.indexzp
            OR new.unique_id_sinp_zp <> old.unique_id_sinp_zp 
            OR ((new.cd_nom <> old.cd_nom) OR (new.cd_nom is null and old.cd_nom is NOT NULL) OR (new.cd_nom is NOT NULL and old.cd_nom is null))
            OR ((new.date_min <> old.date_min) OR (new.date_min is null and old.date_min is NOT NULL) OR (new.date_min is NOT NULL and old.date_min is null))
						OR ((new.date_max <> old.date_max) OR (new.date_max is null and old.date_max is NOT NULL) OR (new.date_max is NOT NULL and old.date_max is null))
  
        ) THEN
        --Récupération du nom du taxon
        SELECT INTO thetaxon t.nom_valide AS taxon 
        FROM pr_priority_flora.t_zprospect zp
        JOIN taxonomie.taxref t ON t.cd_nom = zp.cd_nom
        WHERE zp.indexzp = new.indexzp;
        --on fait le update dans synthese
        UPDATE gn_synthese.synthese 
        SET 
          unique_id_sinp_grp = new.unique_id_sinp_zp,
          cd_nom = new.cd_nom,
          nom_cite = thetaxon,
          date_min = new.date_min,
          date_max = new.date_max,
          last_action = 'u'
        WHERE id_source = (SELECT id_source FROM gn_synthese.t_sources WHERE name_source ILIKE 'Bilan Conservatoire Flore') 
        AND entity_source_pk_value = CAST(mesap.indexap AS VARCHAR);
    END IF;
  END LOOP;
	RETURN NEW; 			
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

-----------------------------------------------------------------------
-- Triggers: création des triggers de la synthèse 
-----------------------------------------------------------------------

CREATE TRIGGER tri_insert_synthese_cor_zp_obs AFTER INSERT ON pr_priority_flora.cor_zp_obs FOR EACH ROW EXECUTE PROCEDURE pr_priority_flora.update_synthese_cor_zp_obs();
CREATE TRIGGER tri_delete_synthese_ap AFTER DELETE ON pr_priority_flora.t_apresence FOR EACH ROW EXECUTE PROCEDURE pr_priority_flora.delete_synthese_ap();
CREATE TRIGGER tri_insert_synthese_ap AFTER INSERT ON pr_priority_flora.t_apresence FOR EACH ROW EXECUTE PROCEDURE pr_priority_flora.insert_synthese_ap();
CREATE TRIGGER tri_update_synthese_ap AFTER UPDATE ON pr_priority_flora.t_apresence FOR EACH ROW EXECUTE PROCEDURE pr_priority_flora.update_synthese_ap();
CREATE TRIGGER tri_update_synthese_zp AFTER UPDATE ON pr_priority_flora.t_zprospect FOR EACH ROW EXECUTE PROCEDURE pr_priority_flora.update_synthese_zp();
