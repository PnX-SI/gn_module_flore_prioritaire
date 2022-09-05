----------------------------------------------------------------------------------------------------
-- Add t_zprospect and t_apresence in bib_tables_location
----------------------------------------------------------------------------------------------------

INSERT INTO gn_commons.bib_tables_location (
    table_desc,
    "schema_name",
    table_name,
    pk_field,
    uuid_field_name
) VALUES (
    'Table centralisant les zones de prospection',
    'pr_priority_flora',
    't_zprospect',
    'id_zp',
    'uuid_zp'
);

INSERT INTO gn_commons.bib_tables_location (
    table_desc,
    "schema_name",
    table_name,
    pk_field,
    uuid_field_name
) VALUES (
    'Table centralisant les aires de présence',
    'pr_priority_flora',
    't_apresence',
    'id_ap',
    'uuid_ap'
);


------------------------------------------------------------------------
-- Trigger: t_apresence history
------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pr_priority_flora.add_presence_area_perturbation()
RETURNS trigger AS
$BODY$
    DECLARE
        concatenedPerturbations VARCHAR;
    BEGIN
        -- Build perturbations concatened list
        SELECT INTO concatenedPerturbations pr_priority_flora.build_perturbations(NEW.id_ap, TG_OP, NEW.id_nomenclature) ;

        -- Update additional_data in presence area table
        UPDATE pr_priority_flora.t_apresence SET
            additional_data = (
              COALESCE(additional_data, '{}'::JSONB)
              || ('{"perturbations": "'
                || REGEXP_REPLACE(concatenedPerturbations, '"', '\"', 'g')
              || '"}')::JSONB)
        WHERE id_ap = NEW.id_ap ;

        RETURN NULL;  -- Result is ignored since this is an AFTER trigger
    END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;


CREATE OR REPLACE FUNCTION pr_priority_flora.delete_presence_area_perturbation()
RETURNS trigger AS
$BODY$
    DECLARE
        concatenedPerturbations VARCHAR;
    BEGIN
        -- Build observers concatened list
        SELECT INTO concatenedPerturbations pr_priority_flora.build_perturbations(OLD.id_ap, TG_OP, OLD.id_nomenclature) ;

        -- Update additional_data in prospect zone table
        UPDATE pr_priority_flora.t_apresence SET
            additional_data = (
              COALESCE(additional_data, '{}'::JSONB)
              || ('{"perturbations": "'
                || REGEXP_REPLACE(concatenedPerturbations, '"', '\"', 'g')
              || '"}')::JSONB)
        WHERE id_ap = OLD.id_ap ;

        RETURN NULL ; -- Result is ignored since this is an AFTER trigger
    END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;


CREATE TRIGGER tri_insert_presence_area_perturbation
  AFTER INSERT ON pr_priority_flora.cor_ap_perturb
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.add_presence_area_perturbation() ;


CREATE TRIGGER tri_delete_presence_area_perturbation
  AFTER DELETE ON pr_priority_flora.cor_ap_perturb
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.delete_presence_area_perturbation() ;


CREATE TRIGGER tri_log_insert_delete_t_apresence
  AFTER INSERT OR DELETE
  ON pr_priority_flora.t_apresence
  FOR EACH ROW
  EXECUTE PROCEDURE gn_commons.fct_trg_log_changes();


CREATE TRIGGER tri_log_update_t_apresence
  AFTER UPDATE
  ON pr_priority_flora.t_apresence
  FOR EACH ROW
  WHEN (
    OLD.uuid_ap IS DISTINCT FROM NEW.uuid_ap
    OR OLD.id_zp IS DISTINCT FROM NEW.id_zp
    OR OLD.id_nomenclature_counting IS DISTINCT FROM NEW.id_nomenclature_counting
    OR OLD.id_nomenclature_phenology IS DISTINCT FROM NEW.id_nomenclature_phenology
    OR OLD.altitude_min IS DISTINCT FROM NEW.altitude_min
    OR OLD.altitude_max IS DISTINCT FROM NEW.altitude_max
    OR OLD.total_min IS DISTINCT FROM NEW.total_min
    OR OLD.total_max IS DISTINCT FROM NEW.total_max
    OR OLD."comment" IS DISTINCT FROM NEW."comment"
    OR OLD.additional_data IS DISTINCT FROM NEW.additional_data
    OR OLD.geom_4326 IS DISTINCT FROM NEW.geom_4326
    OR OLD.geom_local IS DISTINCT FROM NEW.geom_local
    OR OLD.geom_point_4326 IS DISTINCT FROM NEW.geom_point_4326
	)
  EXECUTE PROCEDURE gn_commons.fct_trg_log_changes();


------------------------------------------------------------------------
-- Trigger & functions : t_zprospect history
------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION pr_priority_flora.add_prospect_zone_observers()
RETURNS trigger AS
$BODY$
    DECLARE
        concatenedObservers VARCHAR;
    BEGIN
        -- Build observers concatened list
        SELECT INTO concatenedObservers pr_priority_flora.build_observers(NEW.id_zp, TG_OP, NEW.id_role) ;

        -- Update additional_data in prospect zone table
        UPDATE pr_priority_flora.t_zprospect SET
            additional_data = (
              COALESCE(additional_data, '{}'::JSONB)
              || ('{"observers": "'
                || REGEXP_REPLACE(concatenedObservers, '"', '\"', 'g')
              || '"}')::JSONB)
        WHERE id_zp = NEW.id_zp ;

        RETURN NULL;  -- Result is ignored since this is an AFTER trigger
    END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;


CREATE OR REPLACE FUNCTION pr_priority_flora.delete_prospect_zone_observers()
RETURNS trigger AS
$BODY$
    DECLARE
        concatenedObservers VARCHAR;
    BEGIN
        -- Build observers concatened list
        SELECT INTO concatenedObservers pr_priority_flora.build_observers(OLD.id_zp, TG_OP, OLD.id_role) ;

        -- Update additional_data in prospect zone table
        UPDATE pr_priority_flora.t_zprospect SET
            additional_data = (
              COALESCE(additional_data, '{}'::JSONB)
              || ('{"observers": "'
                || REGEXP_REPLACE(concatenedObservers, '"', '\"', 'g')
              || '"}')::JSONB)
        WHERE id_zp = OLD.id_zp ;

        RETURN NULL ; -- Result is ignored since this is an AFTER trigger
    END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;


CREATE TRIGGER tri_insert_prospect_zone_observer
  AFTER INSERT ON pr_priority_flora.cor_zp_obs
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.add_prospect_zone_observers() ;


CREATE TRIGGER tri_delete_prospect_zone_observer
  AFTER DELETE ON pr_priority_flora.cor_zp_obs
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.delete_prospect_zone_observers() ;


CREATE TRIGGER tri_log_insert_delete_t_zprospect
  AFTER INSERT OR DELETE
  ON pr_priority_flora.t_zprospect
  FOR EACH ROW
  EXECUTE PROCEDURE gn_commons.fct_trg_log_changes();


CREATE TRIGGER tri_log_update_t_zprospect
  AFTER UPDATE
  ON pr_priority_flora.t_zprospect
  FOR EACH ROW
  WHEN (
    OLD.uuid_zp IS DISTINCT FROM NEW.uuid_zp
    OR OLD.cd_nom IS DISTINCT FROM NEW.cd_nom
    OR OLD.date_min IS DISTINCT FROM NEW.date_min
    OR OLD.date_max IS DISTINCT FROM NEW.date_max
    OR OLD.additional_data IS DISTINCT FROM NEW.additional_data
    OR OLD.geom_local IS DISTINCT FROM NEW.geom_local
    OR OLD.geom_4326 IS DISTINCT FROM NEW.geom_4326
    OR OLD.geom_point_4326 IS DISTINCT FROM NEW.geom_point_4326
  )
  EXECUTE PROCEDURE gn_commons.fct_trg_log_changes();


------------------------------------------------------------------------------------
-- Trigger: update t_validations after insert new prospect zone
------------------------------------------------------------------------------------

CREATE TRIGGER tri_insert_default_validation_status
  AFTER INSERT
  ON pr_priority_flora.t_zprospect
  FOR EACH ROW
  EXECUTE PROCEDURE gn_commons.fct_trg_add_default_validation_status();
