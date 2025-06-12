CREATE PROGRAM dm_ocd_install_schema:dba
 CALL parser("rdb alter session set nls_sort = BINARY go",1)
 SET filename2 = build("dm_ocd_fix_schema2_",ocd_number)
 SET filename3 = build("dm_ocd_fix_schema3_",ocd_number)
 SET filename4 = build("dm_ocd_fix_schema4_",ocd_number,".dat")
 SET sqlfile2 = build("dm_ocd_fix_schema2_",ocd_number,".sql")
 SET sqlfile3 = build("dm_ocd_fix_schema3_",ocd_number,".lst")
 SET comfile2 = build("dm_ocd_fix_schema2_",ocd_number,".com")
 SET comfile3 = build("dm_ocd_fix_schema3_",ocd_number,".log")
 SET reset_error = 1
 SET loopcount = 0
 SET errstr = fillstring(110," ")
 EXECUTE FROM init_error_files_begin TO init_error_files_end
 FREE RECORD env_data
 RECORD env_data(
   1 env_id = i4
   1 env_name = vc
   1 connect_str = vc
   1 oper_sys = vc
   1 envset_str = vc
 )
 SELECT INTO "nl:"
  d.environment_id
  FROM dm_environment d
  WHERE d.environment_id=env_id
  DETAIL
   env_data->env_id = d.environment_id, env_data->env_name = d.environment_name, env_data->oper_sys
    = d.target_operating_system,
   env_data->connect_str = cnvtlower(d.v500_connect_string), env_data->envset_str = cnvtlower(d
    .envset_string)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Invalid Environment Id")
  SELECT INTO value(filename3)
   FROM dual
   DETAIL
    "Error = Invalid environment id!", row + 1, "Environment id ",
    env_id, "' not found!"
   WITH noheading, format = variable, formfeed = none,
    maxrow = 1, maxcol = 512, append
  ;end select
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = concat("Environment id ",trim(cnvtstring(env_id))," is not valid!")
  GO TO end_program
 ENDIF
 IF ((env_data->connect_str=""))
  CALL echo("Invalid Connect string")
  SELECT INTO value(filename3)
   FROM dual
   DETAIL
    "Error = Connect string not found!", row + 1, "Environment '",
    env_data->env_name, "' does not have a valid connect string!"
   WITH noheading, format = variable, formfeed = none,
    maxrow = 1, maxcol = 512, append
  ;end select
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = concat("Environment '",trim(env_data->env_name),
   "' does not have a valid connect string!")
  GO TO end_program
 ENDIF
 IF ((env_data->oper_sys="AIX")
  AND (((env_data->connect_str="admin")) OR ((env_data->connect_str=""))) )
  CALL echo("Invalid Envset string")
  SELECT INTO value(filename3)
   FROM dual
   DETAIL
    "Error = Invalid Envset string!", row + 1, "Environment '",
    env_data->env_name, "' does not have a valid envset string!"
   WITH noheading, format = variable, formfeed = none,
    maxrow = 1, maxcol = 512, append
  ;end select
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = concat("Environment '",trim(env_data->env_name),
   "' does not have a valid envset string!")
  GO TO end_program
 ENDIF
 EXECUTE FROM init_files_begin TO init_files_end
 FREE RECORD space_summary
 RECORD space_summary(
   1 rdate = dq8
   1 rseq = i4
 )
 SELECT INTO "nl:"
  rseq = max(a.report_seq), y = max(a.begin_date)
  FROM ref_report_log a,
   ref_report_parms_log b,
   ref_instance_id c
  WHERE a.report_seq=b.report_seq
   AND b.parm_cd=1
   AND a.report_cd=1
   AND a.end_date IS NOT null
   AND b.parm_value=cnvtstring(c.instance_cd)
   AND (c.environment_id=env_data->env_id)
  DETAIL
   space_summary->rdate = y, space_summary->rseq = rseq
  WITH nocounter
 ;end select
 IF ((space_summary->rseq=0))
  SELECT INTO value(filename2)
   *
   FROM dual
   DETAIL
    row + 1, "select into value(filename3) * from dual", row + 1,
    "detail", row + 1, "  ';WARNING: No space summary report found!', row+1",
    row + 1, "  ';Default sizing parameters will be used.', row+1, row+1", row + 1,
    "with format=variable,formfeed=none,maxcol=512,maxrow=1,append go", row + 1, row + 1
   WITH format = variable, noheading, formfeed = none,
    maxcol = 512, maxrow = 1
  ;end select
 ENDIF
 FREE SET table_list
 RECORD table_list(
   1 table_name[*]
     2 tname = c32
     2 created_flg = i2
   1 table_count = i4
 )
 SET stat = alterlist(table_list->table_name,0)
 SET table_list->table_count = 0
 FREE SET d_cons
 RECORD d_cons(
   1 cons_cnt = i4
   1 cons[*]
     2 cons_name = c30
     2 create_ind = i2
     2 tbl_name = c30
     2 cons_type = c1
     2 parent_table = vc
     2 parent_table_columns = vc
     2 r_constraint_name = vc
     2 status_ind = i2
     2 cons_col_cnt = i4
     2 cons_col[*]
       3 col_name = vc
       3 col_pos = i2
 )
 SET stat = alterlist(d_cons->cons,0)
 SET d_cons->cons_cnt = 0
 SELECT INTO "nl:"
  FROM dm_alpha_features_env da
  WHERE da.alpha_feature_nbr=ocd_number
   AND ((da.status != "SUCCESS") OR (da.status = null))
   AND (da.environment_id=env_data->env_id)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM dm_alpha_features_env da
   WHERE da.alpha_feature_nbr=ocd_number
    AND da.status="SUCCESS"
    AND (da.environment_id=env_data->env_id)
   WITH nocounter
  ;end select
  IF (curqual=1)
   SELECT INTO value(filename3)
    FROM dual
    DETAIL
     "WARNING!", row + 1, "The schema on this OCD has already been installed successfully.",
     row + 1, "No schema changes will be made... exiting OCD Fix Schema program."
    WITH noheading, format = variable, formfeed = none,
     maxrow = 1, maxcol = 512, append
   ;end select
  ELSE
   SELECT INTO value(filename3)
    FROM dual
    DETAIL
     "WARNING!", row + 1, "OCD row not found in dm_alpha_features_env for this environment.",
     row + 1, "No schema changes will be made... exiting OCD Fix Schema program."
    WITH noheading, format = variable, formfeed = none,
     maxrow = 1, maxcol = 512, append
   ;end select
  ENDIF
  GO TO end_program
 ENDIF
 UPDATE  FROM dm_alpha_features_env da
  SET da.status = "RUNNING FIX SCHEMA"
  WHERE da.alpha_feature_nbr=ocd_number
   AND (da.environment_id=env_data->env_id)
   AND da.status != "SUCCESS"
  WITH nocounter
 ;end update
 COMMIT
 SET loopcount = 0
 SET tname = fillstring(32," ")
 SET d_table = fillstring(30," ")
 SET d_tbl_ptr = 0
 SET u_tbl_ptr = 0
 FOR (loopcount = 1 TO bn_ocd->tbl_cnt)
   SET d_tbl_ptr = loopcount
   SET d_table = bn_ocd->tbl[d_tbl_ptr].tbl_name
   SET u_tbl_ptr = 0
   SET tname = bn_ocd->tbl[d_tbl_ptr].tbl_name
   SET old_tbl_ind = 0
   SET table_list->table_count = (table_list->table_count+ 1)
   SET stat = alterlist(table_list->table_name,table_list->table_count)
   SET table_list->table_name[table_list->table_count].tname = d_table
   SET table_list->table_name[table_list->table_count].created_flg = 0
   SELECT INTO "nl:"
    FROM dm_user_tab_cols d
    WHERE d.table_name=d_table
    DETAIL
     old_tbl_ind = 1
    WITH nocounter
   ;end select
   IF (old_tbl_ind=0)
    EXECUTE dm_ocd_create_tables d_tbl_ptr
    SET table_list->table_name[table_list->table_count].created_flg = 1
   ENDIF
 ENDFOR
 SET loopcount = 0
 SET tname = fillstring(32," ")
 SET d_table = fillstring(30," ")
 SET d_tbl_ptr = 0
 SET u_tbl_ptr = 0
 FOR (loopcount = 1 TO bn_ocd->tbl_cnt)
   IF ((table_list->table_name[loopcount].created_flg != 1))
    SET d_tbl_ptr = loopcount
    SET d_table = bn_ocd->tbl[d_tbl_ptr].tbl_name
    SET u_tbl_ptr = 0
    SET tname = bn_ocd->tbl[d_tbl_ptr].tbl_name
    FOR (i = 1 TO curdb->tbl_cnt)
      IF ((curdb->tbl[i].tbl_name=d_table))
       SET u_tbl_ptr = i
       SET i = curdb->tbl_cnt
      ENDIF
    ENDFOR
    EXECUTE dm_ocd_fix_columns d_tbl_ptr, u_tbl_ptr
    SELECT INTO value(filename2)
     *
     FROM dual
     DETAIL
      "execute oragen3 '", d_table, "' go",
      row + 1
     WITH format = stream, noheading, formfeed = none,
      maxcol = 512, maxrow = 1, append
    ;end select
   ENDIF
 ENDFOR
 EXECUTE FROM call_dcl_begin TO call_dcl_end
 SET loopcount = 0
 SET tname = fillstring(32," ")
 SET d_table = fillstring(30," ")
 SET d_tbl_ptr = 0
 SET u_tbl_ptr = 0
 FOR (loopcount = 1 TO bn_ocd->tbl_cnt)
   SET d_tbl_ptr = loopcount
   SET d_table = bn_ocd->tbl[d_tbl_ptr].tbl_name
   SET u_tbl_ptr = 0
   SET tname = bn_ocd->tbl[d_tbl_ptr].tbl_name
   IF ((table_list->table_name[loopcount].created_flg != 1))
    FOR (i = 1 TO curdb->tbl_cnt)
      IF ((curdb->tbl[i].tbl_name=d_table))
       SET u_tbl_ptr = i
       SET i = curdb->tbl_cnt
      ENDIF
    ENDFOR
    EXECUTE dm_ocd_fix_null_constraints d_tbl_ptr, u_tbl_ptr
    EXECUTE dm_ocd_fix_indexes d_tbl_ptr, u_tbl_ptr
    EXECUTE dm_ocd_fix_constraints d_tbl_ptr, u_tbl_ptr, "P"
    EXECUTE dm_ocd_fix_constraints d_tbl_ptr, u_tbl_ptr, "U"
    EXECUTE dm_ocd_fix_constraints d_tbl_ptr, u_tbl_ptr, "R"
    EXECUTE dm_ocd_fix_columns_null d_tbl_ptr, u_tbl_ptr
   ELSE
    EXECUTE dm_ocd_fix_constraints d_tbl_ptr, 0, "R"
   ENDIF
 ENDFOR
 FOR (ccnt = 1 TO d_cons->cons_cnt)
   IF ((d_cons->cons[ccnt].create_ind=1))
    EXECUTE dm_ocd_create_constraint 0, ccnt, 0
   ENDIF
 ENDFOR
 EXECUTE FROM terminate_files_begin TO terminate_files_end
 SET docd_reply->status = "S"
 GO TO end_program
#call_dcl_begin
 FREE RECORD dcl_str
 RECORD dcl_str(
   1 str = vc
 )
 SELECT INTO value(filename2)
  *
  FROM dual
  DETAIL
   row + 1, row + 1, "select into value(filename3) * from dual",
   row + 1, "detail", row + 1,
   "  row+1", row + 1, "  '; Now attempting to run *.sql script from sqlplus ...', row+2",
   row + 1, "with format=variable, formfeed=none, maxcol=256, maxrow=1, append go", row + 1,
   row + 1, "; The following CALL DCL() will attempt to", row + 1,
   "; run the *.sql script from sqlplus", row + 1
   IF ((env_data->oper_sys != "AIX"))
    dcl_str->str = build("@CCLUSERDIR:",comfile2)
   ELSE
    dcl_str->str = concat("$ORACLE_HOME/bin/sqlplus ",trim(env_data->connect_str)," @$CCLUSERDIR/",
     trim(sqlfile2))
   ENDIF
   "free record dcl_com go", row + 1, "record dcl_com ( 1 str = c120 1 len = i4) go",
   row + 1, "set dcl_com->str = '", dcl_str->str,
   "' go", row + 1, "set dcl_com->len = size(trim(dcl_com->str)) go",
   row + 1, "set status = 0 go", row + 1,
   "call dcl(dcl_com->str,dcl_com->len,status) go", row + 1, row + 1,
   "select into value(filename3) * from dual", row + 1, "detail",
   row + 1, "  row+1", row + 1,
   "  '; Finished running *.sql script from sqlplus', row+1", row + 1,
   "  '; Please look at CCLUSERDIR:",
   sqlfile3, "', row+1", row + 1,
   "  '; to check for errors from sqlplus', row+2", row + 1,
   "with format=variable, formfeed=none, maxcol=256, maxrow=1, append go",
   row + 1
  WITH format = variable, noheading, formfeed = none,
   maxcol = 150, maxrow = 1, append
 ;end select
#call_dcl_end
#init_files_begin
 SELECT INTO value(filename2)
  *
  FROM dual
  DETAIL
   "; This file is generated by DM_OCD_FIX_SCHEMA", row + 1, "; Time stamp: ",
   curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
   row + 1, row + 1, "%o  ",
   filename4, row + 2, filestr = concat("set filename3 = '",trim(filename3),"' go"),
   filestr, row + 1, row + 1,
   "select into value(filename3) * from dual", row + 1, "detail",
   row + 1, "  '; DM_OCD_FIX_SCHEMA Error Logging file generated after running', row+1", row + 1,
   "  '; fix schema output for OCD ", ocd_number";L;", "', row+1",
   row + 1, "  '; Started at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'", ", row+1, row+1",
   row + 1, "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go", row + 1
   IF (reset_error=1)
    "set error_msg=fillstring(255,' ') go", row + 1, "set msg=fillstring(255,' ') go",
    row + 1, "set rstring=fillstring(155,' ') go", row + 1,
    "set rstring1=fillstring(155,' ') go", row + 1, "set msgnum=0 go",
    row + 1, reset_error = 0
   ENDIF
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(filename3)
  *
  FROM dual
  DETAIL
   " ", row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SET reset_error = 1
 SELECT INTO value(sqlfile2)
  *
  FROM dual
  DETAIL
   "REM This file is generated by DM_OCD_FIX_SCHEMA", row + 1, "REM Time stamp: ",
   curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
   row + 1, row + 1
   IF ((env_data->oper_sys != "AIX"))
    "spool CCLUSERDIR:", sqlfile3, row + 1
   ELSE
    "spool $CCLUSERDIR/", sqlfile3, row + 1
   ENDIF
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(comfile2)
  *
  FROM dual
  DETAIL
   "$! This COM file is generated by DM_OCD_FIX_SCHEMA", row + 1, "$! Time stamp: ",
   curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
   row + 1, row + 1
   IF ((env_data->oper_sys != "AIX"))
    "$! This proc is called from the 2.dat file and it executes", row + 1, "$! the *.sql script.",
    row + 1, "$@ora_util:orauser.com", row + 1,
    "$set verify", row + 1, '$define sys$output "ccluserdir:',
    comfile3, '"', row + 1,
    row + 1, "$sqlplus ", env_data->connect_str,
    " @CCLUSERDIR:", sqlfile2, row + 1,
    row + 1, "$set nover", row + 1,
    "$deassign sys$output", row + 1
   ELSE
    "$! Since the current OS is AIX, this com file will not be used.", row + 1,
    "$! Including the *2.dat file in CCL will execute the *.sql script."
   ENDIF
  WITH format = variable, noheading, formfeed = none,
   maxcol = 150, maxrow = 1
 ;end select
#init_files_end
#init_error_files_begin
 SELECT INTO value(filename2)
  *
  FROM dual
  DETAIL
   "; This file is generated by DM_OCD_FIX_SCHEMA", row + 1, "; Time stamp: ",
   curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
   row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(filename3)
  *
  FROM dual
  DETAIL
   " ", row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SET reset_error = 1
 SELECT INTO value(sqlfile2)
  *
  FROM dual
  DETAIL
   "REM This file is generated by DM_OCD_FIX_SCHEMA", row + 1, "REM Time stamp: ",
   curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
   row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(comfile2)
  *
  FROM dual
  DETAIL
   "$! This COM file is generated by DM_OCD_FIX_SCHEMA", row + 1, "$! Time stamp: ",
   curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
   row + 1
  WITH format = variable, noheading, formfeed = none,
   maxcol = 150, maxrow = 1
 ;end select
#init_error_files_end
#terminate_files_begin
 SELECT INTO value(filename2)
  *
  FROM dual
  DETAIL
   "execute dm_user_last_updt go", row + 1, "select into value(filename3) * from dual",
   row + 1, "detail", row + 1,
   "  '; End of Error Logging file',row+1", row + 1,
   "  '; Ended at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'",
   row + 1, "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go", row + 1,
   "%o", row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
 SELECT INTO value(sqlfile2)
  *
  FROM dual
  DETAIL
   row + 1
   IF ((env_data->oper_sys != "AIX"))
    "spool off"
   ELSE
    "spool off", row + 1, "exit"
   ENDIF
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
#terminate_files_end
#end_program
END GO
