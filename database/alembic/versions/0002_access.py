"""Fail-closed access baseline; operational service grants remain outstanding."""
from alembic import op

revision = "0002_access"
down_revision = "0001_baseline"
branch_labels = None
depends_on = None


def upgrade():
    op.execute("REVOKE CREATE ON SCHEMA public FROM PUBLIC")
    op.execute("REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC")
    op.execute("REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC")
    op.execute("REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC")
    op.execute("GRANT USAGE ON SCHEMA public TO ll_app")
    # Direct reads only for an internal trusted service. Matter authorization
    # remains a service gate; no browser/client may connect with this role.
    op.execute("GRANT SELECT ON ALL TABLES IN SCHEMA public TO ll_app")
    op.execute("REVOKE ALL ON TABLE public.alembic_version FROM ll_app")
    # Narrow definer entrypoint; trusted schema must not be writable by ll_app.
    op.execute("ALTER FUNCTION public.reserve_matter_number(integer, uuid) SECURITY DEFINER")
    op.execute("ALTER FUNCTION public.reserve_matter_number(integer, uuid) SET search_path = pg_catalog, public, pg_temp")
    op.execute("GRANT EXECUTE ON FUNCTION public.reserve_matter_number(integer, uuid) TO ll_app")
    op.execute("ALTER DEFAULT PRIVILEGES FOR ROLE ll_migrator REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC")


def downgrade():
    op.execute("ALTER DEFAULT PRIVILEGES FOR ROLE ll_migrator GRANT EXECUTE ON FUNCTIONS TO PUBLIC")
    op.execute("REVOKE EXECUTE ON FUNCTION public.reserve_matter_number(integer, uuid) FROM ll_app")
    op.execute("ALTER FUNCTION public.reserve_matter_number(integer, uuid) SECURITY INVOKER")
    op.execute("ALTER FUNCTION public.reserve_matter_number(integer, uuid) RESET search_path")
    op.execute("REVOKE ALL ON ALL TABLES IN SCHEMA public FROM ll_app")
    op.execute("REVOKE USAGE ON SCHEMA public FROM ll_app")
    op.execute("GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO PUBLIC")
