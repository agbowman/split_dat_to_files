CREATE PROGRAM dm_ocd_create_adm_tbls_int:dba
 SELECT INTO "nl:"
  i.info_number
  FROM dm_info i,
   dm_environment e
  WHERE i.info_domain="DATA MANAGEMENT"
   AND i.info_name="DM_ENV_ID"
   AND i.info_number=e.environment_id
  DETAIL
   v5_con_str = trim(e.v500_connect_string)
  WITH nocounter
 ;end select
 SET count = 0
 SET errcode = 0
 SET errmsg = fillstring(132," ")
 SET command = fillstring(132," ")
 FREE RECORD errlog
 RECORD errlog(
   1 count = i4
   1 qual[*]
     2 errmsg = vc
     2 command = vc
 )
 SET errlog->count = 0
 SET stat = alterlist(errlog->qual,0)
 IF (( $1="!KNOWN!"))
  SET connect_str = concat("cdba/cdba@",trim( $2))
 ELSE
  SET connect_str = concat(trim( $1),"/",trim( $3),"@",trim( $2))
 ENDIF
 EXECUTE dm_add_cki_cv
 CALL parser("free define oraclesystem go",1)
 CALL parser(concat("define oraclesystem '",trim(connect_str),"' go"),1)
 SELECT INTO "nl:"
  a.object_type
  FROM user_objects a
  WHERE a.object_name="DM_SCHEMA_VERSION"
   AND a.object_type="TABLE"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET parser_count = 0
  SET parser_buffer[500] = fillstring(132," ")
  SET stat = initarray(parser_buffer,fillstring(132," "))
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_ALPHA_FEATURES"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_alpha_features"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "(alpha_feature_nbr NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "description VARCHAR2(80),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rev_number FLOAT,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "sponsor_client_id CHAR(10),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "create_dt_tm date)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_alpha_features"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "add constraint XPKDM_ALPHA_FEATURES"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "primary key (alpha_feature_nbr)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "using index tablespace I_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_OCD_FEATURES"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_ocd_features"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "(alpha_feature_nbr NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "feature_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "schema_ind NUMBER)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_ocd_features"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "add constraint XPKDM_OCD_FEATURES"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "primary key (alpha_feature_nbr,feature_number)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "using index tablespace I_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_ALPHA_FEATURES_ENV"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_alpha_features_env"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "(alpha_feature_nbr NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "environment_id NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "start_dt_tm date,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "end_dt_tm date,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "status varchar2(100) )"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_alpha_features_env"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "add constraint XPKDM_ALPHA_FEATURES_ENV"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "primary key (alpha_feature_nbr,environment_id)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "using index tablespace I_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
   SET len = 0
   SELECT INTO "nl:"
    FROM user_tab_columns u
    WHERE u.table_name="DM_ALPHA_FEATURES_ENV"
     AND u.column_name="STATUS"
    DETAIL
     len = u.data_length
    WITH nocounter
   ;end select
   IF (len < 100)
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "rdb alter table dm_alpha_features_env"
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "modify (status VARCHAR2(100))"
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "go"
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_TABLES"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_tables"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "(select table_name, tablespace_name, pct_increase, pct_used, pct_free,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_applctx, updt_dt_tm, updt_cnt, updt_id, updt_task"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_tables where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_tables"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null,feature_number number)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
   SELECT INTO "nl:"
    FROM user_tab_columns u
    WHERE u.table_name="DM_AFD_TABLES"
     AND u.column_name="FEATURE_NUMBER"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "rdb alter table dm_afd_tables"
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "add (feature_number number)"
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "go"
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_COLUMNS"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_columns"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "(select table_name, column_name, column_seq, data_type, data_length, "
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "data_precision, data_scale, nullable, updt_applctx, updt_dt_tm, updt_cnt,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_id, updt_task, data_default"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_columns where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_columns"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null) "
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_CONSTRAINTS"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_constraints"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "(select table_name, constraint_name, constraint_type, parent_table_name,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "status_ind, updt_applctx, updt_dt_tm, updt_cnt, updt_id, updt_task,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "parent_table_columns, r_constraint_name"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_constraints where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_constraints"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null) "
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_CONS_COLUMNS"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_cons_columns"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "(select table_name, constraint_name, column_name, position, updt_applctx,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_dt_tm, updt_cnt, updt_id, updt_task"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_cons_columns where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_cons_columns"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_INDEXES"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_indexes"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "(select index_name, table_name, tablespace_name, pct_increase, pct_free,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "unique_ind, updt_applctx, updt_dt_tm, updt_cnt, updt_id, updt_task"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_indexes where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_indexes"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_INDEX_COLUMNS"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_index_columns "
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "(select index_name, table_name, column_name, column_position, updt_applctx,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_dt_tm, updt_cnt, updt_id, updt_task"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_index_columns where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_index_columns"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_CODE_VALUE_SET"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_code_value_set"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "(select CODE_SET, DISPLAY, DISPLAY_KEY, DESCRIPTION, DEFINITION, TABLE_NAME,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "CONTRIBUTOR, OWNER_MODULE,CACHE_IND,EXTENSION_IND, ADD_ACCESS_IND,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "CHG_ACCESS_IND, DEL_ACCESS_IND, INQ_ACCESS_IND, DOMAIN_QUALIFIER_IND,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "DOMAIN_CODE_SET, UPDT_DT_TM, UPDT_ID, UPDT_CNT, UPDT_TASK, UPDT_APPLCTX,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "CODE_SET_HITS, CODE_VALUES_CNT, DEF_DUP_RULE_FLAG, CDF_MEANING_DUP_IND,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "DISPLAY_KEY_DUP_IND, ACTIVE_IND_DUP_IND, DISPLAY_DUP_IND, ALIAS_DUP_IND"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_code_value_set where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_code_value_set"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null,feature_number number)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
   SELECT INTO "nl:"
    FROM user_tab_columns u
    WHERE u.table_name="DM_AFD_CODE_VALUE_SET"
     AND u.column_name="FEATURE_NUMBER"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "rdb alter table dm_afd_code_value_set"
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "add (feature_number number)"
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "go"
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_CODE_VALUE"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_code_value"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "(select code_value, code_set, cdf_meaning, display, display_key, description,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "definition, collation_seq, active_type_cd, active_ind, active_dt_tm,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "inactive_dt_tm, updt_applctx, updt_dt_tm, updt_cnt, updt_id, updt_task,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "begin_effective_dt_tm, end_effective_dt_tm, data_status_cd, data_status_dt_tm,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "data_status_prsnl_id, active_status_prsnl_id, cki"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_code_value where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_code_value"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
   SELECT INTO "nl:"
    FROM user_tab_columns u
    WHERE u.table_name="DM_AFD_CODE_VALUE"
     AND u.column_name="CKI"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "rdb alter table dm_afd_code_value"
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "add (CKI VARCHAR2(255))"
    SET parser_count = (parser_count+ 1)
    SET parser_buffer[parser_count] = "go"
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_COMMON_DATA_FOUNDATION"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_common_data_foundation"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "(select code_set, cdf_meaning, display, definition, updt_applctx,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_dt_tm, updt_cnt, updt_id, updt_task"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_common_data_foundation where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_common_data_foundation"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_CODE_SET_EXTENSION"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_code_set_extension"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "(select code_set, field_name, field_seq, field_type, field_len, field_prompt,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "field_in_mask, field_out_mask, validation_condition, validation_code_set,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "action_field, field_default, field_help, updt_applctx,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_dt_tm, updt_cnt, updt_id, updt_task"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_code_set_extension where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_code_set_extension"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_CODE_VALUE_ALIAS"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_code_value_alias"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "(select code_set, contributor_source_cd, alias, code_value, primary_ind,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "updt_applctx, updt_dt_tm, updt_cnt, updt_id, updt_task , alias_type_meaning"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_code_value_alias where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_code_value_alias"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_AFD_CODE_VALUE_EXTENSION"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_afd_code_value_extension"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT as"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "(select code_value, field_name, code_set, updt_applctx,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] =
   "updt_dt_tm, updt_cnt, updt_id, updt_task , field_type, field_value"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "from dm_adm_code_value_extension where 1=2)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_afd_code_value_extension"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "ADD (alpha_feature_nbr number not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_OCD_APPLICATION"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_ocd_application"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "(application_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "owner VARCHAR2(20),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "description VARCHAR2(200),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "active_dt_tm DATE,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "active_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "last_localized_dt_tm DATE,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "text VARCHAR2(500),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "inactive_dt_tm DATE,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "log_access_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "application_ini_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "object_name VARCHAR2(60),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "direct_access_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "log_level NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "request_log_level NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "min_version_required VARCHAR2(60),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "disable_cache_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "module VARCHAR2(60),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "feature_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "deleted_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "schema_date DATE not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_dt_tm DATE not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_id NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_task NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_cnt NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_applctx NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "alpha_feature_nbr NUMBER not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_ocd_application"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "add constraint XPKDM_OCD_APPLICATION"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "primary key (alpha_feature_nbr,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "application_number, feature_number)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "using index tablespace I_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_OCD_TASK"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_ocd_task"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "(task_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "description VARCHAR2(200),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "active_dt_tm DATE,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "active_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "inactive_dt_tm DATE,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "text VARCHAR2(500),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "subordinate_task_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "optional_required_flag NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "feature_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "deleted_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "schema_date DATE not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_dt_tm DATE not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_id NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_task NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_cnt NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_applctx NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "alpha_feature_nbr NUMBER not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_ocd_task"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "add constraint XPKDM_OCD_TASK"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "primary key (alpha_feature_nbr,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "task_number, feature_number)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "using index tablespace I_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_OCD_REQUEST"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_ocd_request"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "(request_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "description VARCHAR2(200),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "request_name VARCHAR2(30),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "active_dt_tm DATE,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "active_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "inactive_dt_tm DATE,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "text VARCHAR2(500),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "prolog_script VARCHAR2(30),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "epilog_script VARCHAR2(30),"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "write_to_que_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "requestclass NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "cachetime NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "feature_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "deleted_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "schema_date DATE not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_dt_tm DATE not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_id NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_task NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_cnt NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_applctx NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "alpha_feature_nbr NUMBER not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_ocd_request"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "add constraint XPKDM_OCD_REQUEST"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "primary key (alpha_feature_nbr,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "request_number, feature_number)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "using index tablespace I_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_OCD_APP_TASK_R"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_ocd_app_task_r"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "(application_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "task_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "feature_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "deleted_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "schema_date DATE not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_dt_tm DATE not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_id NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_task NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_cnt NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_applctx NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "alpha_feature_nbr NUMBER not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_ocd_app_task_r"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "add constraint XPKDM_OCD_APP_TASK_R"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "primary key (alpha_feature_nbr,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "application_number, task_number,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "feature_number)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "using index tablespace I_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_OCD_TASK_REQ_R"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb create table dm_ocd_task_req_r"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "(task_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "request_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "feature_number NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "deleted_ind NUMBER,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "schema_date DATE not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_dt_tm DATE not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_id NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_task NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_cnt NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "updt_applctx NUMBER not null,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "alpha_feature_nbr NUMBER not null)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "storage (initial 16K next 16K)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "tablespace D_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "rdb alter table dm_ocd_task_req_r"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "add constraint XPKDM_OCD_TASK_REQ_R"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "primary key (alpha_feature_nbr,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "task_number, request_number,"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "feature_number)"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "using index tablespace I_TOOLKIT"
   SET parser_count = (parser_count+ 1)
   SET parser_buffer[parser_count] = "go"
  ELSE
   SET x = 0
  ENDIF
  FOR (count = 1 TO parser_count)
    IF (findstring("rdb",parser_buffer[count])=1)
     IF (findstring("alter table",parser_buffer[count]) > 0)
      SET command = concat(trim(parser_buffer[count])," ",trim(parser_buffer[(count+ 1)]))
     ELSE
      SET command = parser_buffer[count]
     ENDIF
     SET errcode = error(errmsg,1)
    ENDIF
    CALL parser(parser_buffer[count])
    IF (findstring("go",parser_buffer[count])=1)
     SET errcode = error(errmsg,0)
     IF (errcode != 0)
      SET errlog->count = (errlog->count+ 1)
      SET stat = alterlist(errlog->qual,errlog->count)
      SET errlog->qual[errlog->count].errmsg = errmsg
      SET errlog->qual[errlog->count].command = command
     ENDIF
     SET command = " "
     SET errcode = 0
    ENDIF
  ENDFOR
 ENDIF
 IF ((errlog->count > 0))
  SELECT INTO "DM_OCD_CREATE_TABLES.LOG"
   FROM (dummyt d  WITH seq = value(errlog->count))
   DETAIL
    "ERROR ", errlog->count";L;", row + 1,
    errlog->command, row + 1, errlog->errmsg,
    row + 1, row + 1
   WITH nocounter, maxrow = 1, maxcol = 512,
    noheading, format = variable, formfeed = none
  ;end select
  GO TO end_program
 ELSE
  SELECT INTO "DM_OCD_CREATE_TABLES.LOG"
   FROM dual
   DETAIL
    "NO ERRORS WHEN CREATING TABLES"
   WITH nocounter, maxrow = 1, maxcol = 512,
    noheading, format = variable, formfeed = none
  ;end select
 ENDIF
#end_program
END GO
