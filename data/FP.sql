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

------------------------------------------------------------------------
-- Nomenclature: Etat de l'habitat
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (mnemonique, label_default, definition_default, label_fr, definition_fr, source)
    VALUES ('ETAT_HABITAT', 'Type d''etat d''habitat', 'Nomenclature des type d''etats d''habitat', 'Type d''etat d''habitat', 'Nomenclature des type d''etats d''habitat', 'CBNA');

INSERT INTO ref_nomenclatures.t_nomenclatures (id_type, cd_nomenclature, mnemonique, label_default, definition_default, label_fr, definition_fr, id_broader, hierarchy) VALUES                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
 (ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'1','Favorable','Favorable','Etat de l''habitat favorable','Favorable','Etat de l''habitat favorable',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'.001')),
 (ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'2','Défavorable inadéquat','Défavorable inadéquat','Etat de l''habitat défavorable inadéquat','Défavorable inadéquat','Etat de l''habitat défavorable inadéquat',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'.002')),
 (ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'3','Défavorable','Défavorable','Etat de l''habitat défavorable','Défavorable','Etat de l''habitat défavorable',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('ETAT_HABITAT'),'.003')),

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
 (ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'1','2.5','Labourable (>0-5)','Pente : Labourable (>0-5)','Labourable (>0-5)','Pente : Labourable (>0-5)',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PENTE'),'.002'));

------------------------------------------------------------------------
-- Nomenclature: Type de perturbation
------------------------------------------------------------------------

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (mnemonique, label_default, definition_default, label_fr, definition_fr, source)
    VALUES ('TYPE_PERTURBATION', 'Type de perturbations', 'Nomenclature des types de perturbations.', 'Type de perturbations', 'Nomenclatures des types de perturbations.', 'CBNA');

INSERT INTO ref_nomenclatures.t_nomenclatures (id_type, cd_nomenclature, mnemonique, label_default, definition_default, label_fr, definition_fr, id_broader, hierarchy) VALUES 
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'GeF', 'Gestion par le feu', 'Gestion par le feu', 'Type de perturbation: Gestion par le feu', 'Gestion par le feu', 'Type de perturbation: Gestion par le feu', 0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.001')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Bru', 'Brûlage contrôlé', 'Brûlage contrôlé', 'Gestion par le feu: Brûlage contrôlé', 'Brûlage contrôlé', 'Gestion par le feu: Brûlage contrôlé', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeF') , CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeF'),'.001')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Inc', 'Incendie', 'Incendie (naturel ou incontrôlé)', 'Gestion par le feu: Incendie (naturel ou incontrôlé)', 'Incendie (naturel ou incontrôlé)', 'Gestion par le feu: Incendie (naturel ou incontrôlé)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeF') , CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeF'),'.002')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'AcL', 'Activité de loisirs', 'Activité de loisirs', 'Type de perturbation: Activité de loisirs', 'Activité de loisirs', 'Type de perturbation: Activité de loisirs', 0, CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.002')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Rec', 'Récolte des fleurs', 'Récolte des fleurs', 'Activité de loisirs: Récolte des fleurs', 'Récolte des fleurs', 'Activité de loisirs: Récolte des fleurs', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcL') , CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcL'),'.001')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Arr', 'Arrachage des pieds', 'Arrachage des pieds', 'Activité de loisirs: Arrachage des pieds', 'Arrachage des pieds', 'Activité de loisirs: Arrachage des pieds', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcL') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcL'),'.002')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Pie', 'Piétinement pédestre', 'Piétinement pédestre', 'Activité de loisirs: Piétinement pédestre', 'Piétinement pédestre', 'Activité de loisirs: Piétinement pédestre', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcL') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcL'),'.003')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Veh', 'Véhicules à moteur', 'Véhicules à moteur', 'Activité de loisirs: Véhicules à moteur', 'Véhicules à moteur', 'Activité de loisirs: Véhicules à moteur', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcL') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcL'),'.004')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Plo', 'Plongée dans un lac', 'Plongée dans un lac', 'Activité de loisirs: Plongée dans un lac', 'Plongée dans un lac', 'Activité de loisirs: Plongée dans un lac', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcL') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcL'),'.005')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'GeE', 'Gestion de l''eau', 'Gestion de l''eau', 'Type de perturbation: Gestion de l''eau', 'Gestion de l''eau', 'Type de perturbation: Gestion de l''eau', 0, CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.003')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Pom', 'Pompage', 'Pompage', 'Gestion de l''eau: Pompage', 'Pompage', 'Gestion de l''eau: Pompage', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE'),'.001')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Drn', 'Drainage', 'Drainage', 'Gestion de l''eau: Drainage', 'Drainage', 'Gestion de l''eau: Drainage', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE'),'.002')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Irg', 'Irrigation par gravité', 'Irrigation par gravité', 'Gestion de l''eau: Irrigation par gravité', 'Irrigation par gravité', 'Gestion de l''eau: Irrigation par gravité', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE'),'.003')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Ira', 'Irrigation par aspersion', 'Irrigation par aspersion', 'Gestion de l''eau: Irrigation par aspersion', 'Irrigation par aspersion', 'Gestion de l''eau: Irrigation par aspersion', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE'),'.004')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Cur', 'Curage', 'Curage', 'Gestion de l''eau: Curage (fossé, mare, serve)', 'Curage', 'Gestion de l''eau: Curage (fossé, mare, serve)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE'),'.005')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Ext', 'Extraction de granulats', 'Extraction de granulats', 'Gestion de l''eau: Extraction de granulats', 'Extraction de granulats', 'Gestion de l''eau: Extraction de granulats', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeE'),'.006')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'AcA', 'Activités agricoles', 'Activités agricoles', 'Type de perturbation: Activités agricoles', 'Activités agricoles', 'Type de perturbation: Activités agricoles', 0, CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.004')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Lab', 'Labour', 'Labour', 'Activités agricoles: Labour', 'Labour', 'Activités agricoles: Labour',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA'),'.001')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Fer', 'Fertilisation', 'Fertilisation', 'Activités agricoles: Fertilisation', 'Fertilisation', 'Activités agricoles: Fertilisation', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA'),'.002')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Prp', 'Produits phyosanitaires', 'Produits phyosanitaires', 'Activités agricoles: Produits phyosanitaires (épandage)', 'Produits phyosanitaires', 'Activités agricoles: Produits phyosanitaires (épandage)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA'),'.003')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Fauc', 'Fauchaison', 'Fauchaison', 'Activités agricoles: Fauchaison', 'Fauchaison', 'Activités agricoles: Fauchaison', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA'),'.004')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Apb', 'Apport de blocs', 'Apport de blocs', 'Activités agricoles: Apport de blocs (déterrés par le labour)', 'Apport de blocs', 'Activités agricoles: Apport de blocs (déterrés par le labour)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA'),'.005')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Gyr', 'Gyrobroyage', 'Gyrobroyage', 'Activités agricoles: Gyrobroyage', 'Gyrobroyage', 'Activités agricoles: Gyrobroyage', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA'),'.006')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Reg', 'Revégétalisation', 'Revégétalisation', 'Activités agricoles: Revégétalisation (sur semis)', 'Revégétalisation', 'Activités agricoles: Revégétalisation (sur semis)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcA'),'.007')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'AcF', 'Activités forestières', 'Activités forestières', 'Type de perturbation: Activités forestières', 'Activités forestières', 'Type de perturbation: Activités forestières', 0, CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.005')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Jpf', 'Jeune plantation de feuillus', 'Jeune plantation de feuillus', 'Activités forestières: Jeune plantation de feuillus', 'Jeune plantation de feuillus', 'Activités forestières: Jeune plantation de feuillus', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF'),'.001')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Jpm', 'Jeune plantation mixte', 'Jeune plantation mixte', 'Activités forestières: Jeune plantation mixte', 'Jeune plantation mixte', 'Activités forestières: Jeune plantation mixte', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF'),'.002')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Jpr', 'Jeune plantation de résineux', 'Jeune plantation de résineux', 'Activités forestières: Jeune plantation de résineux', 'Jeune plantation de résineux', 'Activités forestières: Jeune plantation de résineux', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF'),'.003')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Ela', 'Elagage', 'Elagage', 'Activités forestières: Elagage (haie et bord de route)', 'Elagage', 'Activités forestières: Elagage (haie et bord de route)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF'),'.004')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Cec', 'Coupe d''éclaircie', 'Coupe d''éclaircie', 'Activités forestières: Coupe d''éclaircie', 'Coupe d''éclaircie', 'Activités forestières: Coupe d''éclaircie', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF'),'.005')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Cbl', 'Coupe à blanc', 'Coupe à blanc', 'Activités forestières: Coupe à blanc', 'Coupe à blanc', 'Activités forestières: Coupe à blanc', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF'),'.006')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Bcl', 'Bois coupé et laissé', 'Bois coupé et laissé', 'Activités forestières: Bois coupé et laissé sur place', 'Bois coupé et laissé', 'Activités forestières: Bois coupé et laissé sur place', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF'),'.007')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Opf', 'Ouverture de piste forestière', 'Ouverture de piste forestière', 'Activités forestières: Ouverture de piste forestière', 'Ouverture de piste forestière', 'Activités forestières: Ouverture de piste forestière', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AcF'),'.008')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'CpA', 'Comportement des animaux', 'Comportement des animaux', 'Type de perturbation: Comportement des animaux', 'Comportement des animaux', 'Type de perturbation: Comportement des animaux', 0, CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.006')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Jas', 'Jas', 'Jas', 'Comportement des animaux: Jas (couchades nocturnes des animaux domestiques)', 'Jas', 'Comportement des animaux: Jas (couchades nocturnes des animaux domestiques)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA'),'.001')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Cha', 'Chaume', 'Chaume', 'Comportement des animaux: Chaume (couchades aux heures chaudes des animaux domestiques)', 'Chaume', 'Comportement des animaux: Chaume (couchades aux heures chaudes des animaux domestiques)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA'),'.002')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Faus', 'Faune sauvage', 'Faune sauvage', 'Comportement des animaux: Faune sauvage (reposoir)', 'Faune sauvage', 'Comportement des animaux: Faune sauvage (reposoir)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA'),'.003')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Psa', 'Piétinement sans déjection', 'Piétinement sans déjection', 'Comportement des animaux: Piétinement, sans apports de déjection', 'Piétinement sans déjection', 'Comportement des animaux: Piétinement, sans apports de déjection', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA'),'.004')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Pat', 'Pâturage', 'Pâturage', 'Comportement des animaux: Pâturage (sur herbacées exclusivement)', 'Pâturage', 'Comportement des animaux: Pâturage (sur herbacées exclusivement)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA'),'.005')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Acl', 'Abroutissement et écorçage ', 'Abroutissement et écorçage ', 'Comportement des animaux: Abroutissement et écorçage (sur ligneux)', 'Abroutissement et écorçage ', 'Comportement des animaux: Abroutissement et écorçage (sur ligneux)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA'),'.006')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'San', 'Sangliers labours grattis', 'Sangliers labours grattis', 'Comportement des animaux: Sangliers-labours et grattis', 'Sangliers labours grattis', 'Comportement des animaux: Sangliers-labours et grattis', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA'),'.007')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Mar', 'Marmottes terriers', 'Marmottes terriers', 'Comportement des animaux: Marmottes-terriers', 'Marmottes terriers', 'Comportement des animaux: Marmottes-terriers', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA'),'.008')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Che', 'Chenilles défoliation', 'Chenilles défoliation', 'Comportement des animaux: Chenilles-défoliation', 'Chenilles défoliation', 'Comportement des animaux: Chenilles-défoliation', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'CpA'),'.009')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'PnE', 'Processus naturels d''érosion', 'Processus naturels d''érosion', 'Type de perturbation: Processus naturels d''érosion', 'Processus naturels d''érosion', 'Type de perturbation: Processus naturels d''érosion', 0, CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.007')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Sub', 'Submersion temporaire', 'Submersion temporaire', 'Processus naturels d''érosion: Submersion temporaire', 'Submersion temporaire', 'Processus naturels d''érosion: Submersion temporaire', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE'),'.001')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Env', 'Envasement', 'Envasement', 'Processus naturels d''érosion: Envasement', 'Envasement', 'Processus naturels d''érosion: Envasement', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE'),'.002')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Eng', 'Engravement', 'Engravement', 'Processus naturels d''érosion: Engravement (laves torrentielles et divagation d''une rivière)', 'Engravement', 'Processus naturels d''érosion: Engravement (laves torrentielles et divagation d''une rivière)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE'),'.003')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Aam', 'Avalanche apport matériaux', 'Avalanche apport matériaux', 'Processus naturels d''érosion: Avalanche (apport de matériaux non triés)', 'Avalanche', 'Processus naturels d''érosion: Avalanche (apport de matériaux non triés)', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE'),'.004')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Evs', 'Erosion vastes surfaces', 'Erosion vastes surfaces', 'Processus naturels d''érosion:Erosion s''exerçant sur de vastes surfaces', 'Erosion vastes surfaces', 'Processus naturels d''érosion:Erosion s''exerçant sur de vastes surfaces', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE'),'.005')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Sbe', 'Sapement berge', 'Sapement berge', 'Processus naturels d''érosion: Sapement de la berge d''un cours d''eau', 'Sapement berge', 'Processus naturels d''érosion: Sapement de la berge d''un cours d''eau', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE'),'.006')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Art', 'Avalanche ramonage terrain', 'Avalanche ramonage terrain', 'Processus naturels d''érosion: Avalanche-ramonage du terrain', 'Avalanche ramonage terrain', 'Processus naturels d''érosion: Avalanche-ramonage du terrain', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE'),'.007')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Ebr', 'Eboulement récent', 'Eboulement récent', 'Processus naturels d''érosion: Eboulement récent', 'Eboulement récent', 'Processus naturels d''érosion: Eboulement récent', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'PnE'),'.008')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'AmL', 'Aménagements lourds', 'Aménagements lourds', 'Type de perturbation: Aménagements lourds', 'Aménagements lourds', 'Type de perturbation: Aménagements lourds', 0, CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.008')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Car', 'Carrière en roche dure', 'Carrière en roche dure', 'Aménagements lourds: Carrière en roche dure', 'Carrière en roche dure', 'Aménagements lourds: Carrière en roche dure', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL'),'.001')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Fos', 'Fossé pare-blocs', 'Fossé pare-blocs', 'Aménagements lourds: Fossé pare-blocs', 'Fossé pare-blocs', 'Aménagements lourds: Fossé pare-blocs', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL'),'.002')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'End', 'Endiguement', 'Endiguement', 'Aménagements lourds: Endiguement', 'Endiguement', 'Aménagements lourds: Endiguement', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL'),'.003')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Ter', 'Terrassement aménagements lourds', 'Terrassement aménagements lourds', 'Aménagements lourds: Terrassement pour aménagements lourds', 'Terrassement aménagements lourds', 'Aménagements lourds: Terrassement pour aménagements lourds', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL'),'.004')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Deb', 'Déboisement avec désouchage', 'Déboisement avec désouchage', 'Aménagements lourds: Déboisement avec désouchage', 'Déboisement avec désouchage', 'Aménagements lourds: Déboisement avec désouchage', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL'),'.005')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Beg', 'Béton-goudron:revêtement', 'Béton-goudron:revêtement', 'Aménagements lourds: Béton, goudron-revêtement abiotique', 'Béton-goudron:revêtement', 'Aménagements lourds: Béton, goudron-revêtement abiotique', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'AmL'),'.006')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'GeI', 'Gestion des invasives', 'Gestion des invasives', 'Type de perturbation: Gestion des invasives', 'Gestion des invasives', 'Type de perturbation: Gestion des invasives', 0, CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.009')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Arg', 'Arrachage', 'Arrachage', 'Gestion des invasives: Arrachage', 'Arrachage', 'Gestion des invasives: Arrachage', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeI') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeI'),'.001')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Fag', 'Fauchage', 'Fauchage', 'Gestion des invasives: Fauchage', 'Fauchage', 'Gestion des invasives: Fauchage', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeI') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeI'),'.002')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Dbs', 'Débroussaillage', 'Débroussaillage', 'Gestion des invasives: Débroussaillage', 'Débroussaillage', 'Gestion des invasives: Débroussaillage', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeI') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeI'),'.003')),
(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'), 'Reb', 'Recouvrement avec bâches', 'Recouvrement avec bâches', 'Gestion des invasives: Recouvrement avec bâches', 'Recouvrement avec bâches', 'Gestion des invasives:Recouvrement avec bâches', ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeI') ,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PERTURBATION'),'.',ref_nomenclatures.get_id_nomenclature('TYPE_PERTURBATION', 'GeI'),'.004'));

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
 (ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'8','Stade végétatif permanent ','Phénologie : Stade végétatif permanent ','Phénologie : Stade végétatif permanent ','Phénologie : Stade végétatif permanent ','Phénologie : Stade végétatif permanent ',0,CONCAT(ref_nomenclatures.get_id_nomenclature_type('TYPE_PHENOLOGIE'),'.008'));

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
	geom_local                                        geometry(Geometry,2154),
	geom_4326                                         geometry(Geometry,4326),
	geom_point_4326                                   geometry(Point,4326),
	
  CONSTRAINT pk_t_apresence PRIMARY KEY (indexap),
	CONSTRAINT fk_t_apresence_t_zprospect FOREIGN KEY (indexzp) REFERENCES pr_priority_flora.t_zprospect(indexzp) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_pente FOREIGN KEY (id_nomenclatures_pente) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_counting FOREIGN KEY (id_nomenclatures_counting) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_habitat FOREIGN KEY (id_nomenclatures_habitat) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_t_apresence_t_nomenclatures_id_phenology FOREIGN KEY (id_nomenclatures_phenology) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT fk_t_apresence_t_history_actions FOREIGN KEY (id_history_action) REFERENCES gn_commons.t_history_actions(id_history_action) ON UPDATE CASCADE ON DELETE NO ACTION,
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
	indexap   INT  NOT NULL,
	
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
	indexap           INT  NOT NULL,
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

	DELETE FROM pr_priority_flora.cor_ap_area WHERE indexzp = NEW.indexap;
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

		new.geom_local = st_transform(new.geom_4326,2154);
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

------------------------------------
-- Vue: Création de la vue d'export
------------------------------------

DROP VIEW pr_priority_flora.export_ap;

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
				



