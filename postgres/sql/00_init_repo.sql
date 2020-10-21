create domain t_filename   varchar(255);
create domain t_walfile    varchar(32);
create domain t_directory  varchar(4096);
create domain t_filepath   varchar(4096);
create domain t_md5	    varchar(32);
create domain t_sreq	   varchar(64); -- service request
create domain t_username   varchar(16); -- unix user that runs the script (overridable)

create type   t_backuptype as ENUM('full','wal');
create type   t_jobstatus  as ENUM('ok','error','warning','running');
create type   t_importtype as ENUM('database','dumpfile');

create table pge_auth_members (
   pg_cluster   name
  ,roleid	   oid
  ,member	   oid
  ,grantor	  oid
  ,admin_option boolean
 );


create table pge_backup (
	id serial
	,pg_cluster name not null
	,backup_type t_backuptype
	,status t_jobstatus
	,start_time timestamp
	,end_time timestamp
	,start_wal t_walfile
	,end_wal t_walfile
	,filepath t_filepath
	,filesize bigint
	,checksum t_md5
	,backuplog text
	,backupindex text
) ;


create table pge_backup_wal (
	bsid integer
	,pg_cluster name
	,filename t_filename
	,filepath t_filepath
	,filedate timestamp
	,checksum t_md5
) ;

create table pge_database_create (
	id serial
	,start_date timestamp
	,end_date timestamp
	,status t_jobstatus
	,database_name name
	,lc_ctype name
	,lc_collate name
	,pg_cluster name
	,server_name name
	,sreq t_sreq
	,username name
	,log text
) ;

   
create table pge_databases_histo (
	pg_cluster name
	,server_name name
	,port integer 
	,database_name name
	,collation_name name
	,is_template boolean
	,allows_connections boolean
	,connection_limit integer
	,bytes bigint 
	,perimeter boolean
	,collect_date timestamp default now()
	,version varchar(10) 
	,ctype name
)  ;

create table pge_dumps (
	id serial 
	,pg_cluster name
	,database_name name 
	,status t_jobstatus 
	,start_date timestamp 
	,end_date timestamp
	,run_log text 
	,run_log_path t_filepath
	,dumpfile_path t_filepath
	,dump_log text 
	,dump_log_path t_filepath 
	,username t_username 
	,sreq t_sreq 
)  ;


create table pge_imports (
	id serial 
	,start_date timestamp 
	,end_date timestamp
	,sreq t_sreq 
	,dumpfile_path t_filename
	,source_cluster name 
	,refresh_date timestamp
	,dest_cluster name 
	,source_database name
	,dest_database name
	,status t_jobstatus
	,run_log text 
	,run_log_path t_filepath
	,username t_username 
	,import_type t_importtype 
	,dump_id integer
)  ;


create table pge_roles (
	 pg_cluster name
	,rolname name
	,rolsuper boolean
	,rolinherit boolean
	,rolcreaterole boolean
	,rolcreatedb boolean
	,rolcanlogin boolean
	,rolreplication boolean
	,rolconnlimit integer
	,rolvaliduntil timestamp with time zone 
	,rolbypassrls boolean
	,oid oid
)  ;


create unique index pk_pge_auth_members on pge_auth_members (pg_cluster, roleid, member);
alter table pge_auth_members add primary key using index pk_pge_auth_members;

create index idx_pge_backup on pge_backup (pg_cluster, end_time, backup_type, status);
create index idx_pge_backup_1 on pge_backup (backup_type, pg_cluster, status, start_time, end_time);
create unique index pk_pge_backup on pge_backup (id);

alter table pge_backup add primary key using index pk_pge_backup;
alter table pge_backup alter start_time set not null ;
alter table pge_backup alter status set not null;
alter table pge_backup alter backup_type set not null;
alter table pge_backup alter pg_cluster set not null;
alter table pge_backup alter id set not null;

create unique index pk_pge_backup_wal on pge_backup_wal (bsid, pg_cluster, filename);

alter table pge_backup_wal add primary key using index pk_pge_backup_wal;
alter table pge_backup_wal alter pg_cluster set not null ;
alter table pge_backup_wal alter bsid set not null;

create unique index pk_pge_database_create on pge_database_create (id);
alter table pge_database_create add primary key using index pk_pge_database_create;

create index idx_pge_databases_1 on pge_databases (server_name, pg_cluster)  ;

create unique index pk_pge_databases on pge_databases (pg_cluster, database_name) ;
alter table pge_databases add primary key using index pk_pge_databases;

create unique index pk_pge_databases_h on pge_databases_histo (pg_cluster, database_name, collect_date) ;
alter table pge_databases_histo add primary key using index pk_pge_databases_h;
alter table pge_databases_histo alter collect_date set not null;

create unique index pk_pge_dumps on pge_dumps (id);
alter table pge_dumps add primary key using index pk_pge_dumps;
create index idx_pge_dumps_name on pge_dumps (dumpfile_path);
create index idx_pg_dumps_1 on pge_dumps (status, end_date) ;

create unique index pk_pge_imports on pge_imports (id);
alter table pge_imports add primary key using index pk_pge_imports;
create index idx_pge_imports_dest on pge_imports (dest_cluster, status);
create index idx_pge_imports_start on pge_imports (start_date);
create index idx_pge_imports_dump_fk on pge_imports (dump_id);

create unique index pk_pge_roles on pge_roles (pg_cluster, rolname);
alter table pge_roles add primary key using index pk_pge_roles;


alter table pge_imports add constraint pge_imports_dump_fk foreign key (dump_id)
  references pge_dumps (id) on delete set null on update cascade;

alter table pge_backup_wal add constraint pge_backup_wal_backup_fk foreign key (bsid)
  references pge_backup (id) on delete cascade;

create view v_pge_databases as select * from pge_databases_histo where collect_date=date_trunc('day',current_timestamp);

