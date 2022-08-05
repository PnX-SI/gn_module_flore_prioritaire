
------------------------------------------------------------------------
-- Nomenclature: Etat de l'habitat
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (mnemonique, label_default, definition_default, label_fr, definition_fr, source)
    VALUES ('ETAT_HABITAT', 'Type d''etat d''habitat', 'Nomenclature des types d''etats d''habitat', 'Type d''etat d''habitat', 'Nomenclature des type d''etats d''habitat', 'CBNA');

INSERT INTO ref_nomenclatures.t_nomenclatures (id_type, cd_nomenclature, mnemonique, label_default, definition_default, label_fr, definition_fr, id_broader, hierarchy) VALUES
    (ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'1','Favorable','Favorable','Etat de l''habitat favorable','Favorable','Etat de l''habitat favorable',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'.001')),
    (ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'2','Défavorable inadéquat','Défavorable inadéquat','Etat de l''habitat défavorable inadéquat','Défavorable inadéquat','Etat de l''habitat défavorable inadéquat',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'.002')),
    (ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'3','Défavorable','Défavorable','Etat de l''habitat défavorable','Défavorable','Etat de l''habitat défavorable',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'.003'))
;

------------------------------------------------------------------------
-- Nomenclature: Type de pente
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (mnemonique, label_default, definition_default, label_fr, definition_fr, source)
    VALUES ('TYPE_PENTE', 'Type de pente', 'Nomenclature des types de pentes', 'Type de pentes', 'Nomenclatures des types de pentes.', 'CBNA');

INSERT INTO ref_nomenclatures.t_nomenclatures (id_type, cd_nomenclature, mnemonique, label_default, definition_default, label_fr, definition_fr, id_broader, hierarchy) VALUES
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'2','7.5','Fauchable (5-10)','Pente : Fauchable (5-10)','Fauchable (5-10)','Pente : Fauchable (5-10)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.003')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'3','12.5','Haut d''un cône de déjection torrentiel (10-15)','Pente : Haut d''un cône de déjection torrentiel (10-15)','Haut d''un cône de déjection torrentiel (10-15)','Pente : Haut d''un cône de déjection torrentiel (10-15)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.004')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'4','17.5','Haut d''un cône d''avalanche (15-20)','Pente : Haut d''un cône d''avalanche (15-20)','Haut d''un cône d''avalanche (15-20)','Pente : Haut d''un cône d''avalanche (15-20)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.005')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'5','22.5','Pied d''éboulis (20-25)','Pente : Pied d''éboulis (20-25)','Pied d''éboulis (20-25)','Pente : Pied d''éboulis (20-25)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.006')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'6','30','Tablier d''éboulis (25-35)','Pente : Tablier d''éboulis (25-35)','Tablier d''éboulis (25-35)','Pente : Tablier d''éboulis (25-35)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.007')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'7','37.5','Sommet d''éboulis (35-40)','Pente : Sommet d''éboulis (35-40)','Sommet d''éboulis (35-40)','Pente : Sommet d''éboulis (35-40)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.008')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'8','45','Rochillon (sans les mains) (40-50)','Pente : Rochillon (sans les mains) (40-50)','Rochillon (sans les mains) (40-50)','Pente : Rochillon (sans les mains) (40-50)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.009')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'9','55','Rochillon (avec les mains) (50-60)','Pente : Rochillon (avec les mains) (50-60)','Rochillon (avec les mains) (50-60)','Pente : Rochillon (avec les mains) (50-60)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.010')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'10','90','Vires et barres (>60)','Pente : Vires et barres (>60)','Vires et barres (>60)','Pente : Vires et barres (>60)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.011')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'0','0','Plat (0)','Pente : Plat (0)','Plat (0)','Pente : Plat (0)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.001')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'1','2.5','Labourable (>0-5)','Pente : Labourable (>0-5)','Labourable (>0-5)','Pente : Labourable (>0-5)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.002'))
;

------------------------------------------------------------------------
-- Nomenclature: Type de phénologie
------------------------------------------------------------------------

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
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'8','Stade végétatif permanent ','Phénologie : Stade végétatif permanent ','Phénologie : Stade végétatif permanent ','Phénologie : Stade végétatif permanent ','Phénologie : Stade végétatif permanent ',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'.008'))
;

------------------------------------------------------------------------
-- Nomenclature: Type de comptage
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (mnemonique, label_default, definition_default, label_fr, definition_fr, source)
    VALUES ('TYPE_COMPTAGE', 'Type de comptage', 'Nomenclature des types de comptage des taxons présent dans une surface donnée.', 'Type de comptage', 'Nomenclature des types de comptage des taxons présent dans une surface donnée.', 'CBNA');

INSERT INTO ref_nomenclatures.t_nomenclatures (id_type, cd_nomenclature, mnemonique, label_default, definition_default, label_fr, definition_fr, id_broader, hierarchy) VALUES
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_COMPTAGE'),'1','Recensement exhaustif','Recensement exhaustif','Recensement exhaustif des taxons présent sur la surface.','Recensement exhaustif','Recensement exhaustif des taxons présent sur la surface.',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_COMPTAGE'),'.001')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_COMPTAGE'),'2','Échantillonage','Échantillonage','Échantillonage des taxons présent sur la surface.','Échantillonage','Échantillonage des taxons présent sur la surface.',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_COMPTAGE'),'.002')),
    (ref_nomenclatures.get_id_nomenclature_type('TYPE_COMPTAGE'),'9','Aucun comptage','Aucun comptage','Aucun comptage','Aucun comptage','Aucun comptage.',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_COMPTAGE'),'.003'))
;
