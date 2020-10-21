SELECT r.rolname,
  case when r.rolsuper is true then 'X' else '' END as super,
  case when r.rolinherit is true then 'X' else '' END as inherit,
  case when r.rolcreaterole is true then 'X' else '' END as createrole,
  case when r.rolcreatedb is true then 'X' else '' END as createdb,
  case when r.rolcanlogin is true then 'X' else '' END as canlogin,
 r.rolconnlimit, r.rolvaliduntil,
  ARRAY(SELECT b.rolname
        FROM pg_catalog.pg_auth_members m
        JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid)
        WHERE m.member = r.oid) as memberof
,
case when  r.rolreplication is true then 'X' else '' END as replication
FROM pg_catalog.pg_roles r
join pg_catalog.pg_auth_members au on (au.member=r.oid)
JOIN pg_catalog.pg_roles ro on (ro.oid=au.roleid)
--where ro.rolname like 'catprest%'
ORDER BY 1;

