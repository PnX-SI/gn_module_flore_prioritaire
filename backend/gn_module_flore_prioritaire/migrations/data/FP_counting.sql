INSERT INTO ref_nomenclatures.bib_nomenclatures_types (mnemonique, label_default, definition_default, label_fr, definition_fr, source)
    VALUES ('FLORE_PATRI_METHODO_DENOM', 'Méthodologie de comptage', 'Méthodologie de comptage', 'Méthodologie de comptage', 'Méthodologie de comptage', 'CBNA');

INSERT INTO ref_nomenclatures.t_nomenclatures (id_type, cd_nomenclature, mnemonique, label_default, definition_default, label_fr, definition_fr, id_broader, hierarchy) VALUES                    
 (ref_nomenclatures.get_id_nomenclature_type('FLORE_PATRI_METHODO_DENOM'),'1','Recensement exhaustif','Recensement exhaustif','Recensement exhaustif','Recensement exhaustif','Recensement exhaustif',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('FLORE_PATRI_METHODO_DENOM'),'.001')),
 (ref_nomenclatures.get_id_nomenclature_type('FLORE_PATRI_METHODO_DENOM'),'2','Echantillonage','Echantillonage','Echantillonage','Echantillonage','Echantillonage',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('FLORE_PATRI_METHODO_DENOM'),'.002')),
 (ref_nomenclatures.get_id_nomenclature_type('FLORE_PATRI_METHODO_DENOM'),'9','Aucun comptage','Aucun comptage','Aucun comptage','Aucun comptage','Aucun comptage',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('FLORE_PATRI_METHODO_DENOM'),'.003'))
 ;
 