CREATE EXTENSION file_fdw;

CREATE SERVER pge_file FOREIGN DATA WRAPPER file_fdw;

\set quoted_dba_list '\'' :dba_list '\''

CREATE FOREIGN TABLE pge_dba_list (
  user_name name
  ) SERVER pge_file OPTIONS ( filename :quoted_dba_list, format 'csv' );


DO
$$
BEGIN
   IF NOT EXISTS (
      SELECT *
      FROM   pg_catalog.pg_roles
      WHERE  rolname = 'ldap_dbas') THEN

      CREATE ROLE ldap_dbas NOLOGIN SUPERUSER CREATEROLE CREATEDB;
   END IF;
END
$$;


CREATE OR REPLACE FUNCTION set_ldap_dbas() RETURNS TEXT AS
$$
DECLARE
  l_retstring TEXT DEFAULT '';
  c_new_dbas CURSOR FOR
    SELECT user_name AS user_name
     FROM pge_dba_list
     EXCEPT 
      SELECT DISTINCT r.rolname
        FROM pg_catalog.pg_roles r
        JOIN pg_catalog.pg_auth_members au ON (au.member=r.oid)
        JOIN pg_catalog.pg_roles ro ON (ro.oid=au.roleid)
       WHERE ro.rolname = 'ldap_dbas'
     ORDER BY 1;
    
  c_old_dbas CURSOR FOR
    SELECT DISTINCT r.rolname AS user_name
      FROM pg_catalog.pg_roles r
      JOIN pg_catalog.pg_auth_members au ON (au.member=r.oid)
      JOIN pg_catalog.pg_roles ro ON (ro.oid=au.roleid)
    WHERE ro.rolname = 'ldap_dbas'
    EXCEPT
      SELECT user_name
        FROM pge_dba_list
    ORDER BY 1;
   
  r_dba RECORD;
  
BEGIN
  l_retstring := E'===== NEW DBAS =====\n';
  OPEN c_new_dbas;
  LOOP
    FETCH c_new_dbas INTO r_dba;
   EXIT WHEN NOT FOUND;
    IF NOT EXISTS (SELECT * FROM pg_roles WHERE rolname = r_dba.user_name) THEN
        l_retstring := l_retstring || ' CREATE USER '||r_dba.user_name|| E'\n';
      EXECUTE 'CREATE USER '|| r_dba.user_name ||' IN ROLE ldap_dbas';
    ELSE
        l_retstring := l_retstring || ' GRANT USER '||r_dba.user_name|| E'\n';
      EXECUTE 'GRANT ldap_dbas TO '|| r_dba.user_name;
    END IF;
  END LOOP;
  CLOSE c_new_dbas;

  l_retstring := l_retstring || E'===== EX DBAS =====\n';
  OPEN c_old_dbas;
  LOOP
    FETCH c_old_dbas INTO r_dba;
   EXIT WHEN NOT FOUND;
    IF EXISTS (
      SELECT 1
        FROM pg_catalog.pg_auth_members x
        JOIN pg_catalog.pg_roles r ON (r.oid = x.roleid)
        JOIN pg_catalog.pg_roles m ON (m.oid = x.member)
      WHERE r.rolname != 'ldap_dbas'
      AND m.rolname = r_dba.user_name) THEN
       -- there are roles other than ldap_dbas: revoke only
        l_retstring := l_retstring || ' REVOKE '||r_dba.user_name|| E'\n';
        EXECUTE 'REVOKE ldap_dbas FROM '|| r_dba.user_name;
    ELSE
       -- no other roles: drop
        l_retstring := l_retstring || ' DROP USER '||r_dba.user_name|| E'\n';
      EXECUTE 'DROP USER '|| r_dba.user_name;
    END IF;
  END LOOP;
  CLOSE c_old_dbas;

  RETURN l_retstring;
END;
$$
LANGUAGE plpgsql;

SELECT set_ldap_dbas();  
