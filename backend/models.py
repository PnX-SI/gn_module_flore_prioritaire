from geonature.utils.utilssqlalchemy import serializable
from geonature.utils.env import DB

@serializable
class TPrograms(DB.Model):
    __tablename__ = 't_zprospect'
    __table_args__ = {'schema': 'pr_priority_flora'}
    id_program = DB.Column(
        DB.Integer,
        primary_key=True,
    )
    program_name = DB.Column(DB.Unicode)
program_desc = DB.Column(DB.Unicode)