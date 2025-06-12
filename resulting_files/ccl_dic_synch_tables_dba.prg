CREATE PROGRAM ccl_dic_synch_tables:dba
 RDB drop table ccl_synch_cmp
 END ;Rdb
 RDB create table ccl_synch_cmp ( object char ( 1 ) , object_name char ( 30 ) , cclgroup number ,
 node_name char ( 20 ) , binary_cnt number , checksum number , major_version number , minor_version
 number , timestamp_dt_tm date , user_name char ( 20 ) , updt_dt_tm date , updt_id number , updt_task
  number , updt_cnt number , updt_applctx number , constraint xpkccl_synch_cmp primary key ( object ,
  object_name , cclgroup , node_name ) using index tablespace i_discern_ref_log ) tablespace
 d_discern_ref_log
 END ;Rdb
 RDB drop table ccl_synch_objects
 END ;Rdb
 RDB create table ccl_synch_objects ( ccl_synch_objects_id number , timestamp_dt_tm date , rcode char
  ( 1 ) , object char ( 1 ) , object_name char ( 30 ) , cclgroup number , node_name char ( 20 ) ,
 dir_name char ( 20 ) , major_version number , minor_version number , checksum number , dic_key char
 ( 40 ) , dic_data varchar ( 810 ) , updt_dt_tm date , updt_id number , updt_task number , updt_cnt
 number , updt_applctx number , constraint xpkccl_synch_objects primary key ( ccl_synch_objects_id )
 using index tablespace i_discern_ref_log ) tablespace d_discern_ref_log
 END ;Rdb
 RDB drop table ccl_synch_backup
 END ;Rdb
 RDB create table ccl_synch_backup ( ccl_synch_backup_id number , timestamp_dt_tm date , rcode char (
  1 ) , object char ( 1 ) , object_name char ( 30 ) , cclgroup number , node_name char ( 20 ) ,
 dir_name char ( 20 ) , major_version number , minor_version number , checksum number , dic_key char
 ( 40 ) , dic_data varchar ( 810 ) , updt_dt_tm date , updt_id number , updt_task number , updt_cnt
 number , updt_applctx number , constraint xpkccl_synch_backup primary key ( ccl_synch_backup_id )
 using index tablespace i_discern_ref_log ) tablespace d_discern_ref_log
 END ;Rdb
 RDB drop table ccl_synch_data
 END ;Rdb
 RDB create table ccl_synch_data ( ccl_synch_data_id number , node_name char ( 20 ) ,
 export_begin_dt_tm date , export_end_dt_tm date , export_only_ind number , import_begin_dt_tm date ,
  import_end_dt_tm date , object_purge_days number , backup_purge_days number , updt_dt_tm date ,
 updt_id number , updt_task number , updt_cnt number , updt_applctx number , constraint
 xpkccl_synch_data primary key ( ccl_synch_data_id ) using index tablespace i_discern_ref_log )
 tablespace d_discern_ref_log
 END ;Rdb
 RDB drop table ccl_synch_audit
 END ;Rdb
 RDB create table ccl_synch_audit ( ccl_synch_audit_id number , node_name char ( 20 ) , operation
 char ( 10 ) , begin_dt_tm date , end_dt_tm date , updt_dt_tm date , updt_id number , updt_task
 number , updt_cnt number , updt_applctx number , constraint xpkccl_synch_audit primary key (
 ccl_synch_audit_id ) using index tablespace i_discern_ref_log ) tablespace d_discern_ref_log
 END ;Rdb
 RDB create index xie1ccl_synch_objects on ccl_synch_objects ( timestamp_dt_tm , object , object_name
  , rcode ) tablespace i_discern_ref_log
 END ;Rdb
 RDB create index xie1ccl_synch_backup on ccl_synch_backup ( timestamp_dt_tm , object , object_name ,
  rcode ) tablespace i_discern_ref_log
 END ;Rdb
 RDB create unique index xie1ccl_synch_data on ccl_synch_data ( node_name ) tablespace
 i_discern_ref_log
 END ;Rdb
 RDB drop sequence ccl_dic_synch_seq
 END ;Rdb
 RDB create sequence ccl_dic_synch_seq
 END ;Rdb
END GO
