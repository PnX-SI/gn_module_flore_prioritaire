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
-- Functions: perturbations
------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pr_priority_flora.get_perturbations_ids(presenceAreaId BIGINT)
  RETURNS INT[]
  LANGUAGE plpgsql
  IMMUTABLE
AS
$function$
  -- Function that return an array of perturbations ids (t_nomenclatures.id_nomenclature)
  -- of a presence area.
  -- USAGE: SELECT pr_priority_flora.get_perturbations_ids(t_apresence.id_ap);
  DECLARE
    currentPerturbationsIds INT[];

  BEGIN
    -- Get current observers id in prospect zones linked observers table
    SELECT array_agg(cap.id_nomenclature) INTO currentPerturbationsIds
    FROM pr_priority_flora.cor_ap_perturbation AS cap
    WHERE cap.id_ap = presenceAreaId ;

    RETURN currentPerturbationsIds ;
  END;
$function$ ;


CREATE OR REPLACE FUNCTION pr_priority_flora.build_perturbations(
  presenceAreaId BIGINT,
  operation VARCHAR DEFAULT NULL,
  perturbationId INTEGER DEFAULT NULL
)
  RETURNS VARCHAR
  LANGUAGE plpgsql
  IMMUTABLE
AS
$function$
  -- Function that return the perturbations names of a presence area concatened
  -- into a string.
  -- USAGE:
  -- concat current perturbations :
  --      SELECT pr_priority_flora.build_perturbations(t_apresence.id_ap);
  -- concat current perturbations and delete one by id nomenclature :
  --      SELECT pr_priority_flora.build_perturbations(t_apresence.id_ap, 'DELETE', nomenclatures.id_nomenclature);
  -- concat current perturbations and add one by id nomenclature :
  --      SELECT pr_priority_flora.build_perturbations(t_apresence.id_ap, 'INSERT', nomenclatures.id_nomenclature);
  DECLARE
    currentPerturbationsIds INT[];
    perturbations VARCHAR;

  BEGIN
    -- Get current perturbations id in presence areas linked perturbations nomenclature table
    SELECT pr_priority_flora.get_perturbations_ids(presenceAreaId) INTO currentPerturbationsIds ;

    -- Remove or add perturbation who is processing from current perturbations id list
    IF (operation = 'DELETE') THEN
      SELECT ARRAY(
        SELECT unnest(currentPerturbationsIds)
        EXCEPT SELECT unnest(ARRAY[perturbationId]::INT[])
      ) INTO currentPerturbationsIds ;
    ELSIF (operation = 'INSERT') THEN
      SELECT currentPerturbationsIds || ARRAY[perturbationId]::INT[] INTO currentPerturbationsIds;
    END IF;

    -- Build perturbations string aggregation
    SELECT INTO perturbations
      array_to_string(array_agg( n.label_default ORDER BY n.hierarchy ASC), ', ')
    FROM ref_nomenclatures.t_nomenclatures AS n
    WHERE n.id_nomenclature = ANY(currentPerturbationsIds) ;

    RETURN perturbations ;
  END;
$function$ ;


------------------------------------------------------------------------
-- Triggers & functions: cor_ap_perturbation
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
        || '"}')::JSONB
      )
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
    -- Build perturbations concatened list
    SELECT INTO concatenedPerturbations pr_priority_flora.build_perturbations(OLD.id_ap, TG_OP, OLD.id_nomenclature) ;

    -- Update additional_data in prospect zone table
    UPDATE pr_priority_flora.t_apresence SET
      additional_data = (
        COALESCE(additional_data, '{}'::JSONB)
        || ('{"perturbations": "'
          || REGEXP_REPLACE(concatenedPerturbations, '"', '\"', 'g')
        || '"}')::JSONB
      )
    WHERE id_ap = OLD.id_ap ;

    RETURN NULL ; -- Result is ignored since this is an AFTER trigger
  END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;


CREATE TRIGGER tri_insert_presence_area_perturbation
  AFTER INSERT ON pr_priority_flora.cor_ap_perturbation
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.add_presence_area_perturbation() ;


CREATE TRIGGER tri_delete_presence_area_perturbation
  AFTER DELETE ON pr_priority_flora.cor_ap_perturbation
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.delete_presence_area_perturbation() ;


------------------------------------------------------------------------
-- Functions: physiognomies
------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pr_priority_flora.get_physiognomies_ids(presenceAreaId BIGINT)
  RETURNS INT[]
  LANGUAGE plpgsql
  IMMUTABLE
AS
$function$
  -- Function that return an array of physiognomies ids (t_nomenclatures.id_nomenclature)
  -- of a presence area.
  -- USAGE: SELECT pr_priority_flora.get_physiognomies_ids(t_apresence.id_ap);
  DECLARE
    currentPhysiognomiesIds INT[];

  BEGIN
    -- Get current observers id in prospect zones linked observers table
    SELECT array_agg(cap.id_nomenclature) INTO currentPhysiognomiesIds
    FROM pr_priority_flora.cor_ap_physiognomy AS cap
    WHERE cap.id_ap = presenceAreaId ;

    RETURN currentPhysiognomiesIds ;
  END;
$function$ ;


CREATE OR REPLACE FUNCTION pr_priority_flora.build_physiognomies(
  presenceAreaId BIGINT,
  operation VARCHAR DEFAULT NULL,
  physiognomyId INTEGER DEFAULT NULL
)
  RETURNS VARCHAR
  LANGUAGE plpgsql
  IMMUTABLE
AS
$function$
  -- Function that return the physiognomies names of a presence area concatened
  -- into a string.
  -- USAGE:
  -- concat current physiognomies :
  --      SELECT pr_priority_flora.build_physiognomies(t_apresence.id_ap);
  -- concat current physiognomies and delete one by id nomenclature :
  --      SELECT pr_priority_flora.build_physiognomies(t_apresence.id_ap, 'DELETE', nomenclatures.id_nomenclature);
  -- concat current physiognomies and add one by id nomenclature :
  --      SELECT pr_priority_flora.build_physiognomies(t_apresence.id_ap, 'INSERT', nomenclatures.id_nomenclature);
  DECLARE
    currentPhysiognomiesIds INT[];
    physiognomies VARCHAR;

  BEGIN
    -- Get current physiognomies id in presence areas linked physiognomies nomenclature table
    SELECT pr_priority_flora.get_physiognomies_ids(presenceAreaId) INTO currentPhysiognomiesIds ;

    -- Remove or add physiognomies who is processing from current physiognomies id list
    IF (operation = 'DELETE') THEN
      SELECT ARRAY(
        SELECT unnest(currentPhysiognomiesIds)
        EXCEPT SELECT unnest(ARRAY[physiognomyId]::INT[])
      ) INTO currentPhysiognomiesIds ;
    ELSIF (operation = 'INSERT') THEN
      SELECT currentPhysiognomiesIds || ARRAY[physiognomyId]::INT[] INTO currentPhysiognomiesIds;
    END IF;

    -- Build physiognomies string aggregation
    SELECT INTO physiognomies
      array_to_string(array_agg( n.label_default ORDER BY n.hierarchy ASC), ', ')
    FROM ref_nomenclatures.t_nomenclatures AS n
    WHERE n.id_nomenclature = ANY(currentPhysiognomiesIds) ;

    RETURN physiognomies ;
  END;
$function$ ;


------------------------------------------------------------------------
-- Triggers & functions: cor_ap_physiognomy
------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pr_priority_flora.add_presence_area_physiognomy()
RETURNS trigger AS
$BODY$
  DECLARE
    concatenedPhysiognomies VARCHAR;
  BEGIN
    -- Build physiognomies concatened list
    SELECT INTO concatenedPhysiognomies pr_priority_flora.build_physiognomies(NEW.id_ap, TG_OP, NEW.id_nomenclature) ;

    -- Update additional_data in presence area table
    UPDATE pr_priority_flora.t_apresence SET
      additional_data = (
        COALESCE(additional_data, '{}'::JSONB)
        || ('{"physiognomies": "'
          || REGEXP_REPLACE(concatenedPhysiognomies, '"', '\"', 'g')
        || '"}')::JSONB
      )
    WHERE id_ap = NEW.id_ap ;

    RETURN NULL;  -- Result is ignored since this is an AFTER trigger
  END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;


CREATE OR REPLACE FUNCTION pr_priority_flora.delete_presence_area_physiognomy()
RETURNS trigger AS
$BODY$
  DECLARE
    concatenedPhysiognomies VARCHAR;
  BEGIN
    -- Build physiognomies concatened list
    SELECT INTO concatenedPhysiognomies pr_priority_flora.build_physiognomies(OLD.id_ap, TG_OP, OLD.id_nomenclature) ;

    -- Update additional_data in prospect zone table
    UPDATE pr_priority_flora.t_apresence SET
      additional_data = (
        COALESCE(additional_data, '{}'::JSONB)
        || ('{"physiognomies": "'
          || REGEXP_REPLACE(concatenedPhysiognomies, '"', '\"', 'g')
        || '"}')::JSONB
      )
    WHERE id_ap = OLD.id_ap ;

    RETURN NULL ; -- Result is ignored since this is an AFTER trigger
  END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;


CREATE TRIGGER tri_insert_presence_area_physiognomy
  AFTER INSERT ON pr_priority_flora.cor_ap_physiognomy
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.add_presence_area_physiognomy() ;


CREATE TRIGGER tri_delete_presence_area_physiognomy
  AFTER DELETE ON pr_priority_flora.cor_ap_physiognomy
  FOR EACH ROW
  EXECUTE PROCEDURE pr_priority_flora.delete_presence_area_physiognomy() ;


------------------------------------------------------------------------
-- Triggers: t_apresence history
------------------------------------------------------------------------
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
    row_to_json(OLD)::JSONB - 'meta_update_date'
    IS DISTINCT FROM
    row_to_json(NEW)::JSONB - 'meta_update_date'
	)
  EXECUTE PROCEDURE gn_commons.fct_trg_log_changes();


------------------------------------------------------------------------
-- Triggers & functions: cor_zp_obs
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
        || '"}')::JSONB
      )
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
        || '"}')::JSONB
      )
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


------------------------------------------------------------------------
-- Triggers: t_zprospect history
------------------------------------------------------------------------
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
    row_to_json(OLD)::JSONB - 'meta_update_date'
    IS DISTINCT FROM
    row_to_json(NEW)::JSONB - 'meta_update_date'
	)
  EXECUTE PROCEDURE gn_commons.fct_trg_log_changes();


------------------------------------------------------------------------------------
-- Trigger: update t_validations after insert new presence area
------------------------------------------------------------------------------------

CREATE TRIGGER tri_insert_default_validation_status
  AFTER INSERT
  ON pr_priority_flora.t_apresence
  FOR EACH ROW
  EXECUTE PROCEDURE gn_commons.fct_trg_add_default_validation_status();
