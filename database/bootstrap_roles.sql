BEGIN;
-- Run by a database administrator before migration. Attach actual login roles
-- separately; no production credentials are created here.
DO $$
BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='ll_migrator') THEN CREATE ROLE ll_migrator NOLOGIN NOINHERIT; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='ll_app') THEN CREATE ROLE ll_app NOLOGIN NOINHERIT; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='ll_db_admin') THEN CREATE ROLE ll_db_admin NOLOGIN NOINHERIT; END IF;
END $$;
GRANT ll_migrator TO ll_db_admin;
ALTER SCHEMA public OWNER TO ll_migrator;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
DO $$
BEGIN
 IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname IN ('ll_app','ll_migrator','ll_db_admin') AND
   (rolcanlogin OR rolinherit OR rolsuper OR rolcreatedb OR rolcreaterole OR rolreplication OR rolbypassrls)) THEN
  RAISE EXCEPTION 'Existing database group roles do not satisfy the expected restricted baseline';
 END IF;
 IF EXISTS (SELECT 1 FROM pg_auth_members m JOIN pg_roles r ON r.oid=m.member WHERE r.rolname='ll_app') THEN
  RAISE EXCEPTION 'Existing ll_app role has unexpected inherited role memberships';
 END IF;
END $$;
COMMIT;
