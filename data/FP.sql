SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE SCHEMA pr_priority_flora;

SET search_path = pr_priority_flora, pg_catalog, public;

SET default_with_oids = false;

------------------------
--TABLES AND SEQUENCES--
------------------------
------------------------------------------------------------
-- Table: t_zprospect
------------------------------------------------------------

CREATE TABLE pr_priority_flora.t_zprospect(
	indexzp             serial NOT NULL,
	date_min            DATE,
	date_max            DATE,
	topo_valid          BOOLEAN,
	initial_insert      VARCHAR (20),
	srid_design         INT,
	cd_nom		        INT,
	id_history_action   INT,
	id_validation       INT,
	id_dataset          INT,
	unique_id_sinp_zp   UUID DEFAULT public.uuid_generate_v4(),
	geom_local          geometry(Geometry,2154),
	geom_4326           geometry(Geometry,4326),
	geom_point_4326     geometry(Point,4326),
	
    CONSTRAINT pk_t_zprospect PRIMARY KEY (indexzp),
	CONSTRAINT fk_t_zprospect_taxref FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom),
	CONSTRAINT fk_t_apresence_t_history_actions FOREIGN KEY (id_history_action) REFERENCES gn_commons.t_history_actions(id_history_action),
	CONSTRAINT fk_t_apresence_t_validations FOREIGN KEY (id_validation) REFERENCES gn_commons.t_validations(id_validation),
	CONSTRAINT fk_t_apresence_t_datasets FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset)
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
	CONSTRAINT fk_cor_zp_obs_t_zprospect FOREIGN KEY (indexzp) REFERENCES pr_priority_flora.t_zprospect(indexzp),
	CONSTRAINT fk_cor_zp_obs_t_roles FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role)
)
WITH (
  OIDS=FALSE
);
------------------------------------------------------------
-- Table: t_apresence
------------------------------------------------------------

CREATE TABLE pr_priority_flora.t_apresence(
	indexap                                           serial NOT NULL,
	area                                              INT  NOT NULL,
	frequency                                         FLOAT  NOT NULL,
	topo_valid                                        BOOLEAN,
	altitude_min                                      INT  NOT NULL DEFAULT 0,
	altitude_max                                      INT  NOT NULL DEFAULT 0,
	nb_transects_frequency                            INT  NOT NULL DEFAULT 0,
	nb_points_frequency                               INT  NOT NULL DEFAULT 0,
	nb_contacts_frequency                             INT  NOT NULL DEFAULT 0,
	nb_plots_count                                    INT  NOT NULL DEFAULT 0,
	area_plots_count                                  FLOAT  NOT NULL,
	comment                                           VARCHAR (200),
	step_length                                       NUMERIC (10,2),
	indexzp						  					  INT,
	id_nomenclatures_pente				  			  INT,
	id_nomenclatures_count_method			  		  INT,
	id_nomenclatures_freq_method			  		  INT,
	id_nomenclatures_phenology			  			  INT,
	id_history_action				  				  INT,
	nb_sterile_plots                                  INT ,
	nb_fertile_plots                                  INT ,
	total_sterile                                     INT ,
	total_fertile                                     INT ,
	unique_id_sinp_zp                                 UUID DEFAULT public.uuid_generate_v4(),
	geom_local                                        geometry(Geometry,2154),
	geom_4326                                         geometry(Geometry,4326),
	geom_point_4326                                   geometry(Point,4326),
	
    CONSTRAINT pk_t_apresence PRIMARY KEY (indexap),
	CONSTRAINT fk_t_apresence_t_zprospect FOREIGN KEY (indexzp) REFERENCES pr_priority_flora.t_zprospect(indexzp),
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_pente FOREIGN KEY (id_nomenclatures_pente) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature),
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_count_method FOREIGN KEY (id_nomenclatures_count_method) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature),
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_freq_method FOREIGN KEY (id_nomenclatures_freq_method) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature),
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_phenology FOREIGN KEY (id_nomenclatures_phenology) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature),
	CONSTRAINT fk_t_apresence_t_history_actions FOREIGN KEY (id_history_action) REFERENCES gn_commons.t_history_actions(id_history_action)
)
WITH (
  OIDS=FALSE
);

------------------------------------------------------------
-- Table: cor_zp_area
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_zp_area(
	id_area   INT  NOT NULL,
	indexzp   INT  NOT NULL,
	
	CONSTRAINT pk_cor_zp_area PRIMARY KEY (id_area,indexzp),
	CONSTRAINT fk_cor_zp_area_l_areas FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area),
	CONSTRAINT fk_cor_zp_area_t_zprospect FOREIGN KEY (indexzp) REFERENCES pr_priority_flora.t_zprospect(indexzp)
)
WITH (
  OIDS=FALSE
);

------------------------------------------------------------
-- Table: cor_ap_area
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_ap_area(
	id_area   INT  NOT NULL,
	indexap   INT  NOT NULL,
	
	CONSTRAINT pk_cor_ap_area PRIMARY KEY (id_area,indexap),
	CONSTRAINT fk_cor_ap_area_l_areas FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area),
	CONSTRAINT fk_cor_ap_area_t_apresence FOREIGN KEY (indexap) REFERENCES pr_priority_flora.t_apresence(indexap)
)
WITH (
  OIDS=FALSE
);

------------------------------------------------------------
-- Table: cor_ap_perturb
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_ap_perturb(
	indexap           INT  NOT NULL,
	id_nomenclature   INT  NOT NULL,

	CONSTRAINT pk_cor_ap_perturb PRIMARY KEY (indexap,id_nomenclature),
	CONSTRAINT fk_cor_ap_perturb_t_apresence FOREIGN KEY (indexap) REFERENCES pr_priority_flora.t_apresence(indexap),
	CONSTRAINT fk_cor_ap_perturb_t_nomenclatures FOREIGN KEY (id_nomenclature) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature)
)
WITH (
  OIDS=FALSE
);

------------------------------------------------------------
-- Table: cor_ap_physionomie
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_ap_physionomie(
	indexap           INT  NOT NULL,
	id_nomenclature   INT  NOT NULL,

	CONSTRAINT pk_cor_ap_physionomie PRIMARY KEY (indexap,id_nomenclature),
	CONSTRAINT fk_cor_ap_physionomie_t_apresence FOREIGN KEY (indexap) REFERENCES pr_priority_flora.t_apresence(indexap),
	CONSTRAINT fk_cor_ap_physionomie_t_nomenclatures FOREIGN KEY (id_nomenclature) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature)
)
WITH (
  OIDS=FALSE
);

------------------------------------------------------------
-- Trigger: actualisation de cor_ap_area
------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.fct_trg_cor_ap_area()
  RETURNS trigger AS
$BODY$
BEGIN

	DELETE FROM pr_priority_flora.cor_ap_area WHERE indexap = NEW.indexap;
	INSERT INTO pr_priority_flora.cor_ap_area
	SELECT NEW.indexap, (ref_geo.fct_get_area_intersection(NEW.geom)).id_area;

  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION pr_priority_flora.fct_trg_cor_ap_area()
  OWNER TO geonatuser;

------------------------------------------------------------
-- Trigger: actualisation de cor_zp_area
------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.fct_trg_cor_zp_area()
  RETURNS trigger AS
$BODY$
BEGIN

	DELETE FROM pr_priority_flora.cor_zp_area WHERE indexzp = NEW.indexzp;
	INSERT INTO pr_priority_flora.cor_zp_area
	SELECT NEW.indexzp, (ref_geo.fct_get_area_intersection(NEW.geom)).id_area;

  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION pr_priority_flora.fct_trg_cor_zp_area()
  OWNER TO geonatuser;

