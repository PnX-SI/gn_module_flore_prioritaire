--insérer les unités 

ALTER TABLE utilisateurs.bib_unites ADD anc_id_unite integer;

INSERT INTO utilisateurs.bib_unites
(nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite,anc_id_unite)
SELECT nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite
FROM OLD_DATABASE_SCHEMA.OLD_DATABASE_TABLE;

--insérer les organismes 

ALTER TABLE utilisateurs.bib_organismes ADD anc_id_organisme integer;

INSERT INTO utilisateurs.bib_organismes
(nom_organisme, adresse_organisme, cp_organisme, ville_organisme, tel_organisme, fax_organisme, email_organisme, anc_id_organisme)
SELECT nom_organisme, adresse_organisme, cp_organisme, ville_organisme, tel_organisme, fax_organisme, email_organisme, id_organisme
FROM OLD_DATABASE_SCHEMA.OLD_DATABASE_TABLE;

--insérer les observateurs

ALTER TABLE utilisateurs.t_roles ADD anc_id_role integer;

INSERT INTO utilisateurs.t_roles(groupe, id_role, identifiant, nom_role, prenom_role, desc_role, pass, email, id_organisme, organisme, id_unite, remarques, pn, session_appli, date_insert, date_update)
SELECT groupe, id_role, identifiant, nom_role, prenom_role, desc_role, pass, email, id_organisme, organisme, id_unite, remarques, pn, session_appli, date_insert, date_update
FROM OLD_DATABASE_SCHEMA.OLD_DATABASE_TABLE;

--MAJ du champ id_organisme dans la table t_roles

UPDATE utilisateurs.t_roles SET id_organisme=SELECT id_organisme FROM utilisateurs.bib_organismes WHERE t_roles.id_organisme=bib_organismes.anc_id_organisme;

--MAJ du champ id_unite dans la table t_roles

UPDATE utilisateurs.t_roles SET id_unite=SELECT id_unite FROM utilisateurs.bib_unites WHERE t_roles.id_unite=bib_unites.anc_id_unite;