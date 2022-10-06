# Installation/Désinstallation du module

## Prérequis

- Avoir [installer GeoNature](https://github.com/PnX-SI/GeoNature) en version v2.9.2 ou plus.

## Installation

**Notes :** l'installation proposée ici est en mode *développement*. Pour la *production*, supprimez les options `--build false` des commandes.

1. Télécharger le module sur votre serveurs [à partir d'une release](https://github.com/PnX-SI/gn_module_flore_prioritaire/releases) :
    ```bash
    wget https://github.com/PnX-SI/gn_module_flore_prioritaire/archive/X.Y.Z.zip
    ```
1. Créer un dossier qui contiendra vos modules :
    ```bash
    mkdir /home/${USER}/modules
    ```
1. Dézippez la dans `/home/${USER}/modules` avec :
    ```
    unzip X.Y.Z.zip
    ```
1. Placez vous dans le dossier de GeoNature et activer le venv :
    ```bash
    source backend/venv/bin/activate
    ```
1. Installer le module avec la commande :
    ```bash
    geonature install-packaged-gn-module --build false /home/${USER}/modules/gn_module_flore_prioritaire PRIORITY_FLORA
    ```
    - Adapter le chemin `/home/${USER}/modules/gn_module_flore_prioritaire` à votre installation.
1. Complétez la configuration du module uniquement si nécessaire :
    ```bash
    nano config/conf_gn_module.toml
    ```
    - Vous trouverez les paramètres possibles dans le fichier : `config/conf_gn_module.toml.example`.
    - Les valeurs par défaut dans : `backend/gn_module_priority_flora/conf_schema_toml.py`
1. Mettre à jour le frontend :
    ```bash
    geonature update-configuration --build false && geonature generate-frontend-tsconfig && geonature generate-frontend-tsconfig-app && geonature generate-frontend-modules-route
    ```
1. Vous pouvez sortir du venv en lançant la commande : `deactivate`


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
1. Mettre à jour le frontend :
    ```bash
    geonature update-configuration --build false && geonature generate-frontend-tsconfig && geonature generate-frontend-tsconfig-app && geonature generate-frontend-modules-route
    ```

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
