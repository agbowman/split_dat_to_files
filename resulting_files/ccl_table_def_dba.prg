CREATE PROGRAM ccl_table_def:dba
 IF (( $1="DROP"))
  RDB drop table explorer_menu
  END ;Rdb
  RDB drop sequence explorer_menu_seq
  END ;Rdb
  RDB drop table explorer_menu_security
  END ;Rdb
  RDB drop table ccl_product_security
  END ;Rdb
  RDB drop table ccl_prompt_help
  END ;Rdb
  RDB drop sequence ccl_prompt_help_seq
  END ;Rdb
 ENDIF
 RDB create table explorer_menu ( menu_id number , menu_parent_id number , person_id number ,
 item_name char ( 30 ) , item_desc char ( 40 ) , item_type char ( 1 ) , active_ind number ,
 updt_dt_tm date , updt_id number , updt_task number , updt_cnt number , updt_applctx number ,
 constraint xpk_explorer_menu primary key ( menu_id ) using index tablespace i_discern ) tablespace
 d_discern
 END ;Rdb
 RDB create sequence explorer_menu_seq
 END ;Rdb
 RDB create table explorer_menu_security ( menu_id number , app_group_cd number , updt_dt_tm date ,
 updt_id number , updt_task number , updt_cnt number , updt_applctx number , constraint
 xpk_explorer_menu_security primary key ( menu_id , app_group_cd ) using index tablespace i_discern )
  tablespace d_discern
 END ;Rdb
 RDB create index xpk_explorer_security_group on explorer_menu_security ( app_group_cd ) tablespace
 i_discern
 END ;Rdb
 RDB create table ccl_product_security ( position_cd number , data_model_section varchar ( 80 ) ,
 updt_dt_tm date , updt_id number , updt_task number , updt_cnt number , updt_applctx number ,
 constraint xpk_ccl_product_security primary key ( position_cd , data_model_section ) using index
 tablespace i_discern ) tablespace d_discern
 END ;Rdb
 RDB create sequence ccl_prompt_help_seq
 END ;Rdb
 RDB create table ccl_prompt_help ( prompt_id number , program_name char ( 30 ) , prompt_num number ,
  control_flag number , help_codeset number , help_lookup varchar ( 1000 ) , active_ind number ,
 updt_dt_tm date , updt_id number , updt_task number , updt_cnt number , updt_applctx number ,
 constraint xpk_ccl_prompt_help primary key ( program_name , prompt_num ) using index tablespace
 i_discern ) tablespace d_discern
 END ;Rdb
 RDB create table ccl_program_doc ( program_name char ( 30 ) , description varchar ( 2000 ) ,
 start_val_ind number , multi_col_ind number , active_ind number , updt_dt_tm date , updt_id number ,
  updt_task number , updt_cnt number , updt_applctx number , constraint xpk_ccl_program_doc primary
 key ( program_name ) using index tablespace i_discern ) tablespace d_discern
 END ;Rdb
END GO
