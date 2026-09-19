\getenv admin_pass ADMIN_PASS
\getenv app_pass APP_PASS
\getenv monitor_pass MONITOR_PASS

CREATE ROLE cluster_admin
WITH LOGIN
CREATEDB
CREATEROLE
PASSWORD :'admin_pass';

CREATE ROLE app_user
WITH LOGIN
PASSWORD :'app_pass';

CREATE ROLE monitor_user
WITH LOGIN
PASSWORD :'monitor_pass';

GRANT pg_monitor TO monitor_user;

CREATE DATABASE clusterdb
OWNER cluster_admin;

\connect clusterdb
GRANT CONNECT ON DATABASE clusterdb TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
ALTER DEFAULT PRIVILEGES FOR ROLE cluster_admin IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES FOR ROLE cluster_admin IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO app_user;
