CREATE PROGRAM dm_load_purge_table_indexes:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Failed starting dm_load_purge_table_indexes..."
 DECLARE dlpti_tablecnt = i4 WITH protect, noconstant(0)
 DECLARE dlpti_errmsg = vc WITH protect, noconstant("")
 DECLARE dlpti_curcolumncnt = i4 WITH protect, noconstant(0)
 DECLARE dlpti_loop = i4 WITH protect, noconstant(0)
 DECLARE dlpti_lvalidx = i4 WITH protect, noconstant(0)
 DECLARE dlpti_adminlink = vc WITH protect, noconstant("")
 DECLARE dlpti_linkexistsind = i2 WITH protect, noconstant(0)
 DECLARE dlpti_hasadmintablesind = i2 WITH protect, noconstant(0)
 DECLARE dlpti_periodpos = i4 WITH protect, noconstant(0)
 DECLARE dlpti_columncnt = i4 WITH protect, noconstant(0)
 DECLARE dlpti_maxcolumncnt = i4 WITH protect, noconstant(0)
 DECLARE dlpti_betterindexind = i2 WITH protect, noconstant(0)
 DECLARE dlpti_columnloop = i4 WITH protect, noconstant(0)
 DECLARE dlpti_hasindexinfoind = i2 WITH protect, noconstant(0)
 DECLARE dlpti_check_user_objects(dlpticuo_usertablename=vc,dlpticuo_parserstmt=vc) = null
 DECLARE dlpti_check_pk_info(dlpticpki_userconsname=vc,dlpticpki_userobjsname=vc,
  dlpticpki_userindcolname=vc,dlpticpki_usertabcolname=vc,dlpticpki_parserstmt=vc,
  dlpticpki_adminind=i2) = null
 DECLARE dlpti_check_nonpk_info(dlpticni_userindname=vc,dlpticni_userobjsname=vc,
  dlpticni_userindcolname=vc,dlpticni_usertabcolname=vc,dlpticni_parserstmt=vc,
  dlpticni_adminind=i2) = null
 FREE RECORD dlpti_tables
 RECORD dlpti_tables(
   1 list_0[*]
     2 tablename = vc
     2 indexname = vc
     2 hasvalididxind = i2
     2 haspkidx = i2
     2 hasnonpkidx = i2
     2 lastddltime = dq8
     2 isadminind = i2
     2 columns[*]
       3 columnname = vc
       3 datatype = vc
       3 precedence = i2
 )
 FREE RECORD dlpti_curcolumns
 RECORD dlpti_curcolumns(
   1 list_0[*]
     2 columnname = vc
     2 datatype = vc
     2 precedence = i2
 )
 SELECT DISTINCT INTO "nl:"
  ds.db_link
  FROM dba_synonyms ds
  WHERE ds.synonym_name="DM_ENVIRONMENT"
  DETAIL
   dlpti_periodpos = findstring(".WORLD",ds.db_link), dlpti_adminlink = substring(1,(dlpti_periodpos
     - 1),ds.db_link), dlpti_linkexistsind = 1
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  dpt.parent_table, dpti.index_name, dpti.last_ddl_dt_tm,
  dpti.admin_table_ind
  FROM dm_purge_table dpt,
   dm_purge_table_index dpti
  PLAN (dpt)
   JOIN (dpti
   WHERE dpti.table_name=outerjoin(dpt.parent_table))
  DETAIL
   dlpti_tablecnt = (dlpti_tablecnt+ 1)
   IF (mod(dlpti_tablecnt,10)=1)
    stat = alterlist(dlpti_tables->list_0,(dlpti_tablecnt+ 9))
   ENDIF
   dlpti_tables->list_0[dlpti_tablecnt].tablename = cnvtupper(dpt.parent_table)
   IF (dpti.index_name > " ")
    dlpti_hasindexinfoind = 1, dlpti_tables->list_0[dlpti_tablecnt].indexname = cnvtupper(dpti
     .index_name), dlpti_tables->list_0[dlpti_tablecnt].lastddltime = dpti.last_ddl_dt_tm,
    dlpti_tables->list_0[dlpti_tablecnt].isadminind = dpti.admin_table_ind
   ENDIF
  FOOT REPORT
   stat = alterlist(dlpti_tables->list_0,dlpti_tablecnt)
  WITH nocounter
 ;end select
 IF (error(dlpti_errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed in select parent tables: ",dlpti_errmsg)
  GO TO exit_script
 ENDIF
 IF (dlpti_tablecnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Success; no parent tables exists in the database."
  GO TO exit_script
 ENDIF
 CALL echo("Comparing index information for tables...")
 CALL dlpti_check_user_objects("USER_OBJECTS","dlpti_tables->list_0[d.seq].isAdminInd = 0")
 IF (dlpti_linkexistsind=1)
  CALL echo("Comparing index information for potential admin tables...")
  CALL dlpti_check_user_objects(concat("USER_OBJECTS@",dlpti_adminlink),
   "dlpti_tables->list_0[d.seq].isAdminInd = 1")
 ENDIF
 IF (dlpti_hasindexinfoind=1)
  FOR (dlpti_loop = 1 TO dlpti_tablecnt)
    IF ((dlpti_tables->list_0[dlpti_loop].hasvalididxind=0))
     DELETE  FROM dm_purge_table_index dpti
      WHERE (dpti.table_name=dlpti_tables->list_0[dlpti_loop].tablename)
     ;end delete
     IF (error(dlpti_errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to purge index record for '",dlpti_tables->list_0[
       dlpti_loop].tablename,"': ",dlpti_errmsg)
      GO TO exit_script
     ELSE
      COMMIT
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 CALL echo("Looking for primary key indexes...")
 CALL dlpti_check_pk_info("USER_CONSTRAINTS","USER_OBJECTS","USER_IND_COLUMNS","USER_TAB_COLUMNS",
  "dlpti_tables->list_0[d.seq].isAdminInd = 0",
  0)
 IF (dlpti_linkexistsind=1)
  CALL echo("Looking for admin table primary keys...")
  CALL dlpti_check_pk_info(concat("USER_CONSTRAINTS@",dlpti_adminlink),concat("USER_OBJECTS@",
    dlpti_adminlink),concat("USER_IND_COLUMNS@",dlpti_adminlink),concat("USER_TAB_COLUMNS@",
    dlpti_adminlink),"dlpti_tables->list_0[d.seq].hasValidIdxInd = 0",
   1)
 ENDIF
 CALL echo("Inserting primary key indexes...")
 INSERT  FROM dm_purge_table_index dpti,
   (dummyt d  WITH seq = value(dlpti_tablecnt)),
   (dummyt d2  WITH seq = value(dlpti_maxcolumncnt))
  SET dpti.table_index_id = seq(dm_clinical_seq,nextval), dpti.table_name = dlpti_tables->list_0[d
   .seq].tablename, dpti.index_name = dlpti_tables->list_0[d.seq].indexname,
   dpti.column_name = dlpti_tables->list_0[d.seq].columns[d2.seq].columnname, dpti.data_type =
   dlpti_tables->list_0[d.seq].columns[d2.seq].datatype, dpti.precedence_nbr = dlpti_tables->list_0[d
   .seq].columns[d2.seq].precedence,
   dpti.last_ddl_dt_tm = cnvtdatetime(dlpti_tables->list_0[d.seq].lastddltime), dpti.admin_table_ind
    = dlpti_tables->list_0[d.seq].isadminind, dpti.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   dpti.updt_task = reqinfo->updt_task, dpti.updt_id = reqinfo->updt_id, dpti.updt_applctx = reqinfo
   ->updt_applctx,
   dpti.updt_cnt = 0
  PLAN (d
   WHERE (dlpti_tables->list_0[d.seq].haspkidx=1))
   JOIN (d2
   WHERE d2.seq <= size(dlpti_tables->list_0[d.seq].columns,5))
   JOIN (dpti)
  WITH nocounter
 ;end insert
 IF (error(dlpti_errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert primary-key-index entries: ",dlpti_errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("Looking for non-primary key unique indexes...")
 CALL dlpti_check_nonpk_info("USER_INDEXES","USER_OBJECTS","USER_IND_COLUMNS","USER_TAB_COLUMNS",
  "dlpti_tables->list_0[d.seq].isAdminInd = 0",
  0)
 IF (dlpti_linkexistsind=1)
  CALL echo("Looking for admin table unique indexes...")
  CALL dlpti_check_nonpk_info(concat("USER_INDEXES@",dlpti_adminlink),concat("USER_OBJECTS@",
    dlpti_adminlink),concat("USER_IND_COLUMNS@",dlpti_adminlink),concat("USER_TAB_COLUMNS@",
    dlpti_adminlink),"dlpti_tables->list_0[d.seq].hasValidIdxInd = 0",
   1)
 ENDIF
 CALL echo("Inserting non-primary-key unique indexes...")
 INSERT  FROM dm_purge_table_index dpti,
   (dummyt d  WITH seq = value(dlpti_tablecnt)),
   (dummyt d2  WITH seq = value(dlpti_maxcolumncnt))
  SET dpti.table_index_id = seq(dm_clinical_seq,nextval), dpti.table_name = dlpti_tables->list_0[d
   .seq].tablename, dpti.index_name = dlpti_tables->list_0[d.seq].indexname,
   dpti.column_name = dlpti_tables->list_0[d.seq].columns[d2.seq].columnname, dpti.data_type =
   dlpti_tables->list_0[d.seq].columns[d2.seq].datatype, dpti.precedence_nbr = dlpti_tables->list_0[d
   .seq].columns[d2.seq].precedence,
   dpti.admin_table_ind = dlpti_tables->list_0[d.seq].isadminind, dpti.last_ddl_dt_tm = cnvtdatetime(
    dlpti_tables->list_0[d.seq].lastddltime), dpti.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   dpti.updt_task = reqinfo->updt_task, dpti.updt_id = reqinfo->updt_id, dpti.updt_applctx = reqinfo
   ->updt_applctx,
   dpti.updt_cnt = 0
  PLAN (d
   WHERE (dlpti_tables->list_0[d.seq].hasnonpkidx=1))
   JOIN (d2
   WHERE d2.seq <= size(dlpti_tables->list_0[d.seq].columns,5))
   JOIN (dpti)
  WITH nocounter
 ;end insert
 IF (error(dlpti_errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert non-primary-key-index entries: ",dlpti_errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Successfully loaded unique- and primary-key columns for all purge parent tables."
 SUBROUTINE dlpti_check_user_objects(dlpticuo_usertablename,dlpticuo_parserstmt)
   SELECT INTO "nl:"
    FROM (value(cnvtupper(dlpticuo_usertablename)) uo),
     (dummyt d  WITH seq = value(dlpti_tablecnt))
    PLAN (d
     WHERE parser(dlpticuo_parserstmt))
     JOIN (uo
     WHERE (uo.object_name=dlpti_tables->list_0[d.seq].tablename)
      AND uo.object_type="TABLE"
      AND uo.last_ddl_time=cnvtdatetime(dlpti_tables->list_0[d.seq].lastddltime))
    DETAIL
     dlpti_tables->list_0[d.seq].hasvalididxind = 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE dlpti_check_pk_info(dlpticpki_userconsname,dlpticpki_userobjsname,
  dlpticpki_userindcolname,dlpticpki_usertabcolname,dlpticpki_parserstmt,dlpticpki_adminind)
   SELECT INTO "nl:"
    uc.index_name
    FROM (value(cnvtupper(dlpticpki_userconsname)) uc),
     (value(cnvtupper(dlpticpki_userobjsname)) uo),
     (value(cnvtupper(dlpticpki_userindcolname)) uic),
     (value(cnvtupper(dlpticpki_usertabcolname)) utc),
     (dummyt d  WITH seq = value(dlpti_tablecnt))
    PLAN (d
     WHERE (dlpti_tables->list_0[d.seq].hasvalididxind=0)
      AND parser(dlpticpki_parserstmt))
     JOIN (uc
     WHERE (uc.table_name=dlpti_tables->list_0[d.seq].tablename)
      AND uc.constraint_type="P")
     JOIN (uo
     WHERE uo.object_name=uc.table_name
      AND uo.object_type="TABLE")
     JOIN (uic
     WHERE uic.index_name=uc.index_name)
     JOIN (utc
     WHERE utc.column_name=uic.column_name
      AND (utc.table_name=dlpti_tables->list_0[d.seq].tablename))
    ORDER BY uc.index_name
    HEAD uc.index_name
     dlpti_tables->list_0[d.seq].indexname = uc.index_name, dlpti_tables->list_0[d.seq].haspkidx = 1,
     dlpti_tables->list_0[d.seq].hasvalididxind = 1,
     dlpti_tables->list_0[d.seq].isadminind = dlpticpki_adminind, dlpti_tables->list_0[d.seq].
     lastddltime = uo.last_ddl_time, dlpti_columncnt = 0
    DETAIL
     dlpti_columncnt = (dlpti_columncnt+ 1), stat = alterlist(dlpti_tables->list_0[d.seq].columns,
      dlpti_columncnt), dlpti_tables->list_0[d.seq].columns[dlpti_columncnt].columnname = utc
     .column_name,
     dlpti_tables->list_0[d.seq].columns[dlpti_columncnt].datatype = evaluate(utc.data_type,"FLOAT",
      "NUMBER",utc.data_type)
     IF (utc.data_type IN ("VARCHAR2", "CHAR"))
      dlpti_tables->list_0[d.seq].columns[dlpti_columncnt].datatype = build(dlpti_tables->list_0[d
       .seq].columns[dlpti_columncnt].datatype,"(",cnvtstring(utc.data_length),")")
     ENDIF
     dlpti_tables->list_0[d.seq].columns[dlpti_columncnt].precedence = cnvtint(uic.column_position)
    FOOT  uc.index_name
     dlpti_maxcolumncnt = maxval(dlpti_maxcolumncnt,dlpti_columncnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE dlpti_check_nonpk_info(dlpticni_userindname,dlpticni_userobjsname,dlpticni_userindcolname,
  dlpticni_usertabcolname,dlpticni_parserstmt,dlpticni_adminind)
   SELECT INTO "nl:"
    ui.index_name, uo.last_ddl_time, utc.column_name,
    utc.data_type, utc.data_length, uic.column_position
    FROM (value(cnvtupper(dlpticni_userindname)) ui),
     (value(cnvtupper(dlpticni_userindcolname)) uic),
     (value(cnvtupper(dlpticni_userobjsname)) uo),
     (value(cnvtupper(dlpticni_usertabcolname)) utc),
     (dummyt d  WITH seq = value(dlpti_tablecnt))
    PLAN (d
     WHERE (dlpti_tables->list_0[d.seq].hasvalididxind=0)
      AND parser(dlpticni_parserstmt))
     JOIN (ui
     WHERE (ui.table_name=dlpti_tables->list_0[d.seq].tablename)
      AND ui.uniqueness="UNIQUE")
     JOIN (uic
     WHERE uic.index_name=ui.index_name)
     JOIN (uo
     WHERE uo.object_name=ui.table_name
      AND uo.object_type="TABLE")
     JOIN (utc
     WHERE (utc.table_name=dlpti_tables->list_0[d.seq].tablename)
      AND utc.column_name=uic.column_name)
    ORDER BY ui.index_name, uic.column_position
    HEAD REPORT
     dlpti_tables->list_0[d.seq].hasvalididxind = 1, dlpti_tables->list_0[d.seq].hasnonpkidx = 1,
     dlpti_tables->list_0[d.seq].lastddltime = uo.last_ddl_time,
     dlpti_tables->list_0[d.seq].isadminind = dlpticni_adminind, dlpti_curcolumncnt = 0
    HEAD ui.index_name
     dlpti_curcolumncnt = 0, dlpti_betterindexind = 0
    DETAIL
     dlpti_curcolumncnt = (dlpti_curcolumncnt+ 1), stat = alterlist(dlpti_curcolumns->list_0,
      dlpti_curcolumncnt), dlpti_curcolumns->list_0[dlpti_curcolumncnt].columnname = utc.column_name
     IF (utc.data_type IN ("VARCHAR2", "CHAR"))
      dlpti_curcolumns->list_0[dlpti_curcolumncnt].datatype = build(utc.data_type,"(",cnvtstring(utc
        .data_length),")")
     ELSE
      dlpti_curcolumns->list_0[dlpti_curcolumncnt].datatype = evaluate(utc.data_type,"FLOAT","NUMBER",
       utc.data_type)
     ENDIF
     dlpti_curcolumns->list_0[dlpti_curcolumncnt].precedence = cnvtint(uic.column_position)
    FOOT  ui.index_name
     IF (size(dlpti_tables->list_0[d.seq].columns,5)=0)
      dlpti_betterindexind = 1
     ELSEIF (dlpti_curcolumncnt < size(dlpti_tables->list_0[d.seq].columns,5))
      dlpti_betterindexind = 1
     ENDIF
     IF (dlpti_betterindexind=1)
      dlpti_tables->list_0[d.seq].indexname = ui.index_name, stat = alterlist(dlpti_tables->list_0[d
       .seq].columns,dlpti_curcolumncnt)
      FOR (dlpti_columnloop = 1 TO dlpti_curcolumncnt)
        dlpti_tables->list_0[d.seq].columns[dlpti_columnloop].columnname = dlpti_curcolumns->list_0[
        dlpti_columnloop].columnname, dlpti_tables->list_0[d.seq].columns[dlpti_columnloop].datatype
         = dlpti_curcolumns->list_0[dlpti_columnloop].datatype, dlpti_tables->list_0[d.seq].columns[
        dlpti_columnloop].precedence = dlpti_curcolumns->list_0[dlpti_columnloop].precedence
      ENDFOR
     ENDIF
    FOOT REPORT
     dlpti_maxcolumncnt = maxval(dlpti_maxcolumncnt,size(dlpti_tables->list_0[d.seq].columns,5))
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 FREE RECORD dlpti_tables
 FREE RECORD dlpti_curcolumns
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
