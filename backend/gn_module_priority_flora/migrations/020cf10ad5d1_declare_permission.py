"""declare permission

Revision ID: 020cf10ad5d1
Revises: f6092b0c6ef4
Create Date: 2023-05-25 11:39:13.275368

"""
from alembic import op
import sqlalchemy as sa

from gn_module_priority_flora import MODULE_CODE


# revision identifiers, used by Alembic.
revision = "020cf10ad5d1"
down_revision = "f6092b0c6ef4"
branch_labels = None
depends_on = None


def upgrade():
    op.get_bind().execute(
        """
        INSERT INTO
            gn_permissions.t_permissions_available (
                id_module,
                id_object,
                id_action,
                label,
                scope_filter
            )
        SELECT
            m.id_module,
            o.id_object,
            a.id_action,
            v.label,
            v.scope_filter
        FROM ( VALUES
                (:moduleCode, 'ALL', 'C', True, 'Créer des ZP et AP'),
                (:moduleCode, 'ALL', 'R', True, 'Voir les ZP et AP'),
                (:moduleCode, 'ALL', 'U', True, 'Modifier les ZP et AP'),
                (:moduleCode, 'ALL', 'E', True, 'Exporter les ZP et AP'),
                (:moduleCode, 'ALL', 'D', True, 'Supprimer des ZP et AP')
            ) AS v (module_code, object_code, action_code, scope_filter, label)
        JOIN
            gn_commons.t_modules m ON m.module_code = v.module_code
        JOIN
            gn_permissions.t_objects o ON o.code_object = v.object_code
        JOIN
            gn_permissions.bib_actions a ON a.code_action = v.action_code
        """,
        {"moduleCode": MODULE_CODE},
    )
    op.get_bind().execute(
        """
        WITH bad_permissions AS (
            SELECT
                p.id_permission
            FROM
                gn_permissions.t_permissions p
            JOIN gn_commons.t_modules m
                    USING (id_module)
            WHERE
                m.module_code = :moduleCode
            EXCEPT
            SELECT
                p.id_permission
            FROM
                gn_permissions.t_permissions p
            JOIN gn_permissions.t_permissions_available pa ON
                (p.id_module = pa.id_module
                    AND p.id_object = pa.id_object
                    AND p.id_action = pa.id_action)
        )
        DELETE
        FROM
            gn_permissions.t_permissions p
                USING bad_permissions bp
        WHERE
            bp.id_permission = p.id_permission;
        """,
        {"moduleCode": MODULE_CODE},
    )


def downgrade():
    op.get_bind().execute(
        """
        DELETE FROM
            gn_permissions.t_permissions_available pa
        USING
            gn_commons.t_modules m
        WHERE
            pa.id_module = m.id_module
            AND
            module_code = :moduleCode
        """,
        {"moduleCode": MODULE_CODE},
    )
