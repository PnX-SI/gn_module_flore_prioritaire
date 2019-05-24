--------------
-- DATA -----
--------------

-- Création de la liste des taxons suivis dans le protocole FP

INSERT INTO taxonomie.bib_listes (id_liste, nom_liste, desc_liste, regne, group2_inpn) 
VALUES (40, 'Bilan Conservatoire Flore', 'Taxons suivis dans le protocole Bilan Conservatoire Flore', 'Plantae', 'Angiospermes');

--Insertion des taxons du module FP absents dans la table bib_noms

WITH check_bib_noms AS (
    SELECT cd_nom, taxonomie.check_is_inbibnoms(cd_nom) as check_bn, francais FROM florepatri.bib_taxons_fp 
)

INSERT INTO taxonomie.bib_noms (cd_nom, cd_ref, nom_francais)
SELECT cd_nom, cd_nom, francais FROM check_bib_noms WHERE check_bn='false';

--Insertion des taxons du module FP dans la table de correspondance cor_nom_liste

WITH select_bib_noms AS (
    SELECT bib_noms.id_nom FROM taxonomie.bib_noms JOIN florepatri.bib_taxons_fp ON bib_noms.cd_nom=bib_taxons_fp.cd_nom
)

INSERT INTO taxonomie.cor_nom_liste (id_nom, id_liste) 
SELECT id_nom,40 FROM select_bib_noms;