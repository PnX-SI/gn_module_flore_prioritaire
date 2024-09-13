# Changelog

Toutes les modifications notables apportées à ce projet seront documentées dans ce fichier en français.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Inédit]


## [2.3.0] - 2024-08-20

#### 🚀 Ajouté

- Compatibilité avec GeoNature 2.14
- Possibilité de choisir le Dataset dans la création de ZP.
- La création des datasets, des frameworks d'acquisitions et de la liste des taxons se fait dans une branche Alembic séparée (`priority_flora_sample`)
- Le paramètre pour la liste des taxons n'est plus obligatoire. Par défaut, nous interrogeons tous Taxref. Il peut être restreint via le paramètre `taxons_list_code`.
- Possibilité d'exporter les zones de prospection séparément des zones de présence
- Utilisation du nouveau fichier `pyproject.toml` pour l'installation et les dépendances au lieu de `setup.py`
- Ajout d'un exemple de fichier `tsconfig.json` à utiliser avec le développement de modules en dehors du répertoire GeoNature

### 🐛 Corrigé

- Correction d'un bug de redirection causé par les « onglets » de bootstrap sur les fiches d'informations ZP et le passage aux onglets Material.
- Gérer les exportations ZP et AP avec une valeur nulle pour les champs de géométrie

### 🔄 Modifié

- Le champ `id_source` utilisé dans le déclencheur précédemment obtenu à partir de `__init__.py` est désormais obtenu à partir du code source du module (via `gn_synthese.t_sources`).
- ⚠️ Le paramètre `taxons_list_code` doit être défini avec une valeur de la clé primaire (`id_liste`) de la table `taxonomie.bib_listes`.
- ⚠️ Le champ `observaters` de l'export des aires de présence a été renommé `observers`. Lors de la mise à jour du module, il est nécessaire de supprimer la vue`DROP VIEW pr_priority_flora.export_ap;` et de la créer à nouveau avec le code présent dans le fichier [schema.sql](backend/gn_module_priority_flora/migrations/data/schema.sql#L305)
- ⚠️ Depuis la version 2.12 de GeoNature, le fichier de config du module reste présent dans le dossier `config/` du module mais doit être placé et utilisé sous le nom `<code-module>_config.toml` (ex. `priority_flora_config.toml`) dans le dossier `config/` de GeoNature ([voir GeoNature#2423](https://github.com/PnX-SI/GeoNature/issues/2423)).


## [2.2.1] - 2023-11-15

### 🐛 Corrigé

- Correction de l'utilisation de la date/heure dans le service web d'exportation

## [2.2.0] - 2023-10-13

#### 🚀 Ajouté

- Ajout d'une gestion des droits de ce module dans une section de la documentation d'installation.
- Ajout de la possibilité de trier, sélectionner et renommer les noms des colonnes d'exportation.
- Ajout d'un nouveau service web de statistiques pour le module Conservation Strategy.

### 🐛 Corrigé

- Correction des erreurs de texte du changelog.
- Correction du script de migration. Nous utilisons maintenant le champ de géométrie correct pour la géométrie ZP.
- Activer le mode édition sur le composant `pnx-leaflet-filelayer` pour éviter la suppression du fichier GPX lorsque la géométrie est dessinée.
- Dans la vue de liste de cartes ZP, le filtre d'organisme ne renvoie plus "Erreur interne du serveur". L'exportation est à nouveau possible.
- Utilisateur SRID 4326 pour l'exportation GeoJson.
- Ajout des champs de géométrie ZP et AP manquants dans l'exportation CSV.

### 🔄 Modifié

- Dans la vue de liste de cartes ZP, l'infobulle du filtre de taxon s'affiche désormais au-dessus du filtre.
- Dans la vue des détails ZP, dans la section de ligne développée des détails AP, `NA` s'affiche si aucun comptage n'est effectué.
- Dans la vue du formulaire AP, l'étiquette de pourcentage est modifiée dynamiquement de "Fréquence estimée en %" à "Fréquence calculée en %" lorsque la valeur de la méthode de fréquence est "Transect".
- Configuration plus jolie modifiée. La virgule de fin n'est pas supprimée lorsqu'elle est compatible avec ES5.
- Reformatage de tous les fichiers de code source du frontend avec Prettier.
- Reformatage de tous les fichiers de code source du backend avec Black.
- L'exportation GeoJson inclut les géométries ZP.
- Utilisation de l'anglais pour les champs de vue d'exportation.
- Débogage amélioré pour les classes DB de modèles avec une classe parent.


## [2.1.0] - 2022-10-20

⚠️ Tous les changements entre la v2.0.0 et la v2.1.0 nécessitent la désinstallation et la réinstallation du module.
Exécutez à nouveau le script de migration des données de la v1 vers la v2.

#### 🚀 Ajouté

- Ajout d'icônes aux contrôles de formulaire et aux pages de détails.
- Ajout d'infobulles d'aide sur les contrôles de formulaire.
- Ajout de déclencheurs pour insérer, mettre à jour ou supprimer des observations dans les tables de base de données du module Synthese.
- Ajout de déclencheurs pour les actions d'insertion, de mise à jour ou de suppression d'historique sur les tables de base de données `t_zprospect` et `t_apresence`.
- Ajout du chargeur de fichiers GPX dans les cartes de formulaires ZP et AP.
- Toutes les classes de modèles affichent leurs attributs et leurs valeurs lorsque nous utilisons `print()` pour leur débogage.
- La vue de liste ZP stocke les valeurs de filtre entre les accès.

### 🔄 Modifié

- Amélioration des noms des fonctions des services Web.
- Amélioration du nommage des paramètres de configuration.
- Ajout automatique des valeurs par défaut pour `date_max` et `initial_insert` de la zone de prospection.
- Le SRID des champs de géométrie locale du module sera lu à partir des données renvoyées par la base de données.
- Valeurs de nomenclature des inclinaisons ordonnées.
- Champ observateurs défini comme obligatoire sur le formulaire ZP.
- Le guide d'installation est maintenant plus détaillé. Les commandes pour installer et vectoriser le MNT sont indiquées.
- Schéma du module mis à jour pour améliorer la compatibilité pour la migration depuis la v1 de ce module.
- Script de migration amélioré, ajout de données aux nouveaux champs (physionomies, état de l'habitat...).
- Jeton d'injection utilisé pour les paramètres de configuration du module dans les vues.
- Dans le formulaire AP, le champ surface est désormais obligatoire et activé lorsque la géométrie Point est utilisée.
- Le formulaire AP contient de nouveaux contrôles et de nouveaux ensembles de champs (physionomies, état de l'habitat...).
- La vue de liste AP affiche la fréquence, le pourcentage d'état favorable, la surface et toutes les informations AP dans chaque section de ligne développée.
- La vue de liste ZP affiche la surface et le nombre d'AP.

### 🐛 Corrigé

- Correction de la fonction de base de données `insert_zp()`, `insert_ap()` : générer la valeur `geom_point_4326`.
- Correction de la syntaxe de plusieurs extensions utilisée dans le fichier `.editorconfig`.
- Correction de la casse des lettres de code de module dans les vérifications des autorisations des services Web.
- Correction de la géométrie en double ajoutée sur la carte lors de l'édition d'une ZP ou d'un AP.
- Correction de la gestion des droits des utilisateurs dans la liste des ZP.
- Correction des déclencheurs qui génèrent la valeur de la zone ZP et AP. Nous ne définissons la zone que si elle est nulle.
- Correction de l'activation du champ de zone et du bouton d'enregistrement pour le formulaire AP lors de l'édition.
- Correction des noms d'organismes en double dans la liste des ZP.

### 🗑 Supprimé

- Suppression de l'outil de dessin carré sur la carte.

## [2.0.0] - 2022-09-08

### 🚀 Ajouté

- Première version.
- Module packagé pour GeoNature 2.9.2
- Refactorisation géante du code.
- L'interface est maintenant utilisable et a été améliorée.
- Le script de migration du module GeoNature v1 Priority Flora récupère toutes les anciennes données (utilisation des champs `additional_data`).
- Les services Web sont désormais plus orientés REST.
- La base de données a été revue et améliorée.
- Ajout d'une image MPD de base de données et d'une collection de services Web Postman.
