CREATE PROGRAM dm_import_admin:dba
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_inputs TO 2999_inputs_exit
 EXECUTE FROM 3000_cleanup_current_schema TO 3999_cleanup_current_schema_exit
 EXECUTE FROM 4000_delete_current_rows TO 4999_delete_current_rows_exit
 EXECUTE FROM 5000_import_data TO 5999_import_data_exit
 EXECUTE FROM 6000_fix_data TO 6999_fix_data_exit
 GO TO 9999_exit_program
 SUBROUTINE dia_disable_fks(dia_dummy)
  SELECT INTO "nl:"
   FROM user_constraints uc
   WHERE uc.constraint_type="R"
    AND uc.status="ENABLED"
   DETAIL
    admin_cons->fk_cnt = (admin_cons->fk_cnt+ 1), stat = alterlist(admin_cons->qual,admin_cons->
     fk_cnt), admin_cons->qual[admin_cons->fk_cnt].table_name = uc.table_name,
    admin_cons->qual[admin_cons->fk_cnt].constraint_name = uc.constraint_name
   WITH nocounter
  ;end select
  FOR (diai = 1 TO value(admin_cons->fk_cnt))
    CALL log(concat("Disable foreign key: ",admin_cons->qual[diai].constraint_name))
    CALL parse(concat("rdb alter table ",admin_cons->qual[diai].table_name))
    CALL parse(concat("disable constraint ",admin_cons->qual[diai].constraint_name," go"))
  ENDFOR
 END ;Subroutine
 SUBROUTINE chk_ccldef(ccd_table)
  SELECT INTO "nl:"
   d.table_name, l.attr_name
   FROM dtableattr d,
    dtableattrl l
   WHERE l.structtype="F"
    AND btest(l.stat,11)=0
    AND d.table_name=ccd_table
    AND l.attr_name="*"
   WITH nocounter
  ;end select
  IF (curqual)
   RETURN(0)
  ELSE
   RETURN(1)
  ENDIF
 END ;Subroutine
 SUBROUTINE blast(b_table)
  CALL log(concat("Truncate (blast) table: ",b_table))
  CALL parse(concat("rdb truncate table ",b_table," go"))
 END ;Subroutine
 SUBROUTINE blast_db_version(x_table)
   SET bdv_count = 0
   CALL log(concat("Blast_db_version table: ",x_table))
   SET w_flag = 1
   WHILE (w_flag)
     CALL parse(concat("delete from ",x_table," x where x.db_version >=800"))
     CALL parse("with maxqual(x, 1000) go")
     SET w_flag = curqual
     SET bdv_count = (bdv_count+ curqual)
     COMMIT
   ENDWHILE
   CALL log(concat("Number of rows deleted: ",cnvtstring(bdv_count)))
 END ;Subroutine
 SUBROUTINE blast_schema_date(b_table)
   IF (chk_ccldef(b_table))
    CALL log(concat("Create ccl def for table: ",b_table))
    CALL parse(concat("execute oragen3 '",b_table,"' go"))
   ENDIF
   SET bdv_count = 0
   CALL log(concat("Blast_schema_date table: ",b_table))
   SET w_flag = 1
   WHILE (w_flag)
     CALL parse(concat("delete from ",b_table," x where x.schema_date ="))
     CALL parse(concat("cnvtdatetimeutc('",dump_date,"') with maxqual(x, 1000) go"))
     SET w_flag = curqual
     SET bdv_count = (bdv_count+ curqual)
     COMMIT
   ENDWHILE
   CALL log(concat("Number of rows deleted: ",cnvtstring(bdv_count)))
 END ;Subroutine
 SUBROUTINE blast_env_name(x_table)
   SET bdv_count = 0
   CALL log(concat("Blast_Environment_Name table: ",x_table))
   SET w_flag = 1
   WHILE (w_flag)
     CALL parse(concat("delete from ",x_table," x where x.environment_name ='",sf_hold->env_name,"'")
      )
     CALL parse("with maxqual(x, 1000) go")
     SET w_flag = curqual
     SET bdv_count = (bdv_count+ curqual)
     COMMIT
   ENDWHILE
   CALL log(concat("Number of rows deleted: ",cnvtstring(bdv_count)))
 END ;Subroutine
 SUBROUTINE com(c_text)
   SET command_count = (command_count+ 1)
   SET stat = alterlist(commands->command,command_count)
   SET commands->command[command_count].text = trim(c_text,3)
 END ;Subroutine
 SUBROUTINE com_reset(dummy)
   SET command_count = 0
   SET stat = alterlist(commands->command,command_count)
   IF (cursys != "AIX")
    IF ((commands->oracle_version >= 9))
     CALL com("$@oracle_home:orauser")
    ELSE
     CALL com("$@ora_util:orauser")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE kick(k_text)
   SET mgx_errcode = 1
   CALL log(concat("ERROR: ",k_text))
   ROLLBACK
   GO TO 9999_exit_program
 END ;Subroutine
 SUBROUTINE log(l_text)
   SET l_temp_string = concat(l_text," (",format(cnvtdatetime(curdate,curtime3),";;q"),")")
   IF (mgx_errcode=1)
    CALL echo("**************************************************************************")
   ENDIF
   CALL echo(l_temp_string)
   IF (mgx_errcode=1)
    CALL echo("**************************************************************************")
   ENDIF
   IF (tmp_log->init_log)
    SELECT INTO value(tmp_log->log_file_name)
     FROM dual
     DETAIL
      row 1, l_temp_string
     WITH nocounter, maxcol = value(tmp_log->max_col_size)
    ;end select
   ELSE
    SELECT INTO value(tmp_log->log_file_name)
     FROM dual
     DETAIL
      IF (mgx_errcode=1)
       row + 1, "**************************************************************************"
      ENDIF
      row + 1, l_temp_string
      IF (mgx_errcode=1)
       row + 1, "**************************************************************************"
      ENDIF
     WITH nocounter, maxcol = value(tmp_log->max_col_size), append
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE parse(p_text)
   CALL parser(p_text,1)
 END ;Subroutine
 SUBROUTINE run(r_dummy)
   SET r_file = commands->command_file
   SET r_command = commands->command_file_name
   SET r_len = size(r_command)
   SET r_i = 0
   SELECT INTO value(r_file)
    FROM dummyt d
    DETAIL
     FOR (r_i = 1 TO command_count)
      commands->command[r_i].text,
      IF (r_i < command_count)
       row + 1
      ENDIF
     ENDFOR
    WITH nocounter, format = variable, noformfeed,
     maxrow = 1, maxcol = 1000
   ;end select
   IF (cursys="AIX")
    SET r2_len = 0
    SET r2_command = concat("chmod 777 ",r_command)
    SET r2_len = size(r2_command)
    CALL dcl(r2_command,r2_len,0)
   ENDIF
   SET command_count = 0
   SET stat = alterlist(commands->command,0)
   SET r_i = 0
   CALL dcl(r_command,r_len,r_i)
 END ;Subroutine
 SUBROUTINE switch_database(sd_name)
   SET mgx_errcode = error(mgx_errmsg,1)
   FREE DEFINE oraclesystem
   DEFINE oraclesystem sd_name
   SET mgx_errcode = error(mgx_errmsg,0)
   IF (mgx_errcode)
    CALL kick(concat("Could not define oraclesystem with: ",sd_name))
   ENDIF
 END ;Subroutine
 SUBROUTINE wipe(w_table,w_afd)
   IF (chk_ccldef(w_table))
    CALL log(concat("Create ccl def for table: ",w_table))
    CALL parse(concat("execute oragen3 '",w_table,"' go"))
   ENDIF
   SET bdv_count = 0
   CALL log(concat("Wipe table: ",w_table))
   SET w_flag = 1
   WHILE (w_flag)
     IF (w_afd)
      CALL parse(concat("delete from ",w_table," x where x.alpha_feature_nbr in"))
     ELSE
      CALL parse(concat("delete from ",w_table," x where x.ocd in"))
     ENDIF
     CALL parse("(select o.ocd from dm_current_ocd o where o.ocd > 0) with maxqual(x, 1000) go")
     SET w_flag = curqual
     SET bdv_count = (bdv_count+ curqual)
     COMMIT
   ENDWHILE
   CALL log(concat("Number of rows deleted: ",cnvtstring(bdv_count)))
 END ;Subroutine
 SUBROUTINE di_drop_table(ddd_table)
   SELECT INTO "nl:"
    FROM dba_synonyms da
    WHERE da.synonym_name=ddd_table
     AND da.owner="PUBLIC"
    WITH nocounter
   ;end select
   IF (curqual)
    CALL log(concat("Drop synonym: ",ddd_table))
    CALL parse(concat("rdb drop public synonym ",ddd_table," go"))
   ENDIF
   SELECT INTO "nl:"
    FROM dba_objects db
    WHERE db.object_name=ddd_table
     AND db.object_type="TABLE"
     AND db.owner=currdbuser
    WITH nocounter
   ;end select
   IF (curqual)
    CALL log(concat("Drop table: ",ddd_table))
    CALL parse(concat("rdb drop table ",ddd_table," cascade constraints go"))
   ENDIF
 END ;Subroutine
 SUBROUTINE di_build_ccl_def(bcd_dummy)
  SELECT INTO "nl:"
   FROM user_tables ut
   DETAIL
    admin_cons->tbl_cnt = (admin_cons->tbl_cnt+ 1), stat = alterlist(admin_cons->tqual,admin_cons->
     tbl_cnt), admin_cons->tqual[admin_cons->tbl_cnt].tbl_name = trim(ut.table_name)
   WITH nocounter
  ;end select
  FOR (dbcd = 1 TO value(admin_cons->tbl_cnt))
   CALL log(concat("Create CCL definition for table: ",admin_cons->tqual[dbcd].tbl_name))
   CALL parse(concat("execute oragen3 '",admin_cons->tqual[dbcd].tbl_name,"' go"))
  ENDFOR
 END ;Subroutine
#1000_initialize
 ROLLBACK
 FREE SET commands
 RECORD commands(
   1 oracle_version = i4
   1 imp_command_str = vc
   1 sqlplus_command_str = vc
   1 command_file_name = vc
   1 command_file = vc
   1 command[*]
     2 text = vc
 )
 SET command_count = 0
 FREE SET arch_dt
 RECORD arch_dt(
   1 arch_dt_cnt = i4
   1 qual[*]
     2 ocd = i4
     2 archive_dt_tm = dq8
 )
 SET arch_dt->arch_dt_cnt = 0
 SET stat = alterlist(arch_dt->qual,arch_dt->arch_dt_cnt)
 FREE SET admin_cons
 RECORD admin_cons(
   1 fk_cnt = i4
   1 qual[*]
     2 table_name = vc
     2 constraint_name = vc
   1 tbl_cnt = i4
   1 tqual[*]
     2 tbl_name = vc
 )
 SET admin_cons->fk_cnt = 0
 SET stat = alterlist(admin_cons->qual,admin_cons->fk_cnt)
 SET admin_cons->tbl_cnt = 0
 SET stat = alterlist(admin_cons->tqual,admin_cons->tbl_cnt)
 SET i = 0
 SET j = 0
 SET k = 0
 SET mgx_errmsg = fillstring(132," ")
 SET mgx_errcode = 0
 FREE SET tmp_log
 RECORD tmp_log(
   1 init_log = i2
   1 log_file_name = vc
   1 max_col_size = i4
 )
 SET tmp_log->log_file_name = "dm_import_admin.log"
 SET tmp_log->max_col_size = 132
 SET tmp_log->init_log = 1
 CALL log("Starting the DM_IMPORT_ADMIN Process.")
 SET tmp_log->init_log = 0
 IF (cursys="AIX")
  SET commands->imp_command_str = "$ORACLE_HOME/bin/imp"
  SET commands->sqlplus_command_str = "$ORACLE_HOME/bin/sqlplus"
  SET commands->command_file_name = "$CCLUSERDIR/ocd_import_admin.ksh"
  SET commands->command_file = "ocd_import_admin.ksh"
 ELSE
  SET commands->imp_command_str = "$imp"
  SET commands->sqlplus_command_str = "$sqlplus"
  SET commands->command_file_name = "@CCLUSERDIR:ocd_import_admin.com"
  SET commands->command_file = "ocd_import_admin.com"
 ENDIF
#1999_initialize_exit
#2000_inputs
 DECLARE dump_path = vc
 DECLARE dump_date = vc
 SET dump_version = 0.0
 SET dump_path = cnvtlower(trim( $1,3))
 SET dump_date =  $2
 SET admin_connect =  $3
 IF ((( NOT (size(trim(dump_path,3)))) OR ((( NOT (cnvtdatetimeutc(dump_date))) OR ( NOT (size(trim(
   admin_connect,3))))) )) )
  CALL kick("One or more parameters seems to be invalid.")
 ENDIF
 IF (findstring("/",dump_path,1,0)=1)
  CALL log("Searching for Admin.dmp file on AIX ...")
  SET di_dump_file = build(dump_path,"admin.dmp")
 ELSEIF (findstring("$",dump_path,1,0)=1)
  CALL log("Searching for Admin.dmp file on AIX ...")
  FREE RECORD tpx
  RECORD tpx(
    1 tmpstr = vc
  )
  SET tmppos = findstring("/",dump_path,2,0)
  SET tpx->tmpstr = logical(substring(2,(tmppos - 2),dump_path))
  SET tpx->tmpstr = concat(tpx->tmpstr,substring(tmppos,((textlen(dump_path) - tmppos)+ 1),dump_path)
   )
  SET di_dump_file = build(tpx->tmpstr,"admin.dmp")
  FREE RECORD tpx
 ELSE
  CALL log("Searching for Admin.dmp file on AXP ...")
  SET di_dump_file = build(dump_path,"admin.dmp")
 ENDIF
 IF ( NOT (findfile(di_dump_file)))
  CALL kick(concat("Could NOT find file at: ",di_dump_file))
 ELSE
  CALL log(concat("Successfully found file at: ",di_dump_file))
 ENDIF
#2999_inputs_exit
#3000_cleanup_current_schema
 CALL switch_database(admin_connect)
 CALL log("Determine Oracle Version ...")
 SELECT INTO "NL:"
  p.*
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   commands->oracle_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL kick("Could NOT access PRODUCT_COMPONENT_VERSION table.")
 ELSE
  CALL log(concat("Oracle Version: ",cnvtstring(commands->oracle_version)))
 ENDIF
 CALL di_drop_table("DM_CURRENT_OCD")
 CALL log(concat("Importing DM_CURRENT_OCD table via > ",commands->command_file_name," < "))
 CALL com_reset(0)
 CALL com(concat(commands->imp_command_str," ",admin_connect,
   " touser=cdba fromuser=admin_tmp commit=Y ignore=y ","tables=DM_CURRENT_OCD file=",
   dump_path,"admin.dmp log=",dump_path,"admin_table_imp.log"))
 CALL run(0)
 CALL log("Create ccl def for table: DM_CURRENT_OCD")
 CALL parse("execute oragen3 'DM_CURRENT_OCD' go")
 CALL log("Check if DM_CURRENT_OCD table imported successfully and has a CCL definition ...")
 SELECT INTO "nl:"
  FROM dm_current_ocd
  WHERE ocd > 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL kick(
   "Could NOT access DM_CURRENT_OCD table. Either the Import failed or unable to create CCL definition."
   )
 ELSE
  CALL log("DM_CURRENT_OCD table imported successfully and has a valid CCL definition.")
 ENDIF
 CALL log("Grab existing Archive Date Time rows from DM_ALPHA_FEATURES table.")
 SELECT INTO "nl:"
  FROM dm_alpha_features daf
  WHERE daf.archive_dt_tm IS NOT null
  ORDER BY daf.alpha_feature_nbr
  DETAIL
   arch_dt->arch_dt_cnt = (arch_dt->arch_dt_cnt+ 1), stat = alterlist(arch_dt->qual,arch_dt->
    arch_dt_cnt), arch_dt->qual[arch_dt->arch_dt_cnt].ocd = daf.alpha_feature_nbr,
   arch_dt->qual[arch_dt->arch_dt_cnt].archive_dt_tm = cnvtdatetime(daf.archive_dt_tm)
  WITH nocounter
 ;end select
 CALL di_drop_table("DM_ALPHA_FEATURES")
 CALL di_drop_table("DM_TABLES_DOC")
 CALL di_drop_table("DM_INDEXES_DOC")
 CALL di_drop_table("DM_PKT_SETUP_PROCESS")
 CALL di_drop_table("DM_REF_DOMAIN")
 CALL di_drop_table("DM_REQUEST_PROCESSING")
 CALL di_drop_table("OCD_README_COMPONENT")
 CALL di_drop_table("DM_COLUMNS_DOC")
 CALL di_drop_table("DM_TS_PRECEDENCE")
#3999_cleanup_current_schema_exit
#4000_delete_current_rows
 CALL switch_database(admin_connect)
 CALL dia_disable_fks(1)
 CALL blast("DM_CLIENT_OBJECT_SIZE")
 CALL blast("DM_CLIENT_SIZE")
 CALL blast("DM_CODE_SET")
 CALL blast("DM_DATA_MODEL_SECTION")
 CALL blast("DM_DISK_FARM")
 IF ((validate(sf_hold->exist_flag,- (1))=- (1)))
  CALL blast("DM_ENV_CON_FILES_SHIP")
  CALL blast("DM_ENV_FILES_SHIP")
  CALL blast("DM_ENV_FUNCTIONS_SHIP")
  CALL blast("DM_ENV_INDEX_SHIP")
  CALL blast("DM_ENV_REDO_LOGS_SHIP")
  CALL blast("DM_ENV_ROLL_SEGS_SHIP")
  CALL blast("DM_ENV_TABLE_SHIP")
  CALL blast("DM_ENVIRONMENT_SHIP")
  CALL blast("DM_README_HIST_SHIP")
 ELSE
  CALL blast_env_name("DM_ENV_CON_FILES_SHIP")
  CALL blast_env_name("DM_ENV_FILES_SHIP")
  CALL blast_env_name("DM_ENV_FUNCTIONS_SHIP")
  CALL blast_env_name("DM_ENV_INDEX_SHIP")
  CALL blast_env_name("DM_ENV_REDO_LOGS_SHIP")
  CALL blast_env_name("DM_ENV_ROLL_SEGS_SHIP")
  CALL blast_env_name("DM_ENV_TABLE_SHIP")
  CALL blast_env_name("DM_ENVIRONMENT_SHIP")
  CALL blast_env_name("DM_README_HIST_SHIP")
 ENDIF
 CALL blast("DM_ENV_PRIVILEDGES")
 CALL blast("DM_ENV_USER")
 CALL blast("DM_ENV_USER_FUNCTIONS")
 CALL blast("DM_ENV_USER_PRIVLEDGES")
 CALL blast("DM_FLAGS")
 CALL blast("DM_FUNCTION_DEPENDENCIES")
 CALL blast("DM_FUNCTION_DM_SECTION_R")
 CALL blast("DM_MIN_TSPACE_SIZE")
 CALL blast("DM_OWNER")
 CALL blast("DM_PRODUCT_FUNCTIONS")
 CALL blast("DM_PRODUCT_INDEX_RELTN")
 CALL blast("DM_PRODUCT_TABLE_RELTN")
 CALL blast("DM_QUESTION")
 CALL blast("DM_README")
 CALL blast("DM_REF_DOMAIN_GROUP")
 CALL blast("DM_REF_DOMAIN_R")
 CALL blast("DM_SEQUENCES")
 CALL blast_db_version("DM_SIZE_DB_CNTL_FILES")
 CALL blast_db_version("DM_SIZE_DB_CONFIG")
 CALL blast_db_version("DM_SIZE_DB_REDO_LOGS")
 CALL blast_db_version("DM_SIZE_DB_ROLLBACK_SEGS")
 CALL blast_db_version("DM_SIZE_DB_TS")
 CALL blast_db_version("DM_SIZE_DB_VERSION")
 CALL blast("DM_STATIC_TABLESPACES")
 CALL blast("DM_TABLESPACE")
 CALL blast("DM_TABLESPACE_DOC")
 CALL blast("DM_ADM_PURGE_TABLE")
 CALL blast("DM_ADM_PURGE_TEMPLATE")
 CALL blast("DM_ADM_PURGE_TOKEN")
 CALL blast_schema_date("DM_CODE_SET_EXTENSION")
 CALL blast_schema_date("DM_CODE_VALUE")
 CALL blast_schema_date("DM_CODE_VALUE_ALIAS")
 CALL blast_schema_date("DM_CODE_VALUE_EXTENSION")
 CALL blast_schema_date("DM_CODE_VALUE_SET")
 CALL blast_schema_date("DM_COMMON_DATA_FOUNDATION")
 CALL blast_schema_date("DM_CONS_COLUMNS")
 CALL blast_schema_date("DM_CONSTRAINTS")
 CALL blast_schema_date("DM_INDEX_COLUMNS")
 CALL blast_schema_date("DM_INDEXES")
 CALL blast_schema_date("DM_COLUMNS")
 CALL blast_schema_date("DM_TABLES")
 CALL blast_schema_date("DM_SCHEMA_VERSION")
 CALL log("Check if there is a zero row on DM_SCHEMA_VERSION table.")
 SELECT INTO "nl:"
  FROM dm_schema_version dv
  WHERE dv.schema_version=0.0
  WITH nocounter
 ;end select
 IF (curqual)
  CALL log("Delete zero row from DM_SCHEMA_VERSION table.")
  DELETE  FROM dm_schema_version dv
   WHERE dv.schema_version=0.0
   WITH nocounter
  ;end delete
  COMMIT
 ENDIF
 CALL wipe("DM_AFD_CODE_SET_EXTENSION",1)
 CALL wipe("DM_AFD_CODE_VALUE",1)
 CALL wipe("DM_AFD_CODE_VALUE_ALIAS",1)
 CALL wipe("DM_AFD_CODE_VALUE_EXTENSION",1)
 CALL wipe("DM_AFD_CODE_VALUE_SET",1)
 CALL wipe("DM_AFD_CODE_VALUE_GROUP",1)
 CALL wipe("DM_AFD_COLUMNS",1)
 CALL wipe("DM_AFD_COMMON_DATA_FOUNDATION",1)
 CALL wipe("DM_AFD_CONS_COLUMNS",1)
 CALL wipe("DM_AFD_CONSTRAINTS",1)
 CALL wipe("DM_AFD_INDEX_COLUMNS",1)
 CALL wipe("DM_AFD_INDEXES",1)
 CALL wipe("DM_AFD_TABLES",1)
 IF ((validate(sf_hold->exist_flag,- (1))=- (1)))
  CALL blast("DM_AFE_SHIP")
 ELSE
  CALL blast_env_name("DM_AFE_SHIP")
 ENDIF
 CALL wipe("DM_OCD_APP_TASK_R",1)
 CALL wipe("DM_OCD_APPLICATION",1)
 CALL wipe("DM_OCD_FEATURES",1)
 IF ((validate(sf_hold->exist_flag,- (1))=- (1)))
  CALL blast("DM_OCD_LOG_SHIP")
 ELSE
  CALL blast_env_name("DM_OCD_LOG_SHIP")
 ENDIF
 CALL wipe("DM_OCD_PRODUCT_AREA",0)
 CALL wipe("DM_OCD_README",0)
 CALL wipe("DM_OCD_REQUEST",1)
 CALL wipe("DM_OCD_TASK",1)
 CALL wipe("DM_OCD_TASK_REQ_R",1)
#4999_delete_current_rows_exit
#5000_import_data
 CALL switch_database(admin_connect)
 CALL blast("DM_CURRENT_OCD")
 CALL log(concat("Begin importing all rows from the dump file via > ",commands->command_file_name,
   " < "))
 CALL com_reset(0)
 IF (cursys="AIX")
  CALL com(concat(commands->imp_command_str," ",admin_connect,
    " touser=cdba fromuser=admin_tmp commit=Y ignore=y ","file=",
    dump_path,"admin.dmp parfile=$cer_install/dm_import_admin_tables.par ","log=",dump_path,
    "admin_imp.log"))
 ELSE
  CALL com(concat(commands->imp_command_str," ",admin_connect,
    " touser=cdba fromuser=admin_tmp commit=Y ignore=y ","file=",
    dump_path,"admin.dmp parfile=cer_install:dm_import_admin_tables.par ","log=",dump_path,
    "admin_imp.log"))
 ENDIF
 CALL run(0)
#5999_import_data_exit
#6000_fix_data
 CALL switch_database(admin_connect)
 CALL di_build_ccl_def(1)
 CALL log("Update into DM_ALPHA_FEATURES table with existing Archive Date Time rows.")
 UPDATE  FROM dm_alpha_features daf,
   (dummyt d  WITH seq = value(arch_dt->arch_dt_cnt))
  SET daf.seq = 1, daf.archive_dt_tm = cnvtdatetime(arch_dt->qual[d.seq].archive_dt_tm)
  PLAN (d)
   JOIN (daf
   WHERE (daf.alpha_feature_nbr=arch_dt->qual[d.seq].ocd))
  WITH nocounter
 ;end update
 COMMIT
 FREE SET tmp_drp_obj
 RECORD tmp_drp_obj(
   1 cnt = i2
   1 qual[*]
     2 name = vc
     2 exist_flag = i2
 )
 SET tmp_drp_obj->cnt = 7
 SET stat = alterlist(tmp_drp_obj->qual,tmp_drp_obj->cnt)
 SET tmp_drp_obj->qual[1].name = "DM_SIZE_1"
 SET tmp_drp_obj->qual[2].name = "DM_SIZE_2"
 SET tmp_drp_obj->qual[3].name = "DM_SIZE_3"
 SET tmp_drp_obj->qual[4].name = "DM_SIZE_T6"
 SET tmp_drp_obj->qual[5].name = "PT_BODY1"
 SET tmp_drp_obj->qual[6].name = "PT_BODY2"
 SET tmp_drp_obj->qual[7].name = "PT_BODY3"
 SELECT INTO "nl:"
  FROM dba_objects do,
   (dummyt d  WITH seq = value(tmp_drp_obj->cnt))
  PLAN (d)
   JOIN (do
   WHERE (do.object_name=tmp_drp_obj->qual[d.seq].name)
    AND do.object_type="PACKAGE")
  DETAIL
   CASE (do.object_name)
    OF "DM_SIZE_1":
     tmp_drp_obj->qual[d.seq].exist_flag = 1
    OF "DM_SIZE_2":
     tmp_drp_obj->qual[d.seq].exist_flag = 1
    OF "DM_SIZE_3":
     tmp_drp_obj->qual[d.seq].exist_flag = 1
    OF "DM_SIZE_T6":
     tmp_drp_obj->qual[d.seq].exist_flag = 1
    OF "PT_BODY1":
     tmp_drp_obj->qual[d.seq].exist_flag = 1
    OF "PT_BODY2":
     tmp_drp_obj->qual[d.seq].exist_flag = 1
    OF "PT_BODY3":
     tmp_drp_obj->qual[d.seq].exist_flag = 1
   ENDCASE
  WITH nocounter
 ;end select
 FOR (itjxt = 1 TO value(tmp_drp_obj->cnt))
   IF ((tmp_drp_obj->qual[itjxt].exist_flag=1))
    CALL log(concat("Drop unused package: ",tmp_drp_obj->qual[itjxt].name))
    CALL parser(concat("rdb drop package ",tmp_drp_obj->qual[itjxt].name," go"),1)
   ENDIF
 ENDFOR
 CALL log("Attempting to compile all database objects.")
 EXECUTE dm_compile_all_objects
#6999_fix_data_exit
#9999_exit_program
 IF (mgx_errcode)
  CALL log("Encountered ERROR(s) with the DM_IMPORT_ADMIN process!")
  CALL log(concat("Please review errors in ccluserdir:",tmp_log->log_file_name," and try again... "))
 ELSE
  CALL log("Finished executing the DM_IMPORT_ADMIN process!")
  CALL log(concat("Review Log File in ccluserdir:",tmp_log->log_file_name))
 ENDIF
END GO
