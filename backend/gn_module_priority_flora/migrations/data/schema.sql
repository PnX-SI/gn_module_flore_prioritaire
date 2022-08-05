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
	indexzp bigserial NOT NULL,
	date_min DATE,
	date_max  DATE,
	topo_valid  BOOLEAN,
	initial_insert VARCHAR (20),
	cd_nom INT,
	id_dataset INT,
	uuid_zp UUID DEFAULT public.uuid_generate_v4(),
	additional_data jsonb,
	geom_local geometry(Geometry, :local_srid),
	geom_4326 geometry(Geometry, 4326),
	geom_point_4326 geometry(Point, 4326),
	meta_create_date timestamp NULL DEFAULT now(),
	meta_update_date timestamp NULL,

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
	indexzp INT NOT NULL,
	id_role INT NOT NULL,

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
	indexap bigserial NOT NULL,
	area FLOAT,
	topo_valid BOOLEAN,
	altitude_min INT DEFAULT 0,
	altitude_max  INT DEFAULT 0,
    frequency FLOAT,
	comment VARCHAR (2000),
	indexzp BIGINT,
	id_nomenclatures_pente INT,
	id_nomenclatures_counting INT,
	id_nomenclatures_habitat INT,
	id_nomenclatures_phenology INT,
	id_history_action INT,
	total_min INT,
	total_max INT,
	uuid_ap UUID DEFAULT public.uuid_generate_v4(),
	additional_data jsonb,
	geom_local geometry(Geometry, :local_srid),
	geom_4326 geometry(Geometry, 4326),
	geom_point_4326 geometry(Point, 4326),
	meta_create_date timestamp NULL DEFAULT now(),
	meta_update_date timestamp NULL,

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
	id_area INT NOT NULL,
	indexzp BIGINT NOT NULL,

	CONSTRAINT pk_cor_zp_area PRIMARY KEY (id_area, indexzp),
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
	id_area INT NOT NULL,
	indexap BIGINT NOT NULL,

	CONSTRAINT pk_cor_ap_area PRIMARY KEY (id_area, indexap),
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
	indexap BIGINT NOT NULL,
	id_nomenclature INT  NOT NULL,
	pres_effective BOOLEAN,

	CONSTRAINT pk_cor_ap_perturb PRIMARY KEY (indexap, id_nomenclature),
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
	COST 100 ;

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


CREATE OR REPLACE VIEW pr_priority_flora.export_ap
AS
	SELECT DISTINCT
		ta.indexzp AS id_zp,
		ta.indexap AS id_ap,
		t.nom_complet AS taxon,
		string_agg(DISTINCT (roles.prenom_role || ' ' || roles.nom_role || ' (' || bo.nom_organisme || ')'), ', ') AS observateurs,
		ref_nomenclatures.get_nomenclature_label(ta.id_nomenclatures_habitat) AS habitat,
		ref_nomenclatures.get_nomenclature_label(ta.id_nomenclatures_phenology) AS pheno,
		ref_nomenclatures.get_nomenclature_label(ta.id_nomenclatures_pente) AS pente,
		ref_nomenclatures.get_nomenclature_label(ta.id_nomenclatures_counting) AS comptage,
		ta.total_min,
		ta.total_max,
		string_agg(DISTINCT tn.label_default, ', ') AS type_perturbation,
		ta.frequency AS frequence_methode,
		ta."comment"  AS remarques,
		string_agg(DISTINCT la.area_name, ', ') AS secteur,
		tz.date_min AS date_min,
		tz.date_max AS date_max,
		ta.altitude_min AS altitude_min,
		ta.altitude_max AS altitude_max,
		ta."area" AS surface_ap,
		ST_area(tz.geom_local) AS surface_zp,
		ta.geom_local AS ap_geom_local,
		tz.geom_local AS zp_geom_local
	FROM pr_priority_flora.t_apresence ta
		LEFT JOIN pr_priority_flora.cor_ap_area cap
			ON cap.indexap = ta.indexap
		LEFT JOIN ref_geo.l_areas la
			ON la.id_area = cap.id_area
		LEFT JOIN pr_priority_flora.cor_zp_obs observer
			ON observer.indexzp = ta.indexzp
		LEFT JOIN utilisateurs.t_roles AS roles
			ON roles.id_role = observer.id_role
		LEFT JOIN utilisateurs.bib_organismes AS bo
			ON bo.id_organisme = roles.id_organisme
		LEFT JOIN pr_priority_flora.cor_ap_perturb caper
			ON caper.indexap = ta.indexap
		LEFT JOIN ref_nomenclatures.t_nomenclatures tn
			ON tn.id_nomenclature = caper.id_nomenclature
		LEFT JOIN pr_priority_flora.t_zprospect tz
			ON tz.indexzp = ta.indexzp
		LEFT JOIN taxonomie.taxref t
			ON t.cd_nom = tz.cd_nom
	WHERE la.id_type = ref_geo.get_id_area_type('COM'::character varying)
	GROUP BY ta.indexap, ta.indexzp, t.nom_complet, tz.geom_local, tz.date_min, tz.date_max ;
;
