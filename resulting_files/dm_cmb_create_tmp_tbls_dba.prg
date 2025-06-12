CREATE PROGRAM dm_cmb_create_tmp_tbls:dba
 SET trace = debug
 RDB create table dm_cmb_constraints ( constraint_name varchar2 ( 30 ) not null , table_name varchar2
  ( 30 ) not null , constraint_type char ( 1 ) not null , r_constraint_name varchar ( 30 ) null ,
 updt_dt_tm date null , constraint xpkdm_cmb_constraints primary key ( constraint_name ) using index
 tablespace i_sys_mgmt ) tablespace d_sys_mgmt storage ( initial 390k next 39k )
 END ;Rdb
 RDB create table dm_cmb_cons_columns ( column_name varchar2 ( 30 ) not null , constraint_name
 varchar2 ( 30 ) not null , position number not null , table_name varchar2 ( 30 ) not null ,
 updt_dt_tm date null , constraint xpkdm_cmb_cons_columns primary key ( constraint_name , position )
 using index tablespace i_sys_mgmt , constraint xfk1dm_cmb_cons_columns foreign key ( constraint_name
  ) references dm_cmb_constraints ) tablespace d_sys_mgmt storage ( initial 498k next 50k )
 END ;Rdb
 RDB create table dm_cmb_tab_columns ( table_name varchar2 ( 30 ) not null , column_name varchar2 (
 30 ) not null , updt_dt_tm date null , constraint xpkdm_cmb_tab_columns primary key ( table_name ,
 column_name ) using index tablespace i_sys_mgmt ) tablespace d_sys_mgmt storage ( initial 4m next
 400k )
 END ;Rdb
 RDB create index xie1dm_cmb_constraints on dm_cmb_constraints ( table_name , constraint_type )
 tablespace i_sys_mgmt
 END ;Rdb
 RDB create index xie2dm_cmb_constraints on dm_cmb_constraints ( r_constraint_name ) tablespace
 i_sys_mgmt
 END ;Rdb
 EXECUTE oragen3 "DM_CMB_CONSTRAINTS"
 EXECUTE oragen3 "DM_CMB_CONS_COLUMNS"
 EXECUTE oragen3 "DM_CMB_TAB_COLUMNS"
END GO
