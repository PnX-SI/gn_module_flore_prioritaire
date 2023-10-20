"""add id_dataset foreign key

Revision ID: 8785387b4689
Revises: 7e35f5a54cc8
Create Date: 2023-10-20 16:11:10.752880

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '8785387b4689'
down_revision = '7e35f5a54cc8'
branch_labels = None
depends_on = None


def upgrade():
    op.execute(
        """
        alter table pr_priority_flora.t_zprospect 
        ADD CONSTRAINT fk_id_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets (id_dataset) ON UPDATE CASCADE;
        """
    )


def downgrade():
    op.execute(
        """ALTER TABLE pr_priority_flora.t_zprospect drop constraint fk_id_dataset;"""
    )
