SET client_encoding = 'UTF8';

CREATE SCHEMA pr_priority_flora;

SET search_path = pr_pr_priority_flora, pg_catalog, public;


------------------------
--TABLES AND SEQUENCES--
------------------------

------------------------------------------------------------
-- Table: t_zprospect
------------------------------------------------------------

CREATE TABLE pr_priority_flora.t_zprospect(
	indexzp             bigserial NOT NULL,
	date_min            DATE,
	date_max            DATE,
	topo_valid          BOOLEAN,
	initial_insert      VARCHAR (20),
	cd_nom		        INT,
	id_dataset          INT,
	unique_id_sinp_zp   UUID DEFAULT public.uuid_generate_v4(),
	additional_data     jsonb,
	geom_local          geometry(Geometry,:local_srid),
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
	indexzp   INT  NOT NULL,
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
	comment                                           VARCHAR (2000),
	indexzp						  					  BIGINT,
	id_nomenclatures_pente				  			  INT,
	id_nomenclatures_counting			  		      INT,
	id_nomenclatures_habitat			  		      INT,
	id_nomenclatures_phenology			  			  INT,
	id_history_action				  				  INT,
	total_min                                         INT,
	total_max                                         INT,
	unique_id_sinp_ap                                 UUID DEFAULT public.uuid_generate_v4(),
	additional_data                                   jsonb,
	geom_local                                        geometry(Geometry,:local_srid),
	geom_4326                                         geometry(Geometry,4326),
	geom_point_4326                                   geometry(Point,4326),
	
  CONSTRAINT pk_t_apresence PRIMARY KEY (indexap),
	CONSTRAINT fk_t_apresence_t_zprospect FOREIGN KEY (indexzp) REFERENCES pr_priority_flora.t_zprospect(indexzp) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_pente FOREIGN KEY (id_nomenclatures_pente) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_counting FOREIGN KEY (id_nomenclatures_counting) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_habitat FOREIGN KEY (id_nomenclatures_habitat) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_phenology FOREIGN KEY (id_nomenclatures_phenology) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_t_apresence_t_history_actions FOREIGN KEY (id_history_action) REFERENCES gn_commons.t_history_actions(id_history_action) ON UPDATE CASCADE ON DELETE NO ACTION
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
	pres_effective		BOOLEAN,	

	CONSTRAINT pk_cor_ap_perturb PRIMARY KEY (indexap,id_nomenclature),
	CONSTRAINT fk_cor_ap_perturb_t_apresence FOREIGN KEY (indexap) REFERENCES pr_priority_flora.t_apresence(indexap) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_cor_ap_perturb_t_nomenclatures FOREIGN KEY (id_nomenclature) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);

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

BEGIN

IF new.indexzp in (SELECT indexzp FROM pr_priority_flora.t_zprospect) THEN
	RETURN NULL;
ELSE

		new.geom_local = st_transform(new.geom_4326,:local_srid);
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

		new.geom_local = st_transform(new.geom_4326,:local_srid);
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

------------------------------------
-- Vue: Création de la vue d'export
------------------------------------

CREATE OR REPLACE VIEW pr_priority_flora.export_ap AS 
  SELECT ap.indexap AS indexap,
				ap.altitude_min AS altitude_min,
 				ap.altitude_max AS altitude_max,
 				ap.frequency AS frequency,
 				ap.comment AS comment,
 				ref_nomenclatures.get_nomenclature_label(ap.id_nomenclatures_pente) as pente,
				ref_nomenclatures.get_nomenclature_label(ap.id_nomenclatures_counting) as counting,
				ap.total_min AS total_min,
				ap.total_max AS total_max,
				ref_nomenclatures.get_nomenclature_label(ap.id_nomenclatures_habitat) as habitat,
				ref_nomenclatures.get_nomenclature_label(ap.id_nomenclatures_phenology) as pheno, 
    		string_agg((roles.nom_role::text || ' '::text) || roles.prenom_role::text, ','::text) AS observateurs,
    		string_agg(n.label_default::text, ','::text) AS label_perturbation,
    		string_agg(a.area_name::text, ','::text) AS area_name,
				ap.geom_4326 AS geom_local
  FROM pr_priority_flora.t_apresence ap
     LEFT JOIN pr_priority_flora.t_zprospect z ON z.indexzp = ap.indexzp
     LEFT JOIN pr_priority_flora.cor_zp_obs observer ON observer.indexzp = z.indexzp
     LEFT JOIN utilisateurs.t_roles roles ON roles.id_role = observer.id_role
     LEFT JOIN pr_priority_flora.cor_ap_area cap ON cap.indexap = ap.indexap
     LEFT JOIN ref_geo.l_areas a ON a.id_area = cap.id_area
     LEFT JOIN pr_priority_flora.cor_ap_perturb p ON ap.indexap = p.indexap
     LEFT JOIN ref_nomenclatures.t_nomenclatures n ON p.id_nomenclature = n.id_nomenclature
  WHERE a.id_type = ref_geo.get_id_area_type('COM'::character varying)
  GROUP BY ap.indexap,ap.altitude_min,ap.altitude_max,ap.frequency,ap.comment,ref_nomenclatures.get_nomenclature_label(ap.id_nomenclatures_pente),
				ref_nomenclatures.get_nomenclature_label(ap.id_nomenclatures_counting), ap.total_min, ap.total_max, 
				ref_nomenclatures.get_nomenclature_label(ap.id_nomenclatures_habitat), ref_nomenclatures.get_nomenclature_label(ap.id_nomenclatures_phenology),ap.geom_4326;
				
