INSERT INTO ref_nomenclatures.bib_nomenclatures_types (mnemonique, label_default, definition_default, label_fr, definition_fr, source)
    VALUES ('TYPE_PHENOLOGIE', 'Type de phénologie', 'Nomenclature des types de phénologies', 'Type de phénologies', 'Nomenclatures des types de phénologies.', 'CBNA');

INSERT INTO ref_nomenclatures.t_nomenclatures (id_type, cd_nomenclature, mnemonique, label_default, definition_default, label_fr, definition_fr, id_broader, hierarchy) VALUES                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
 (ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'1','Stade végétatif','Phénologie : Stade végétatif','Phénologie : Stade végétatif','Phénologie : Stade végétatif','Phénologie : Stade végétatif',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'.001')),
 (ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'2','Stade boutons floraux','Phénologie : Stade boutons floraux','Phénologie : Stade boutons floraux','Phénologie : Stade boutons floraux','Phénologie : Stade boutons floraux',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'.002')),
 (ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'3','Début de floraison','Phénologie : Début de floraison','Phénologie : Début de floraison','Phénologie : Début de floraison','Phénologie : Début de floraison',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'.003')),
 (ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'4','Pleine floraison','Phénologie : Pleine floraison','Phénologie : Pleine floraison','Phénologie : Pleine floraison','Phénologie : Pleine floraison',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'.004')),
 (ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'5','Fin de floraison et maturation des fruits','Phénologie : Fin de floraison et maturation des fruits','Phénologie : Fin de floraison et maturation des fruits','Phénologie : Fin de floraison et maturation des fruits','Phénologie : Fin de floraison et maturation des fruits',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'.005')),
 (ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'6','Dissémination','Phénologie : Dissémination','Phénologie : Dissémination','Phénologie : Dissémination','Phénologie : Dissémination',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'.006')),
 (ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'7','Stade de décrépitude','Phénologie : Stade de décrépitude','Phénologie : Stade de décrépitude','Phénologie : Stade de décrépitude','Phénologie : Stade de décrépitude',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'.007')),
 (ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'8','Stade végétatif permanent ','Phénologie : Stade végétatif permanent ','Phénologie : Stade végétatif permanent ','Phénologie : Stade végétatif permanent ','Phénologie : Stade végétatif permanent ',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'.008'));