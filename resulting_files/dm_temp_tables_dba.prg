CREATE PROGRAM dm_temp_tables:dba
 SET d_tspace = fillstring(30," ")
 SET i_tspace = fillstring(30," ")
 SET temp_buff = fillstring(200," ")
 SET temp_status = "F"
 DECLARE dtt_ora_purge = vc WITH protect, noconstant(" ")
 DECLARE dtt_ora_drop_index = vc WITH protect, noconstant(" ")
 DECLARE dtt_found = i4 WITH protect, noconstant(0)
 DECLARE dtt_iter = i4 WITH protect, noconstant(0)
 FREE RECORD schema_data
 RECORD schema_data(
   1 table_cnt = i4
   1 tables[*]
     2 table_name = vc
     2 index_cnt = i4
     2 indexes[*]
       3 index_name = vc
 )
 SELECT INTO "nl:"
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  HEAD REPORT
   ora_base_ver = 0
  DETAIL
   ora_base_ver = cnvtint(substring(1,(findstring(".",p.version,1,0) - 1),p.version))
   IF (ora_base_ver >= 10)
    dtt_ora_drop_index = "DROP INDEX"
   ENDIF
   IF (ora_base_ver >= 10)
    dtt_ora_purge = "PURGE"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM user_objects o
  WHERE o.object_name="DM_TEMP_UTC"
   AND o.object_type="PROCEDURE"
  DETAIL
   IF (o.status="VALID")
    temp_status = "T"
   ELSE
    temp_status = "I"
   ENDIF
  WITH nocounter
 ;end select
 IF (temp_status="F")
  CALL echo("******************************************************************")
  CALL echo("**   The DM_TEMP_UTC procedure does not exist                   **")
  CALL echo("**   PLEASE log in to SQLPLUS and compile DM_TEMP_UTC procedure **")
  CALL echo("**   For VMS:                                                   **")
  CALL echo("**            SQL>@cer_install:dm_temp_utc.sql                  **")
  CALL echo("**   For AIX:                                                   **")
  CALL echo("**            SQL>@$cer_install/dm_temp_utc.sql                 **")
  CALL echo("******************************************************************")
  GO TO exit_program
 ELSEIF (temp_status="I")
  CALL parser("rdb alter procedure dm_temp_utc compile go",1)
 ENDIF
 IF (currdbuser="CDBA")
  SET d_tspace = "D_TOOLKIT"
  SET i_tspace = "I_TOOLKIT"
 ELSE
  SET d_tspace = "D_SYS_MGMT"
  SET i_tspace = "I_SYS_MGMT"
  SELECT INTO "nl:"
   FROM user_tables u
   WHERE u.table_name="DM_CMB_EXCEPTION"
   DETAIL
    d_tspace = u.tablespace_name
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM user_indexes u
   WHERE u.table_name="DM_CMB_EXCEPTION"
   DETAIL
    i_tspace = u.tablespace_name
   WITH nocounter
  ;end select
 ENDIF
 SET ds_cnt = 0
 SET duc_cnt = 0
 SET dutc_cnt = 0
 SET duic_cnt = 0
 SET ducc_cnt = 0
 SET dutc_dt_chg_ind = 0
 SET dutc_dd_chg_ind = 0
 SET dutc_tn_chg_ind = 0
 SET dutc_coln_chg_ind = 0
 SET duc_cn_chg_ind = 0
 SET duc_rcn_chg_ind = 0
 SET duc_tn_chg_ind = 0
 SET duic_in_chg_ind = 0
 SET duic_tn_chg_ind = 0
 SET duic_coln_chg_ind = 0
 SET ducc_cn_chg_ind = 0
 SET ducc_rcn_chg_ind = 0
 SET ducc_tn_chg_ind = 0
 SET ducc_coln_chg_ind = 0
 SET ducc_ptn_chg_ind = 0
 SET ds_sn_chg_ind = 0
 SET ds_tn_chg_ind = 0
 SET ds_float_cnt = 0
 SELECT INTO "nl:"
  FROM user_tab_columns u
  WHERE u.table_name IN ("DM_SEGMENTS", "DM_USER_CONSTRAINTS", "DM_USER_TAB_COLS",
  "DM_USER_IND_COLUMNS", "DM_USER_CONS_COLUMNS")
  DETAIL
   IF (u.table_name="DM_SEGMENTS")
    ds_cnt = (ds_cnt+ 1)
    IF (u.data_type="FLOAT")
     ds_float_cnt = (ds_float_cnt+ 1)
    ENDIF
    IF (u.column_name="SEGMENT_NAME"
     AND u.data_length < 128)
     ds_sn_chg_ind = 1
    ENDIF
    IF (u.column_name="TABLE_NAME"
     AND u.data_length < 128)
     ds_tn_chg_ind = 1
    ENDIF
   ELSEIF (u.table_name="DM_USER_CONSTRAINTS")
    duc_cnt = (duc_cnt+ 1)
    IF (u.column_name="CONSTRAINT_NAME"
     AND u.data_length < 128)
     duc_cn_chg_ind = 1
    ENDIF
    IF (u.column_name="R_CONSTRAINT_NAME"
     AND u.data_length < 128)
     duc_rcn_chg_ind = 1
    ENDIF
    IF (u.column_name="TABLE_NAME"
     AND u.data_length < 128)
     duc_tn_chg_ind = 1
    ENDIF
   ELSEIF (u.table_name="DM_USER_TAB_COLS")
    dutc_cnt = (dutc_cnt+ 1)
    IF (u.column_name="DATA_TYPE"
     AND u.data_length <= 12)
     dutc_dt_chg_ind = 1
    ENDIF
    IF (u.column_name="DATA_DEFAULT"
     AND u.data_length=255)
     dutc_dd_chg_ind = 1
    ENDIF
    IF (u.column_name="TABLE_NAME"
     AND u.data_length < 128)
     dutc_tn_chg_ind = 1
    ENDIF
    IF (u.column_name="COLUMN_NAME"
     AND u.data_length < 128)
     dutc_coln_chg_ind = 1
    ENDIF
   ELSEIF (u.table_name="DM_USER_IND_COLUMNS")
    duic_cnt = (duic_cnt+ 1)
    IF (u.column_name="INDEX_NAME"
     AND u.data_length < 128)
     duic_in_chg_ind = 1
    ENDIF
    IF (u.column_name="TABLE_NAME"
     AND u.data_length < 128)
     duic_tn_chg_ind = 1
    ENDIF
    IF (u.column_name="COLUMN_NAME"
     AND u.data_length < 128)
     duic_coln_chg_ind = 1
    ENDIF
   ELSEIF (u.table_name="DM_USER_CONS_COLUMNS")
    ducc_cnt = (ducc_cnt+ 1)
    IF (u.column_name="CONSTRAINT_NAME"
     AND u.data_length < 128)
     ducc_cn_chg_ind = 1
    ENDIF
    IF (u.column_name="R_CONSTRAINT_NAME"
     AND u.data_length < 128)
     ducc_rcn_chg_ind = 1
    ENDIF
    IF (u.column_name="TABLE_NAME"
     AND u.data_length < 128)
     ducc_tn_chg_ind = 1
    ENDIF
    IF (u.column_name="COLUMN_NAME"
     AND u.data_length < 128)
     ducc_coln_chg_ind = 1
    ENDIF
    IF (u.column_name="PARENT_TABLE_NAME"
     AND u.data_length < 128)
     ducc_ptn_chg_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("****************************")
 CALL echo(build("ds_float_cnt:",ds_float_cnt))
 CALL echo("****************************")
 SELECT INTO "nl:"
  FROM user_indexes ui
  WHERE ui.table_name IN ("DM_SEGMENTS", "DM_USER_CONSTRAINTS", "DM_USER_TAB_COLS",
  "DM_USER_IND_COLUMNS", "DM_USER_CONS_COLUMNS")
   AND ui.uniqueness="NONUNIQUE"
  ORDER BY ui.table_name, ui.index_name
  HEAD REPORT
   schema_data->table_cnt = 0, stat = alterlist(schema_data->tables,0)
  HEAD ui.table_name
   schema_data->table_cnt = (schema_data->table_cnt+ 1), stat = alterlist(schema_data->tables,
    schema_data->table_cnt), schema_data->tables[schema_data->table_cnt].table_name = ui.table_name
  DETAIL
   schema_data->tables[schema_data->table_cnt].index_cnt = (schema_data->tables[schema_data->
   table_cnt].index_cnt+ 1), stat = alterlist(schema_data->tables[schema_data->table_cnt].indexes,
    schema_data->tables[schema_data->table_cnt].index_cnt), schema_data->tables[schema_data->
   table_cnt].indexes[schema_data->tables[schema_data->table_cnt].index_cnt].index_name = ui
   .index_name
  WITH nocounter
 ;end select
 IF (ds_cnt >= 14
  AND ds_float_cnt=10)
  CALL parser("rdb truncate table dm_segments go",1)
  CALL parser(concat("rdb alter table dm_segments drop primary key ",dtt_ora_drop_index," end go"),1)
  IF (assign(dtt_found,locateval(dtt_found,1,schema_data->table_cnt,"DM_SEGMENTS",schema_data->
    tables[dtt_found].table_name)) > 0)
   FOR (dtt_iter = 1 TO schema_data->tables[dtt_found].index_cnt)
     CALL parser(concat("rdb drop index ",schema_data->tables[dtt_found].indexes[dtt_iter].index_name,
       " end go"),1)
   ENDFOR
  ENDIF
  IF (ds_sn_chg_ind=1)
   CALL parser(concat("rdb alter table DM_SEGMENTS modify (SEGMENT_NAME VARCHAR2(128)) go"),1)
  ENDIF
  IF (ds_tn_chg_ind=1)
   CALL parser(concat("rdb alter table DM_SEGMENTS modify (TABLE_NAME VARCHAR2(128)) go"),1)
  ENDIF
  EXECUTE oragen3 "DM_SEGMENTS"
 ELSE
  CALL parser(concat("rdb drop table dm_segments cascade constraints ",dtt_ora_purge," end GO"),1)
  CALL parser("drop table dm_segments GO",1)
  CALL parser(concat("rdb create table dm_segments TABLESPACE ",trim(d_tspace)," as "),1)
  CALL parser("select  A.*, B.TABLE_NAME FROM USER_SEGMENTS A, USER_TABLES B ",1)
  CALL parser("WHERE 1=2 end go",1)
  CALL parser(concat(
    "rdb alter table dm_segments modify (bytes float, blocks float, extents float, initial_extent float,",
    "next_extent float, min_extents float, max_extents float, ",
    "pct_increase float, freelists float, freelist_groups float ) go"),1)
  EXECUTE oragen3 "DM_SEGMENTS"
 ENDIF
 INSERT  FROM dm_segments ds
  (ds.segment_name, ds.segment_type, ds.blocks,
  ds.bytes, ds.extents, ds.freelists,
  ds.freelist_groups, ds.initial_extent, ds.max_extents,
  ds.min_extents, ds.next_extent, ds.pct_increase,
  ds.tablespace_name, ds.table_name)(SELECT
   c.segment_name, c.segment_type, c.blocks,
   c.bytes, c.extents, c.freelists,
   c.freelist_groups, c.initial_extent, c.max_extents,
   c.min_extents, c.next_extent, c.pct_increase,
   c.tablespace_name, c.segment_name
   FROM user_segments c
   WHERE c.segment_type="TABLE")
 ;end insert
 INSERT  FROM dm_segments ds
  (ds.segment_name, ds.segment_type, ds.blocks,
  ds.bytes, ds.extents, ds.freelists,
  ds.freelist_groups, ds.initial_extent, ds.max_extents,
  ds.min_extents, ds.next_extent, ds.pct_increase,
  ds.tablespace_name, ds.table_name)(SELECT
   c.segment_name, c.segment_type, c.blocks,
   c.bytes, c.extents, c.freelists,
   c.freelist_groups, c.initial_extent, c.max_extents,
   c.min_extents, c.next_extent, c.pct_increase,
   c.tablespace_name, b.table_name
   FROM user_indexes b,
    user_segments c
   WHERE c.segment_type="INDEX"
    AND c.segment_name=b.index_name)
 ;end insert
 COMMIT
 CALL parser("rdb alter table dm_segments ",1)
 CALL parser("add constraint xpkdm_segments primary key (segment_name, segment_type) ",1)
 CALL parser(concat("USING INDEX TABLESPACE ",trim(i_tspace)," end go"),1)
 CALL parser("rdb create index xie1dm_segments on dm_segments(table_name) ",1)
 CALL parser(concat("TABLESPACE ",trim(i_tspace)," end go"),1)
 IF (duc_cnt >= 8)
  CALL parser("rdb truncate table dm_user_constraints go",1)
  IF (assign(dtt_found,locateval(dtt_found,1,schema_data->table_cnt,"DM_USER_CONSTRAINTS",schema_data
    ->tables[dtt_found].table_name)) > 0)
   FOR (dtt_iter = 1 TO schema_data->tables[dtt_found].index_cnt)
     CALL parser(concat("rdb drop index ",schema_data->tables[dtt_found].indexes[dtt_iter].index_name,
       " end go"),1)
   ENDFOR
  ENDIF
  IF (duc_cn_chg_ind=1)
   CALL parser(concat("rdb alter table DM_USER_CONSTRAINTS modify (CONSTRAINT_NAME VARCHAR2(128)) go"
     ),1)
  ENDIF
  IF (duc_rcn_chg_ind=1)
   CALL parser(concat(
     "rdb alter table DM_USER_CONSTRAINTS modify (R_CONSTRAINT_NAME VARCHAR2(128)) go"),1)
  ENDIF
  IF (duc_tn_chg_ind=1)
   CALL parser(concat("rdb alter table DM_USER_CONSTRAINTS modify (TABLE_NAME VARCHAR2(128)) go"),1)
  ENDIF
  EXECUTE oragen3 "DM_USER_CONSTRAINTS"
 ELSE
  CALL parser(concat("rdb drop table dm_user_constraints cascade constraints ",dtt_ora_purge,
    " end GO"),1)
  CALL parser("drop table dm_user_constraints go ",1)
  CALL parser(concat("rdb create table dm_user_constraints TABLESPACE ",trim(d_tspace)," as select "),
   1)
  CALL parser(
   "owner,constraint_name,constraint_type,table_name,r_owner,r_constraint_name,delete_rule,status ",1
   )
  CALL parser("from user_constraints where 1=2 end go ",1)
  EXECUTE oragen3 "DM_USER_CONSTRAINTS"
 ENDIF
 INSERT  FROM dm_user_constraints duc
  (duc.owner, duc.constraint_name, duc.constraint_type,
  duc.table_name, duc.r_owner, duc.r_constraint_name,
  duc.delete_rule, duc.status)(SELECT
   c.owner, c.constraint_name, c.constraint_type,
   c.table_name, c.r_owner, c.r_constraint_name,
   c.delete_rule, c.status
   FROM user_constraints c
   WHERE c.owner=currdbuser
    AND c.constraint_type IN ("R", "P", "U"))
 ;end insert
 COMMIT
 CALL parser("rdb create index xie1dm_user_constraints on dm_user_constraints(table_name) ",1)
 CALL parser(concat("TABLESPACE ",trim(i_tspace)," end go "),1)
 CALL parser("rdb create index xie2dm_user_constraints on dm_user_constraints(r_constraint_name) ",1)
 CALL parser(concat("TABLESPACE ",trim(i_tspace)," end go "),1)
 CALL parser("rdb create index xie3dm_user_constraints on dm_user_constraints(constraint_name) ",1)
 CALL parser(concat("TABLESPACE ",trim(i_tspace)," end go "),1)
 IF (dutc_cnt >= 8)
  CALL parser("rdb truncate table dm_user_tab_cols go",1)
  IF (assign(dtt_found,locateval(dtt_found,1,schema_data->table_cnt,"DM_USER_TAB_COLS",schema_data->
    tables[dtt_found].table_name)) > 0)
   FOR (dtt_iter = 1 TO schema_data->tables[dtt_found].index_cnt)
     CALL parser(concat("rdb drop index ",schema_data->tables[dtt_found].indexes[dtt_iter].index_name,
       " end go"),1)
   ENDFOR
  ENDIF
  IF (dutc_dt_chg_ind=1)
   CALL parser(concat("rdb alter table DM_USER_TAB_COLS modify (DATA_TYPE VARCHAR2(30)) go"),1)
  ENDIF
  IF (dutc_dd_chg_ind=1)
   CALL parser(concat("rdb alter table DM_USER_TAB_COLS modify (DATA_DEFAULT VARCHAR2(500)) go"),1)
  ENDIF
  IF (dutc_tn_chg_ind=1)
   CALL parser(concat("rdb alter table DM_USER_TAB_COLS modify (TABLE_NAME VARCHAR2(128)) go"),1)
  ENDIF
  IF (dutc_coln_chg_ind=1)
   CALL parser(concat("rdb alter table DM_USER_TAB_COLS modify (COLUMN_NAME VARCHAR2(128)) go"),1)
  ENDIF
  EXECUTE oragen3 "DM_USER_TAB_COLS"
 ELSE
  CALL parser(concat("rdb drop table dm_user_tab_cols cascade constraints ",dtt_ora_purge," end GO"),
   1)
  CALL parser("drop table dm_user_tab_cols go          ",1)
  CALL parser("rdb create table dm_user_tab_cols ",1)
  CALL parser(" (TABLE_NAME      VARCHAR2(128),",1)
  CALL parser("  COLUMN_NAME     VARCHAR2(128),",1)
  CALL parser("  TABLESPACE_NAME VARCHAR2(30),",1)
  CALL parser("  DATA_TYPE       VARCHAR2(30),",1)
  CALL parser("  DATA_LENGTH     NUMBER,",1)
  CALL parser("  NULLABLE        VARCHAR2(1),",1)
  CALL parser("  COLUMN_ID       NUMBER,",1)
  CALL parser("  DATA_DEFAULT    VARCHAR2(500)) ",1)
  CALL parser(concat("TABLESPACE ",trim(d_tspace)," end go "),1)
  EXECUTE oragen3 "DM_USER_TAB_COLS"
  CALL parser("rdb alter procedure dm_temp_utc compile go",1)
 ENDIF
 CALL parser('RDB ASIS(" begin DM_TEMP_UTC; end;") go',1)
 COMMIT
 CALL parser("rdb create index xie1dm_user_tab_cols on dm_user_tab_cols(table_name, column_name) ",1)
 CALL parser(concat("TABLESPACE ",trim(i_tspace)," end go "),1)
 IF (duic_cnt >= 7)
  CALL parser("rdb truncate table dm_user_ind_columns go",1)
  IF (assign(dtt_found,locateval(dtt_found,1,schema_data->table_cnt,"DM_USER_IND_COLUMNS",schema_data
    ->tables[dtt_found].table_name)) > 0)
   FOR (dtt_iter = 1 TO schema_data->tables[dtt_found].index_cnt)
     CALL parser(concat("rdb drop index ",schema_data->tables[dtt_found].indexes[dtt_iter].index_name,
       " end go"),1)
   ENDFOR
  ENDIF
  IF (duic_in_chg_ind=1)
   CALL parser(concat("rdb alter table DM_USER_IND_COLUMNS modify (INDEX_NAME VARCHAR2(128)) go"),1)
  ENDIF
  IF (duic_tn_chg_ind=1)
   CALL parser(concat("rdb alter table DM_USER_IND_COLUMNS modify (TABLE_NAME VARCHAR2(128)) go"),1)
  ENDIF
  IF (duic_coln_chg_ind=1)
   CALL parser(concat("rdb alter table DM_USER_IND_COLUMNS modify (COLUMN_NAME VARCHAR2(128)) go"),1)
  ENDIF
  EXECUTE oragen3 "DM_USER_IND_COLUMNS"
 ELSE
  CALL parser(concat("rdb drop table dm_user_ind_columns cascade constraints ",dtt_ora_purge,
    " end GO"),1)
  CALL parser("drop table dm_user_ind_columns go  ",1)
  CALL parser("rdb create table dm_user_ind_columns",1)
  CALL parser("(table_owner varchar2(30),",1)
  CALL parser(" table_name varchar2(128),",1)
  CALL parser(" index_name varchar2(128),",1)
  CALL parser(" tablespace_name varchar2(30),",1)
  CALL parser(" column_name varchar2(128),",1)
  CALL parser(" column_position number,",1)
  CALL parser(" uniqueness varchar2(9))",1)
  CALL parser(concat(" tablespace ",trim(d_tspace)," end go"),1)
  EXECUTE oragen3 "DM_USER_IND_COLUMNS"
 ENDIF
 INSERT  FROM dm_user_ind_columns dui
  (dui.table_owner, dui.table_name, dui.index_name,
  dui.tablespace_name, dui.column_name, dui.column_position,
  dui.uniqueness)(SELECT
   a.table_owner, a.table_name, a.index_name,
   nullval(a.tablespace_name," "), b.column_name, b.column_position,
   a.uniqueness
   FROM user_ind_columns b,
    user_indexes a
   WHERE a.table_owner=currdbuser
    AND a.table_name=b.table_name
    AND a.index_name=b.index_name)
 ;end insert
 COMMIT
 CALL parser("rdb create index xie1dm_user_ind_columns on ",1)
 CALL parser("dm_user_ind_columns(table_name, index_name, column_name) ",1)
 CALL parser(concat("TABLESPACE ",trim(i_tspace)," end go "),1)
 CALL parser("rdb create index xie2dm_user_ind_columns on dm_user_ind_columns(index_name) ",1)
 CALL parser(concat("TABLESPACE ",trim(i_tspace)," end go "),1)
 IF (ducc_cnt >= 11)
  CALL parser("rdb truncate table dm_user_cons_columns go",1)
  IF (assign(dtt_found,locateval(dtt_found,1,schema_data->table_cnt,"DM_USER_CONS_COLUMNS",
    schema_data->tables[dtt_found].table_name)) > 0)
   FOR (dtt_iter = 1 TO schema_data->tables[dtt_found].index_cnt)
     CALL parser(concat("rdb drop index ",schema_data->tables[dtt_found].indexes[dtt_iter].index_name,
       " end go"),1)
   ENDFOR
  ENDIF
  IF (ducc_cn_chg_ind=1)
   CALL parser(concat(
     "rdb alter table DM_USER_CONS_COLUMNS modify (CONSTRAINT_NAME VARCHAR2(128)) go"),1)
  ENDIF
  IF (ducc_rcn_chg_ind=1)
   CALL parser(concat(
     "rdb alter table DM_USER_CONS_COLUMNS modify (R_CONSTRAINT_NAME VARCHAR2(128)) go"),1)
  ENDIF
  IF (ducc_tn_chg_ind=1)
   CALL parser(concat("rdb alter table DM_USER_CONS_COLUMNS modify (TABLE_NAME VARCHAR2(128)) go"),1)
  ENDIF
  IF (ducc_coln_chg_ind=1)
   CALL parser(concat("rdb alter table DM_USER_CONS_COLUMNS modify (COLUMN_NAME VARCHAR2(128)) go"),1
    )
  ENDIF
  IF (ducc_ptn_chg_ind=1)
   CALL parser(concat(
     "rdb alter table DM_USER_CONS_COLUMNS modify (PARENT_TABLE_NAME VARCHAR2(128)) go"),1)
  ENDIF
  EXECUTE oragen3 "DM_USER_CONS_COLUMNS"
 ELSE
  CALL parser(concat("rdb drop table dm_user_cons_columns cascade constraints ",dtt_ora_purge,
    " end GO"),1)
  CALL parser("drop table dm_user_cons_columns go ",1)
  CALL parser("rdb create table dm_user_cons_columns  ",1)
  CALL parser("(OWNER            VARCHAR2(30),  ",1)
  CALL parser("CONSTRAINT_NAME   VARCHAR2(128),   ",1)
  CALL parser("CONSTRAINT_TYPE   CHAR(1),        ",1)
  CALL parser("TABLE_NAME        VARCHAR2(128),   ",1)
  CALL parser("R_OWNER           VARCHAR2(30),   ",1)
  CALL parser("R_CONSTRAINT_NAME VARCHAR2(128),   ",1)
  CALL parser("PARENT_TABLE_NAME VARCHAR2(128),   ",1)
  CALL parser("STATUS            CHAR(8),        ",1)
  CALL parser("STATUS_IND        NUMBER,         ",1)
  CALL parser("COLUMN_NAME       VARCHAR2(128),   ",1)
  CALL parser("POSITION          NUMBER)         ",1)
  CALL parser(concat("TABLESPACE ",trim(d_tspace)," end go "),1)
  EXECUTE oragen3 "DM_USER_CONS_COLUMNS"
 ENDIF
 INSERT  FROM dm_user_cons_columns ducc
  (ducc.owner, ducc.constraint_name, ducc.constraint_type,
  ducc.table_name, ducc.r_owner, ducc.r_constraint_name,
  ducc.status, ducc.status_ind, ducc.column_name,
  ducc.position)(SELECT
   c.owner, c.constraint_name, c.constraint_type,
   c.table_name, c.r_owner, c.r_constraint_name,
   c.status, evaluate(c.status,"ENABLED",1,0), cc.column_name,
   cc.position
   FROM user_cons_columns cc,
    user_constraints c
   WHERE c.owner=user
    AND c.constraint_type IN ("P", "U")
    AND cc.owner=c.owner
    AND cc.table_name=c.table_name
    AND cc.constraint_name=c.constraint_name)
 ;end insert
 INSERT  FROM dm_user_cons_columns ducc
  (ducc.owner, ducc.constraint_name, ducc.constraint_type,
  ducc.table_name, ducc.r_owner, ducc.r_constraint_name,
  ducc.parent_table_name, ducc.status, ducc.status_ind,
  ducc.column_name, ducc.position)(SELECT
   c.owner, c.constraint_name, c.constraint_type,
   c.table_name, c.r_owner, c.r_constraint_name,
   c1.table_name, c.status, evaluate(c.status,"ENABLED",1,0),
   cc.column_name, cc.position
   FROM user_cons_columns cc,
    user_constraints c1,
    user_constraints c
   WHERE c.owner=user
    AND c.constraint_type="R"
    AND c1.owner=c.r_owner
    AND c1.constraint_name=c.r_constraint_name
    AND cc.owner=c.owner
    AND cc.table_name=c.table_name
    AND cc.constraint_name=c.constraint_name)
 ;end insert
 COMMIT
 CALL parser("rdb create index xie1dm_user_cons_columns on dm_user_cons_columns(table_name, ",1)
 CALL parser(concat("constraint_type,constraint_name, position) TABLESPACE ",trim(i_tspace),
   " end go "),1)
 CALL parser("rdb create index xie2dm_user_cons_columns on dm_user_cons_columns(parent_table_name) ",
  1)
 CALL parser(concat("TABLESPACE ",trim(i_tspace)," end go "),1)
 CALL parser("rdb create index xie3dm_user_cons_columns on dm_user_cons_columns(constraint_name) ",1)
 CALL parser(concat("TABLESPACE ",trim(i_tspace)," end go "),1)
 CALL parser("rdb create index xie4dm_user_cons_columns on dm_user_cons_columns(r_constraint_name) ",
  1)
 CALL parser(concat("TABLESPACE ",trim(i_tspace)," end go "),1)
 DELETE  FROM dm_info
  WHERE info_name="TEMPLASTBLD"
  WITH nocounter
 ;end delete
 INSERT  FROM dm_info
  SET info_domain = "DATA MANAGEMENT", info_name = "TEMPLASTBLD", info_date = cnvtdatetime(curdate,
    curtime3),
   info_char = null, info_number = null, info_long_id = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_applctx = 0, updt_cnt = 0,
   updt_id = 0, updt_task = 0
  WITH nocounter
 ;end insert
 COMMIT
#exit_program
END GO
