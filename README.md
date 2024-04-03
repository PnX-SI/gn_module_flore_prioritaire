# Bilan Stationnel


Refonte du module GeoNature du protocole Flore Prioritaire renommé "Bilan Stationnel Flore" du réseau Flore Sentinelle, piloté par le PNE et le CBNA. Développé à l'origine par @richardvergely (https://geonature.fr/documents/2019-09-Richard-Vergely-veille-technologique-GeoNature.pdf).

Une liste d'espèces prioritaires est définie. Ces espèces sont prospectées sur le territoire.

Pour chaque prospection d'une espèce, on note la *zone de prospection* (`ZP`) et les éventuelles *aires de présence* (`AP`).

## Installation et configuration

- Voir la doc GeoNature pour l'instalation d'un module : https://docs.geonature.fr/installation.html#installation-d-un-module-geonature

- Créer le fichier de configuration du module comme expliquer ici : https://docs.geonature.fr/installation.html#configuration-du-module

Pour créer des données d'exemple dans le module (jeux de données, cadre d'acquisition et liste de taxon), lancez la commande suivante :

`geonature db upgrade priority_flora_sample@head`

## Ajout du MNT (DEM)

Ce module utilise le MNT pour déterminer les altitutdes minimum et maximum
des aires de présence.

Vous pouvez vérifier la présence du MNT dans la table : `ref_geo.dem`
Si la table est vide, cela signifie que le MNT n'est pas installé.

Pour ajouter le MNT *raster* à la base GeoNature utiliser la commande GeoNature suivante :
```
geonature db upgrade ign_bd_alti@head -x local-srid=<local-srid>
```
Remplacer `<local-srid>` par la valeur de votre SRID (généralement `2154`).
Si vous ne le connaissez pas, regarder sa valeur au niveau du champ
`ref_geo.l_areas.geom` de votre base de données.

Si vous souhaiter augementer les performatnces du MNT, vous pouvez le vectoriser avec la commande :
```
geonature db upgrade ign_bd_alti_vector@head
```

## Réglage des droits

Une fois le module installé, vous pouvez régler les droits du module pour votre groupe d'utilisateur :
- Via le module *Admin* de GeoNature, accéder à l'interface d'administration des permissions (CRUVED).
- Définissez les permissions suivant votre besoin. Voici un exemple :
  - `C` (Créer) à `3` (Toutes les données)
  - `R` (Lire) à `3` (Toutes les données)
  - `U` (Mise à jour) à `2` (Les données de mon organisme)
  - `E` (Export) à `3` (Toutes les données)
  - `D` (Supprimer) à `1` (Mes données)

## Association du jeu de données à un/des acteur-s

Soit via l'interface du module "Métadonnées", soit via la table "gn_meta.cor_dataset_actor".

## Associer d'une liste d'utilisateurs pour créer des ZP & AP

Renseigner le paramètre "observers_list_code" qui par défaut prend la valeur "OFS" (Observateurs Flore Sentinelle).
Renseigner la table de correspondance "cor_role"liste" pour associer des utilisateurs à cette liste.

## Charger les communes pour que le filtre par commune fonctionne
Si vous souhaitez filtrer les données par communes, il faut que votre base de données dispose des communes de France, vous pouvez les récupérer avec la commande : 
```
geonature db upgrade ref_geo_fr_municipalities@head
```

## Désinstallation

**⚠️ ATTENTION :** la désinstallation du module implique la suppression de toutes les données associées. Assurez vous d'avoir fait une sauvegarde de votre base de données au préalable.

Suivez la procédure suivante :
1. Rétrograder la base de données pour y enlever les données spécifiques au module :
    ```bash
    geonature db downgrade priority_flora@base
    ```
1. Désinstaller le package du virtual env :
    ```
    pip uninstall gn-module-priority-flora
    ```
    - Possibilité de voir le nom du module avec : `pip list`
1. Supprimer la ligne relative au module dans `gn_commons.t_modules`
1. Supprimer le lien symbolique du module dans les dossiers :
    - `geonature/external_modules`
    - `geonature/frontend/src/external_assets/`


## Licence

* [Licence OpenSource GPL v3](./LICENSE.txt)
* Copyleft 2018-2022 - Parc National des Écrins - Conservatoire National Botanique Alpin

[![Logo PNE](http://geonature.fr/img/logo-pne.jpg)](http://www.ecrins-parcnational.fr)

[![Logo CBNA](http://www.cbn-alpin.fr/images/stories/habillage/logo-cbna.jpg)](http://www.cbn-alpin.fr)

## Lexique

* Zone de prospection [prospecting zone]
* Aire de présence [presence area]
