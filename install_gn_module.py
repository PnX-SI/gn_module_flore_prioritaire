import subprocess
from pathlib import Path
from jinja2 import Template
from sqlalchemy.sql.expression import func
from Flask import request
from geonature.core.gn_meta.models import TDatasets

ROOT_DIR = Path(__file__).absolute().parent


def gnmodule_install_app(gn_db, gn_app):
    """
        Fonction principale permettant de réaliser les opérations d'installation du module : 
            - Base de données
            - Module (pour le moment rien)
    """
    with gn_app.app_context():
        subprocess.call(["./install_db.sh"], cwd=str(ROOT_DIR))

    q = DB.session.query(func.max(TDatasets.id_dataset))
    max = q.all()

    with open(str(ROOT_DIR / "config/conf_schema_toml.py"), "r") as input_file:
        template = Template(input_file.read())
        dataset = template.render(id_dataset=max)

    with open(str(ROOT_DIR / "config/conf_schema_toml.py"), "w") as output_file:
        output_file.write(dataset)

