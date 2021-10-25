=========================
BILAN CONSERVATOIRE FLORE
=========================

Refonte du module GeoNature du protocole Flore Prioritaire renommé "Bilan Conservatoire Flore" du réseau Flore Sentinelle, piloté par le PNE et le CBNA. Développé par @richardvergely (https://geonature.fr/documents/2019-09-Richard-Vergely-veille-technologique-GeoNature.pdf).

Une liste d'espèces prioritaires est définie. Ces espèces sont prospectées sur le territoire. 

Pour chaque prospection d'une espèce, on note la zone de prospection (ZP) et les éventuelles Aires de présence (AP).

Installation
============

* Installez GeoNature (https://github.com/PnX-SI/GeoNature)
* Téléchargez la dernière version stable du module (``wget https://github.com/PnX-SI/gn_module_flore_prioritaire/archive/X.Y.Z.zip``) dans ``/home/myuser/``
* Dézippez la dans ``/home/myuser/`` (``unzip X.Y.Z.zip``)
* Créez et adaptez le fichier ``config/settings.ini`` à partir de ``config/settings.ini.sample`` (``cp config/settings.ini.sample config/settings.ini``)
* Data ?
* Placez-vous dans le répertoire ``backend`` de GeoNature et lancez les commandes ``source venv/bin/activate`` puis ``geonature install_packaged_gn_module <chemin_vers_le_module> GN_MODULE_FLORE_PRIORITAIRE``
* Complétez la configuration du module (``config/conf_gn_module.toml`` à partir des paramètres présents dans ``config/conf_gn_module.toml.example`` dont vous pouvez surcoucher les valeurs par défaut. Puis relancez la mise à jour de la configuration (depuis le répertoire ``geonature/backend`` et une fois dans le venv (``source venv/bin/activate``) : ``geonature update_module_configuration GN_MODULE_FLORE_PRIORITAIRE``)
* Vous pouvez sortir du venv en lançant la commande ``deactivate``

Licence
=======

* OpenSource - GPL-3.0
* Copyleft 2018-2019 - Parc National des Écrins

.. image:: http://geonature.fr/img/logo-pne.jpg
    :target: http://www.ecrins-parcnational.fr
