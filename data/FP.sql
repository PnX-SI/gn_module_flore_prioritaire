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
-- Insertion du jeu de données BCF dans t_datasets
----------------------------------------------------------------------------------------------------

INSERT INTO gn_meta.t_datasets
(unique_dataset_id, id_acquisition_framework, dataset_name, dataset_shortname, dataset_desc, id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, id_nomenclature_dataset_objectif, bbox_west, bbox_east, bbox_south, bbox_north, id_nomenclature_collecting_method, id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, default_validity, active, meta_create_date, meta_update_date)
VALUES(uuid_generate_v4(), 0, 'Bilan Conservatoire Flore', 'BCF', 'Bilan Conservatoire Flore', ref_nomenclatures.get_default_nomenclature_value('DATA_TYP'::character varying), '', false, false, ref_nomenclatures.get_default_nomenclature_value('JDD_OBJECTIFS'::character varying), 0, 0, 0, 0, ref_nomenclatures.get_default_nomenclature_value('METHO_RECUEIL'::character varying), ref_nomenclatures.get_default_nomenclature_value('DS_PUBLIQUE'::character varying), ref_nomenclatures.get_default_nomenclature_value('STATUT_SOURCE'::character varying), ref_nomenclatures.get_default_nomenclature_value('RESOURCE_TYP'::character varying), false, true, '', '');

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

----------------------------------------------------------------------------------------------------
-- Fonction Trigger: actualisation de la table t_validations après l'ajout d'une zone de prospection
----------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.fct_trg_add_default_validation_status()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
	theschema text := quote_ident(TG_TABLE_SCHEMA);
	thetable text := quote_ident(TG_TABLE_NAME);
	theidtablelocation int;
	theuuidfieldname character varying(50);
	theuuid uuid;
  thecomment text := 'auto = default value';
BEGIN
  --Retrouver l'id de la table source stockant l'enregistrement en cours de validation
	SELECT INTO theidtablelocation gn_commons.get_table_location_id(theschema,thetable);
  --Retouver le nom du champ stockant l'uuid de l'enregistrement en cours de validation
	SELECT INTO theuuidfieldname gn_commons.get_uuid_field_name(theschema,thetable);
  --Récupérer l'uuid de l'enregistrement en cours de validation
	EXECUTE format('SELECT $1.%I', theuuidfieldname) INTO theuuid USING NEW;
  --Insertion du statut de validation et des informations associées dans t_validations
  INSERT INTO gn_commons.t_validations (id_table_location,uuid_attached_row,id_nomenclature_valid_status,id_validator,validation_comment,validation_date)
  VALUES(
    theidtablelocation,
    theuuid,
    ref_nomenclatures.get_default_nomenclature_value('STATUT_VALID'), --comme la fonction est générique, cette valeur par défaut doit exister et est la même pour tous les modules
    null,
    thecomment,
    NOW()
  );
  RETURN NEW;
END;
$function$
;

------------------------------------------------------------------------------------
-- Trigger: Lancement actualisation de la table t_validations suite à l'ajout de ZP
------------------------------------------------------------------------------------

CREATE TRIGGER tri_insert_default_validation_status
  AFTER INSERT
  ON t_zprospect
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.fct_trg_add_default_validation_status();

----------------------------------------------------------------------------------------------------
-- Fonction Trigger: actualisation de la synthèse après l'ajout d'une zone de prospection
----------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.fct_trg_update_synthese_validation_status()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
-- This trigger function update validation informations in corresponding row in synthese table
BEGIN
  UPDATE gn_synthese.synthese 
  SET id_nomenclature_valid_status = NEW.id_nomenclature_valid_status,
  validation_comment = NEW.validation_comment,
  validator = (SELECT nom_role || ' ' || prenom_role FROM utilisateurs.t_roles WHERE id_role = NEW.id_validator)::text
  WHERE unique_id_sinp = NEW.uuid_attached_row;
RETURN NEW;
END;
$function$
;

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
$FUNCTION$
DECLARE
id_dataset integer;

BEGIN

-- Récupération du id_dataset
SELECT INTO id_dataset d.id_dataset FROM gn_meta.t_datasets d WHERE dataset_name ILIKE 'Bilan Conservatoire Flore';

IF new.indexzp in (SELECT indexzp FROM pr_priority_flora.t_zprospect) THEN
	RETURN NULL;
ELSE

new.geom_local = st_transform(new.geom_4326,2154);
		
	RETURN NEW;
END IF;	
END;
$FUNCTION$
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

		new.geom_local = st_transform(new.geom_4326,2154);
		new.area = st_area(new.geom_local);
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
