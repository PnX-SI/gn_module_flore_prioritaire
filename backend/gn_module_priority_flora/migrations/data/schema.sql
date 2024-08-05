SET client_encoding = 'UTF8';

CREATE SCHEMA pr_priority_flora;

SET search_path = pr_pr_priority_flora, pg_catalog, public;
SET default_with_oids = false;

------------------------
--TABLES AND SEQUENCES--
------------------------

------------------------------------------------------------
-- Table: t_zprospect
------------------------------------------------------------

CREATE TABLE pr_priority_flora.t_zprospect(
  id_zp BIGSERIAL NOT NULL,
  id_dataset INT,
  uuid_zp UUID DEFAULT public.uuid_generate_v4(),
  cd_nom INT,
  date_min DATE,
  date_max  DATE,
  geom_local geometry(GEOMETRY, :localSrid),
  geom_4326 geometry(GEOMETRY, 4326),
  geom_point_4326 geometry(POINT, 4326),
  area FLOAT,
  initial_insert VARCHAR (20),
  topo_valid  BOOLEAN,
  additional_data JSONB,
  meta_create_date TIMESTAMP NULL DEFAULT now(),
  meta_update_date TIMESTAMP NULL,

  CONSTRAINT pk_t_zprospect PRIMARY KEY (id_zp),
  CONSTRAINT fk_t_zprospect_taxref FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom) ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT fk_t_apresence_t_datasets FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE ON DELETE NO ACTION
);

------------------------------------------------------------
-- Table: cor_zp_obs
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_zp_obs(
  id_zp INT NOT NULL,
  id_role INT NOT NULL,

  CONSTRAINT pk_cor_zp_obs PRIMARY KEY (id_zp, id_role),
  CONSTRAINT fk_cor_zp_obs_t_zprospect FOREIGN KEY (id_zp) REFERENCES pr_priority_flora.t_zprospect(id_zp) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cor_zp_obs_t_roles FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE ON DELETE NO ACTION
);
------------------------------------------------------------
-- Table: t_apresence
------------------------------------------------------------

CREATE TABLE pr_priority_flora.t_apresence(
  id_ap BIGSERIAL NOT NULL,
  uuid_ap UUID DEFAULT public.uuid_generate_v4(),
  id_zp BIGINT,
  geom_local geometry(GEOMETRY, :localSrid),
  geom_4326 geometry(GEOMETRY, 4326),
  geom_point_4326 geometry(POINT, 4326),
  area FLOAT NOT NULL,
  altitude_min INT DEFAULT 0,
  altitude_max  INT DEFAULT 0,
  id_nomenclature_incline INT,
  id_nomenclature_habitat INT,
  favorable_status_percent SMALLINT,
  id_nomenclature_threat_level INT,
  id_nomenclature_phenology INT,
  id_nomenclature_frequency_method INT,
  frequency FLOAT,
  id_nomenclature_counting INT,
  total_min INT,
  total_max INT,
  comment VARCHAR (2000),
  topo_valid BOOLEAN,
  additional_data JSONB,
  meta_create_date TIMESTAMP NULL DEFAULT now(),
  meta_update_date TIMESTAMP NULL,

  CONSTRAINT pk_t_apresence PRIMARY KEY (id_ap),
  CONSTRAINT fk_t_apresence_t_zprospect FOREIGN KEY (id_zp) REFERENCES pr_priority_flora.t_zprospect(id_zp) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_t_apresence_t_nomenclature_id_incline FOREIGN KEY (id_nomenclature_incline) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT fk_t_apresence_t_nomenclature_id_habitat FOREIGN KEY (id_nomenclature_habitat) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT fk_t_apresence_t_nomenclature_id_threat_level FOREIGN KEY (id_nomenclature_threat_level) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT fk_t_apresence_t_nomenclature_id_phenology FOREIGN KEY (id_nomenclature_phenology) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT fk_t_apresence_t_nomenclature_id_frequency_method FOREIGN KEY (id_nomenclature_frequency_method) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT fk_t_apresence_t_nomenclature_id_counting FOREIGN KEY (id_nomenclature_counting) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION
);

------------------------------------------------------------
-- Table: cor_zp_area
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_zp_area(
  id_zp BIGINT NOT NULL,
  id_area INT NOT NULL,

  CONSTRAINT pk_cor_zp_area PRIMARY KEY (id_area, id_zp),
  CONSTRAINT fk_cor_zp_area_l_areas FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT fk_cor_zp_area_t_zprospect FOREIGN KEY (id_zp) REFERENCES pr_priority_flora.t_zprospect(id_zp) ON UPDATE CASCADE ON DELETE CASCADE
);

------------------------------------------------------------
-- Table: cor_ap_area
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_ap_area(
  id_ap BIGINT NOT NULL,
  id_area INT NOT NULL,

  CONSTRAINT pk_cor_ap_area PRIMARY KEY (id_area, id_ap),
  CONSTRAINT fk_cor_ap_area_t_apresence FOREIGN KEY (id_ap) REFERENCES pr_priority_flora.t_apresence(id_ap) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cor_ap_area_l_areas FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE ON DELETE NO ACTION
);

------------------------------------------------------------
-- Table: cor_ap_perturbation
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_ap_perturbation(
  id_ap BIGINT NOT NULL,
  id_nomenclature INT  NOT NULL,
  effective_presence BOOLEAN,

  CONSTRAINT pk_cor_ap_perturbation PRIMARY KEY (id_ap, id_nomenclature),
  CONSTRAINT fk_cor_ap_perturbation_t_apresence FOREIGN KEY (id_ap) REFERENCES pr_priority_flora.t_apresence(id_ap) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cor_ap_perturbation_t_nomenclatures FOREIGN KEY (id_nomenclature) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);

------------------------------------------------------------
-- Table: cor_ap_physiognomy
------------------------------------------------------------

CREATE TABLE pr_priority_flora.cor_ap_physiognomy(
  id_ap BIGINT NOT NULL,
  id_nomenclature INT NOT NULL,

  CONSTRAINT pk_cor_ap_physiognomy PRIMARY KEY (id_ap, id_nomenclature),
  CONSTRAINT fk_cor_ap_physiognomy_t_apresence FOREIGN KEY (id_ap) REFERENCES pr_priority_flora.t_apresence(id_ap) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cor_ap_physiognomy_t_nomenclatures FOREIGN KEY (id_nomenclature) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION
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
  DELETE FROM pr_priority_flora.cor_ap_area WHERE id_ap = NEW.id_ap;
  INSERT INTO pr_priority_flora.cor_ap_area (id_ap, id_area)
  SELECT NEW.id_ap AS id_ap, (ref_geo.fct_get_area_intersection(NEW.geom_local)).id_area AS id_area;
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
  DELETE FROM pr_priority_flora.cor_zp_area WHERE id_zp = NEW.id_zp;
  INSERT INTO pr_priority_flora.cor_zp_area (id_zp, id_area)
  SELECT NEW.id_zp AS id_zp, (ref_geo.fct_get_area_intersection(NEW.geom_local)).id_area AS id_area;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

------------------------------------------------------------------
-- Trigger: Lancement actualisation de cor_zp_area sur t_zprospect
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
-- Fonction Trigger: actualisation champs geom_local et surface
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.edit_zp()
  RETURNS trigger AS
$BODY$
BEGIN
  IF (NEW.geom_local IS NULL) THEN
    NEW.geom_local = public.st_transform(NEW.geom_4326, :localSrid);
  END IF ;
  IF (NEW.geom_point_4326 IS NULL) THEN
    NEW.geom_point_4326 = public.st_pointonsurface(NEW.geom_4326);
  END IF ;
  IF (NEW."area" IS NULL) THEN
    NEW."area" = public.st_area(NEW.geom_local);
  END IF ;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100 ;

-----------------------------------------------------------------------
-- Fonction Trigger: actualisation champ geom_local et surface
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.edit_ap()
  RETURNS trigger AS
$BODY$
BEGIN
  IF (NEW.geom_local IS NULL) THEN
    NEW.geom_local = public.st_transform(NEW.geom_4326, :localSrid);
  END IF ;
  IF (NEW.geom_point_4326 IS NULL) THEN
    NEW.geom_point_4326 = public.st_pointonsurface(NEW.geom_4326);
  END IF ;
  IF (NEW."area" IS NULL) THEN
    NEW."area" = public.st_area(NEW.geom_local);
  END IF ;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-----------------------------------------------------------------------------------------
-- Trigger: Lancement actualisation des champs sur t_zprospect
-----------------------------------------------------------------------------------------

CREATE TRIGGER tri_change_meta_dates_zp
BEFORE INSERT OR UPDATE
ON pr_priority_flora.t_zprospect
FOR EACH ROW
EXECUTE PROCEDURE fct_trg_meta_dates_change() ;


CREATE TRIGGER tri_insert_zp
BEFORE INSERT
ON pr_priority_flora.t_zprospect
FOR EACH ROW
EXECUTE PROCEDURE pr_priority_flora.edit_zp();


CREATE TRIGGER tri_update_zp
BEFORE UPDATE
ON pr_priority_flora.t_zprospect
FOR EACH ROW
WHEN (OLD.geom_4326 IS DISTINCT FROM NEW.geom_4326)
EXECUTE PROCEDURE pr_priority_flora.edit_zp();


------------------------------------------------------------------------
-- Trigger: Lancement actualisation du champ sur t_apresence
------------------------------------------------------------------------

CREATE TRIGGER tri_change_meta_dates_ap
BEFORE INSERT OR UPDATE
ON pr_priority_flora.t_apresence
FOR EACH ROW
EXECUTE PROCEDURE fct_trg_meta_dates_change() ;


CREATE TRIGGER tri_insert_ap
BEFORE INSERT
ON pr_priority_flora.t_apresence
FOR EACH ROW
EXECUTE PROCEDURE pr_priority_flora.edit_ap();


CREATE TRIGGER tri_update_ap
BEFORE UPDATE
ON pr_priority_flora.t_apresence
FOR EACH ROW
WHEN (OLD.geom_4326 IS DISTINCT FROM NEW.geom_4326)
EXECUTE PROCEDURE pr_priority_flora.edit_ap();


-------------------------------------------
-- Vue: Création de la vue d'export des AP
-------------------------------------------

CREATE OR REPLACE VIEW pr_priority_flora.export_ap
AS
  SELECT DISTINCT
    ta.id_zp AS id_zp,
    t.nom_complet AS sciname,
    tz.cd_nom AS sciname_code,
    tz.date_min AS date_min,
    tz.date_max AS date_max,
    string_agg(DISTINCT (roles.prenom_role || ' ' || roles.nom_role || ' (' || bo.nom_organisme || ')'), ', ') AS observaters,
    tz.geom_local AS zp_geom_local,
    public.ST_AsGeoJSON(tz.geom_4326) AS zp_geojson,
    tz."area" AS zp_surface,

    ta.id_ap AS id_ap,
    string_agg(DISTINCT la.area_name, ', ') AS municipalities,
    ta.geom_local AS ap_geom_local,
    public.ST_AsGeoJSON(ta.geom_4326) AS ap_geojson,
    ta."area" AS ap_surface,
    ta.altitude_min AS altitude_min,
    ta.altitude_max AS altitude_max,
    ref_nomenclatures.get_nomenclature_label(ta.id_nomenclature_incline) AS incline,
    string_agg(DISTINCT tnphy.label_default, ', ') AS physiognomies,

    ref_nomenclatures.get_nomenclature_label(ta.id_nomenclature_habitat) AS habitat_state,
    ta.favorable_status_percent AS favorable_state_percentage,
    ref_nomenclatures.get_nomenclature_label(ta.id_nomenclature_threat_level) AS threat_level,
    string_agg(DISTINCT tnper.label_default, ', ') AS perturbations,

    ref_nomenclatures.get_nomenclature_label(ta.id_nomenclature_phenology) AS phenology,

    ref_nomenclatures.get_nomenclature_label(ta.id_nomenclature_frequency_method) AS frequency_method,
    ta.frequency AS frequency,

    ref_nomenclatures.get_nomenclature_label(ta.id_nomenclature_counting) AS counting_method,
    ta.total_min,
    ta.total_max,

    ta."comment" AS comment
  FROM pr_priority_flora.t_apresence AS ta
    LEFT JOIN pr_priority_flora.cor_ap_area AS cap
      ON cap.id_ap = ta.id_ap
    LEFT JOIN ref_geo.l_areas AS la
      ON la.id_area = cap.id_area
    LEFT JOIN pr_priority_flora.cor_zp_obs AS observer
      ON observer.id_zp = ta.id_zp
    LEFT JOIN utilisateurs.t_roles AS roles
      ON roles.id_role = observer.id_role
    LEFT JOIN utilisateurs.bib_organismes AS bo
      ON bo.id_organisme = roles.id_organisme
    LEFT JOIN pr_priority_flora.cor_ap_perturbation AS caper
      ON caper.id_ap = ta.id_ap
    LEFT JOIN ref_nomenclatures.t_nomenclatures AS tnper
      ON tnper.id_nomenclature = caper.id_nomenclature
    LEFT JOIN pr_priority_flora.cor_ap_physiognomy AS caphy
      ON caphy.id_ap = ta.id_ap
    LEFT JOIN ref_nomenclatures.t_nomenclatures AS tnphy
      ON tnphy.id_nomenclature = caphy.id_nomenclature
    LEFT JOIN pr_priority_flora.t_zprospect AS tz
      ON tz.id_zp = ta.id_zp
    LEFT JOIN taxonomie.taxref AS t
      ON t.cd_nom = tz.cd_nom
  WHERE la.id_type = ref_geo.get_id_area_type('COM'::character varying)
  GROUP BY ta.id_ap, ta.id_zp, t.nom_complet, tz.cd_nom, tz.geom_local, tz.geom_4326, tz."area", tz.date_min, tz.date_max ;
;


CREATE OR REPLACE FUNCTION pr_priority_flora.get_source_id()
    RETURNS INTEGER
    LANGUAGE plpgsql
    IMMUTABLE
AS
$function$
    -- Function that return the id of the Source (gn_synthese.t_sources) of this module.
    -- USAGE: SELECT pr_priority_flora.get_source_id();
    DECLARE
        sourceId INTEGER;
    BEGIN
        SELECT id_source INTO sourceId
        FROM gn_synthese.t_sources
        JOIN gn_commons.t_modules using(id_module)
        WHERE module_code = 'PRIORITY_FLORA'
        LIMIT 1 ;

        RETURN sourceId ;
    END;
$function$ ;
