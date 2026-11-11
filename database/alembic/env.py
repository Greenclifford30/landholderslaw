import os
from alembic import context
from sqlalchemy import create_engine, pool

url = os.environ.get("DATABASE_URL")
if not url:
    raise RuntimeError("DATABASE_URL must be supplied explicitly")
if context.is_offline_mode():
    raise RuntimeError("Offline generation is not supported by the SQL baseline")
engine = create_engine(url, poolclass=pool.NullPool)
with engine.connect() as connection:
    # Migration identity is provisioned separately by a database administrator.
    role = os.environ.get("DB_MIGRATION_ROLE")
    if role:
        if role != "ll_migrator":
            raise RuntimeError("Unsupported migration role")
        connection.exec_driver_sql("SET ROLE ll_migrator")
        connection.commit()
    context.configure(connection=connection, target_metadata=None, transactional_ddl=True)
    with context.begin_transaction():
        context.run_migrations()
engine.dispose()
