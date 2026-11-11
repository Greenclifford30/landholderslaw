"""Reviewed draft baseline, kept as versioned PostgreSQL SQL assets.

Revision ID: 0001_baseline
"""
import os
import re
from pathlib import Path
from alembic import op

revision = "0001_baseline"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    sql_dir = Path(__file__).resolve().parents[1] / "sql"
    assets = sorted(sql_dir.glob("*.sql"))
    if len(assets) != 16:
        raise RuntimeError("Baseline requires exactly the 16 versioned SQL assets")
    # Psycopg executes each complete script, retaining dollar-quoted function bodies.
    with op.get_bind().connection.driver_connection.cursor() as cursor:
        for asset in assets:
            cursor.execute(asset.read_text(encoding="utf-8"))


def downgrade():
    # No general-purpose destructive rollback: test databases only, explicit opt-in.
    if os.environ.get("ALLOW_DISPOSABLE_DB_DOWNGRADE") != "1":
        raise RuntimeError("Baseline downgrade is restricted to disposable databases")
    connection = op.get_bind()
    dbname = connection.exec_driver_sql("SELECT current_database()").scalar_one()
    if dbname != "landholders_test":
        raise RuntimeError("Disposable downgrade requires the isolated landholders_test database")
    # Only names captured in this immutable baseline; unrelated tables remain.
    assets = sorted((Path(__file__).resolve().parents[1] / "sql").glob("*.sql"))
    names = []
    for asset in assets:
        names.extend(re.findall(r"\bCREATE\s+TABLE\s+([a-z_][a-z_0-9]*)", asset.read_text(encoding="utf-8"), re.I))
    preparer = connection.dialect.identifier_preparer
    # Refuse to destroy rows even when the explicit disposable override is set.
    for name in names:
        exists = connection.exec_driver_sql("SELECT to_regclass(%s)", (f"public.{name}",)).scalar_one()
        if exists and connection.exec_driver_sql(f"SELECT EXISTS (SELECT 1 FROM public.{preparer.quote(name)} LIMIT 1)").scalar_one():
            raise RuntimeError(f"Disposable downgrade refused: {name} contains data")
    for name in reversed(names):
        connection.exec_driver_sql(f"DROP TABLE IF EXISTS public.{preparer.quote(name)} CASCADE")
    function_names = [name for asset in assets for name in re.findall(r"\bCREATE\s+FUNCTION\s+([a-z_][a-z_0-9]*)", asset.read_text(encoding="utf-8"), re.I)]
    functions = connection.exec_driver_sql("""
        SELECT p.oid::regprocedure::text FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public' AND pg_get_userbyid(p.proowner) = current_user AND p.proname = ANY(%s)
        ORDER BY p.oid DESC
    """, (function_names,)).scalars().all()
    for signature in functions:
        connection.exec_driver_sql(f"DROP FUNCTION IF EXISTS {signature} CASCADE")
