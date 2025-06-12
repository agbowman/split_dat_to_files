CREATE PROGRAM cclreflogdef
 IF (( $1="RESET"))
  RDB drop table ccl_ref_logging
  END ;Rdb
  RDB drop table ccl_ref_logging_bind
  END ;Rdb
  RDB drop sequence cclreflogseq
  END ;Rdb
  RDB create sequence cclreflogseq
  END ;Rdb
  RDB create table ccl_ref_logging ( ref_id number , ref_type char ( 1 ) , ref_table varchar2 ( 31 )
  , ref_command varchar2 ( 2000 ) , ref_prcname varchar2 ( 30 ) , ref_username varchar2 ( 30 ) ,
  ref_rdbmsname varchar2 ( 30 ) , updt_cnt number null , updt_dt_tm date null , updt_id number null ,
   updt_task number null , updt_applctx number null , primary key ( ref_id ) )
  END ;Rdb
  RDB create table ccl_ref_logging_bind ( ref_id number , ref_type char ( 1 ) , ref_bind_num number ,
   param_num number , ref_text varchar2 ( 2000 ) , updt_cnt number null , updt_dt_tm date null ,
  updt_id number null , updt_task number null , updt_applctx number null , primary key ( ref_id ,
  ref_bind_num , param_num ) )
  END ;Rdb
 ENDIF
END GO
