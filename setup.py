import setuptools
from pathlib import Path


root_dir = Path(__file__).absolute().parent
with (root_dir / "VERSION").open() as f:
    version = f.read()
with (root_dir / "README.md").open() as f:
    long_description = f.read()
with (root_dir / "requirements.in").open() as f:
    requirements = f.read().splitlines()


setuptools.setup(
    name="gn_module_priority_flora",
    version=version,
    description="Module Conservation Bilan Stationnel",
    long_description=long_description,
    long_description_content_type="text/x-rst",
    maintainer="Parcs nationaux des Écrins et des Cévennes, Conservatoire Botanique National Alpin",
    maintainer_email="geonature@ecrins-parcnational.fr",
    url="https://github.com/PnX-SI/gn_module_flore_prioritaire",
    packages=setuptools.find_packages("backend"),
    package_dir={"": "backend"},
    package_data={"gn_module_priority_flora.migrations": ["data/*.sql", "data/*.csv"]},
    install_requires=requirements,
    entry_points={
        "gn_module": [
            "code = gn_module_priority_flora:MODULE_CODE",
            "picto = gn_module_priority_flora:MODULE_PICTO",
            "blueprint = gn_module_priority_flora.blueprint:blueprint",
            "config_schema = gn_module_priority_flora.conf_schema_toml:GnModuleSchemaConf",
            "migrations = gn_module_priority_flora:migrations",
        ],
    },
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Developers",
        "Natural Language :: English",
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: GNU Affero General Public License v3"
        "Operating System :: OS Independent",
    ],
)
