CREATE PROGRAM dm_fix_schema:dba
 FREE RECORD env_data
 RECORD env_data(
   1 connect_str = vc
   1 oper_sys = vc
 ) WITH persist
 FREE RECORD space_summary
 RECORD space_summary(
   1 rdate = dq8
   1 rseq = i4
 ) WITH persist
 SELECT INTO "nl:"
  FROM dm_tables d
  WHERE d.schema_date=cnvtdatetime( $2)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT
   *
   FROM dual
   DETAIL
    sch_date =  $2, col 0, "***************************",
    row + 1, col 0, "*** INVALID SCHEMA DATE ***",
    row + 1, col 0, "*** TERMINATING PROGRAM ***",
    row + 1, col 0, "***************************",
    row + 1, "The schema date '", sch_date,
    "' was not found in Admin database.", row + 1, "Please make sure a valid schema date is used."
   WITH nocounter
  ;end select
  GO TO end_program
 ENDIF
 IF (cnvtlower( $1)="fix_admin"
  AND ( $3=0))
  SELECT INTO "nl:"
   FROM dm_tables d
   WHERE d.table_name="DM_SCHEMA_VERSION"
    AND d.schema_date=cnvtdatetime( $2)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT
    *
    FROM dual
    DETAIL
     sch_date =  $2, col 0, "*********************************",
     row + 1, col 0, "*** INVALID ADMIN SCHEMA DATE ***",
     row + 1, col 0, "***    TERMINATING PROGRAM    ***",
     row + 1, col 0, "*********************************",
     row + 1, "The date '", sch_date,
     "' is not a valid Admin schema date.", row + 1,
     "Please make sure a valid Admin schema date is used."
    WITH nocounter
   ;end select
   GO TO end_program
  ENDIF
  SET env_data->connect_str = "cdba/cdba"
  IF (cursys="AIX")
   SET env_data->oper_sys = "AIX"
  ELSE
   SET env_data->oper_sys = "VMS"
  ENDIF
  SET space_summary->rdate = 0
  SET space_summary->rseq = 0
  GO TO skip_env_check
 ENDIF
 SELECT INTO "nl:"
  FROM dm_environment de
  WHERE (de.environment_id= $3)
  DETAIL
   env_data->connect_str = cnvtlower(de.v500_connect_string), env_data->oper_sys = de
   .target_operating_system
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT
   *
   FROM dual
   DETAIL
    env_id =  $3, col 0, "******************************",
    row + 1, col 0, "*** INVALID ENVIRONMENT ID ***",
    row + 1, col 0, "***  TERMINATING PROGRAM   ***",
    row + 1, col 0, "******************************",
    row + 1, "The environment id ", env_id";l",
    " was not found in Admin database.", row + 1, "Please make sure a valid environment id is used."
   WITH nocounter
  ;end select
  GO TO exit_program
 ENDIF
 IF ((((env_data->connect_str="")) OR (((findstring("/",env_data->connect_str)=0) OR (findstring("@",
  env_data->connect_str)=0)) )) )
  SELECT
   *
   FROM dual
   DETAIL
    col 0, "***************************************", row + 1,
    col 0, "*** INVALID DATABASE CONNECT STRING ***", row + 1,
    col 0, "***       TERMINATING PROGRAM       ***", row + 1,
    col 0, "***************************************", row + 1,
    "The database connect string for this environment is not valid.", row + 1,
    "Please use dm_env_maint to set this up correctly."
   WITH nocounter
  ;end select
  GO TO exit_program
 ENDIF
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
   AND (c.environment_id= $3)
  DETAIL
   space_summary->rdate = y, space_summary->rseq = rseq
  WITH nocounter
 ;end select
 CALL echo(concat("Space summary report used ",cnvtstring(space_summary->rseq)))
#skip_env_check
 EXECUTE dm_temp_check
 CALL parser("rdb alter session set nls_sort = BINARY go",1)
 FREE RECORD table_list
 RECORD table_list(
   1 table_name[*]
     2 tname = c32
     2 created_flg = i2
     2 process_flg = i2
     2 dms = vc
     2 row_count = f8
     2 output2_filename = vc
     2 output2sql_filename = vc
     2 output2com_filename = vc
     2 output3_filename = vc
     2 output3sql_filename = vc
     2 output4_filename = vc
     2 output2d_filename = vc
     2 output3d_filename = vc
     2 output4d_filename = vc
     2 file_done_flag = i2
   1 count = i4
 )
 SET stat = alterlist(table_list->table_name,0)
 SET table_list->count = 0
 FREE RECORD dropped_cons_list
 RECORD dropped_cons_list(
   1 cons_name[*]
     2 cname = c32
   1 cons_count = i4
 )
 SELECT INTO "nl:"
  FROM space_objects so,
   dm_table_list dtl,
   dm_tables_doc dtd
  WHERE ((dtl.process_flg=1) OR (dtl.process_flg=3))
   AND so.segment_name=outerjoin(dtl.table_name)
   AND so.report_seq=outerjoin(space_summary->rseq)
   AND dtd.table_name=dtl.table_name
  ORDER BY so.row_count DESC
  DETAIL
   table_list->count = (table_list->count+ 1), stat = alterlist(table_list->table_name,table_list->
    count), table_list->table_name[table_list->count].tname = dtl.table_name,
   table_list->table_name[table_list->count].created_flg = 0, table_list->table_name[table_list->
   count].process_flg = dtl.process_flg, table_list->table_name[table_list->count].row_count = so
   .row_count
   IF (so.row_count > 100000)
    dms = substring(1,13,cnvtlower(cnvtalphanum(dtd.data_model_section)))
   ELSE
    dms = "routine"
   ENDIF
   table_list->table_name[table_list->count].dms = dms, table_list->table_name[table_list->count].
   output2_filename = cnvtlower(build( $1,"_",dms,"_2")), table_list->table_name[table_list->count].
   output2sql_filename = cnvtlower(build( $1,"_",dms,"_2.sql")),
   table_list->table_name[table_list->count].output2com_filename = cnvtlower(build( $1,"_",dms,
     "_2.com")), table_list->table_name[table_list->count].output2d_filename = cnvtlower(build( $1,
     "_",dms,"_2d")), table_list->table_name[table_list->count].output3_filename = cnvtlower(build(
      $1,"_",dms,"_3")),
   table_list->table_name[table_list->count].output3sql_filename = cnvtlower(build( $1,"_",dms,
     "_3.lst")), table_list->table_name[table_list->count].output3d_filename = cnvtlower(build( $1,
     "_",dms,"_3d")), table_list->table_name[table_list->count].output4_filename = cnvtlower(build(
      $1,"_",dms,"_4.dat")),
   table_list->table_name[table_list->count].output4d_filename = cnvtlower(build( $1,"_",dms,
     "_4d.dat")), table_list->table_name[table_list->count].file_done_flag = 0
  WITH nocounter
 ;end select
 SET routine_index = 0
 FOR (i = 1 TO table_list->count)
   IF ((table_list->table_name[i].file_done_flag=0))
    EXECUTE FROM init_file_begin TO init_file_end
    IF ((table_list->table_name[i].dms="routine"))
     SET routine_index = i
    ENDIF
    FOR (j = i TO table_list->count)
      IF ((table_list->table_name[j].dms=table_list->table_name[i].dms))
       SET table_list->table_name[j].file_done_flag = 1
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET tname = fillstring(32," ")
 FOR (loopcount = 1 TO table_list->count)
   SET tname = cnvtupper(table_list->table_name[loopcount].tname)
   SELECT INTO "nl:"
    FROM dm_tables dt
    WHERE dt.table_name=tname
     AND dt.schema_date=cnvtdatetime( $2)
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM dm_user_tab_cols ut
     WHERE ut.table_name=dt.table_name)))
    WITH nocounter
   ;end select
   IF (curqual=1)
    SET x = 1
    EXECUTE dm_create_tables loopcount,  $2
    SET table_list->table_name[loopcount].created_flg = 1
   ENDIF
 ENDFOR
 SET tname = fillstring(32," ")
 FOR (loopcount = 1 TO table_list->count)
   SET tname = cnvtupper(table_list->table_name[loopcount].tname)
   SET stat = alterlist(dropped_cons_list->cons_name,0)
   SET dropped_cons_list->cons_count = 0
   IF ((table_list->table_name[loopcount].created_flg != 1))
    SET x = 2
    EXECUTE dm_fix_columns loopcount,  $2
   ENDIF
   SET x = 3
   EXECUTE dm_fix_indexes loopcount,  $2,  $3
   SET x = 4
   EXECUTE dm_fix_constraints loopcount,  $2
   IF ((table_list->table_name[loopcount].created_flg != 1))
    EXECUTE dm_fix_columns_null loopcount,  $2
   ENDIF
   SET table_list->table_name[loopcount].file_done_flag = 0
 ENDFOR
 FOR (i = 1 TO table_list->count)
   IF ((table_list->table_name[i].file_done_flag=0))
    EXECUTE FROM call_dcl_begin TO call_dcl_end
    FOR (j = i TO table_list->count)
      IF ((table_list->table_name[j].dms=table_list->table_name[i].dms))
       SET table_list->table_name[j].file_done_flag = 1
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 FOR (loopcount = 1 TO table_list->count)
   SET tname = cnvtupper(table_list->table_name[loopcount].tname)
   IF ((table_list->table_name[loopcount].created_flg != 1))
    EXECUTE dm_fix_null_constraints loopcount,  $2
   ENDIF
   SET table_list->table_name[loopcount].file_done_flag = 0
 ENDFOR
 IF (routine_index > 0)
  EXECUTE dm_fix_seq routine_index,  $2
 ENDIF
 FOR (i = 1 TO table_list->count)
   IF ((table_list->table_name[i].file_done_flag=0))
    EXECUTE FROM terminate_file_begin TO terminate_file_end
    FOR (j = i TO table_list->count)
      IF ((table_list->table_name[j].dms=table_list->table_name[i].dms))
       SET table_list->table_name[j].file_done_flag = 1
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 GO TO end_program
#init_file_begin
 FREE RECORD dcl_str
 RECORD dcl_str(
   1 str = vc
 )
 SELECT INTO value(table_list->table_name[i].output2_filename)
  *
  FROM dual
  DETAIL
   "%o  ", table_list->table_name[i].output4_filename, row + 1,
   "%d echo on", row + 1, "set message 0 go",
   row + 1, row + 1, "; This file is generated by DM_FIX_SCHEMA for uptime changes",
   row + 1
   IF ((table_list->table_name[i].dms != "routine"))
    "; for the ", table_list->table_name[i].dms, " data model section.",
    row + 1
   ENDIF
   "; Started at ", curdate"DD-MMM-YYYY;;D", " ",
   curtime"HH:MM:SS;;M", row + 1, row + 1,
   "set msg=fillstring(132,' ') go", row + 1, "set filename3='",
   table_list->table_name[i].output3_filename, "' go", row + 1,
   "set trace symbol mark go", row + 1, row + 1,
   "select into value(filename3) * from dual", row + 1, "detail",
   row + 1, "  '; DM_FIX_SCHEMA Uptime Error Logging file generated after running',row+1", row + 1,
   "  '; fix schema output for the ", table_list->table_name[i].dms, "', row+1",
   row + 1, "  '; data model section.', row+1", row + 1,
   "  '; Started at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'", ", row+1, row+1", row + 1,
   "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go", row + 1,
   "execute dm_user_last_updt go",
   row + 1, "record duds (", row + 1,
   "  1 tname = vc", row + 1, "  1 qual_cnt = i4",
   row + 1, "  1 qual[*]", row + 1,
   "  2 cname = vc", row + 1, "  2 default_value = vc",
   row + 1, "  2 data_type = vc", row + 1,
   ") go", row + 1, row + 1,
   row + 1
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 IF ((env_data->oper_sys != "AIX"))
  SELECT INTO value(table_list->table_name[i].output2com_filename)
   *
   FROM dual
   DETAIL
    "$! This COM file is generated by DM_FIX_SCHEMA for uptime changes", row + 1
    IF ((table_list->table_name[i].dms != "routine"))
     "$! for the ", table_list->table_name[i].dms, " data model section.",
     row + 1
    ENDIF
    "$! Started at ", curdate"DD-MMM-YYYY ;;D", " ",
    curtime"HH:MM:SS;;M", row + 1
    IF ((env_data->oper_sys != "AIX"))
     "$! This proc is called from the *2.dat file and it executes", row + 1,
     "$! the *.sql file before doing anything in the uptime *2.dat file.",
     row + 1, "$@ora_util:orauser.com", row + 1,
     "$sqlplus ", env_data->connect_str, " @CCLUSERDIR:",
     table_list->table_name[i].output2sql_filename, " -SILENT", row + 1
    ELSE
     "$! Since the current OS is AIX, this com file will not be used.", row + 1,
     "$! Including the *2.dat file in CCL will execute the *.sql script."
    ENDIF
   WITH format = variable, noheading, formfeed = none,
    maxcol = 512, maxrow = 1
  ;end select
 ENDIF
 SELECT INTO value(table_list->table_name[i].output2sql_filename)
  *
  FROM dual
  DETAIL
   "REM ** This SQL file is generated by DM_FIX_SCHEMA for uptime changes", row + 1
   IF ((table_list->table_name[i].dms != "routine"))
    "REM ** for the ", table_list->table_name[i].dms, " data model section.",
    row + 1
   ENDIF
   "REM ** Started at ", curdate"DD-MMM-YYYY ;;D", " ",
   curtime"HH:MM:SS;;M", row + 1, row + 1,
   "REM ** This file will be executed from the *2.dat uptime output file", row + 1,
   "REM ** before doing anything else.",
   row + 1
   IF ((env_data->oper_sys != "AIX"))
    "spool CCLUSERDIR:", table_list->table_name[i].output3sql_filename, row + 1
   ELSE
    "spool $CCLUSERDIR/", table_list->table_name[i].output3sql_filename, row + 1
   ENDIF
   row + 1
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(table_list->table_name[i].output2d_filename)
  *
  FROM dual
  DETAIL
   "%o  ", table_list->table_name[i].output4d_filename, row + 2,
   "%d echo on", row + 1, "set message 0 go",
   row + 1, row + 1, "; This file is generated by DM_FIX_SCHEMA for downtime changes",
   row + 1
   IF ((table_list->table_name[i].dms != "routine"))
    "; for the ", table_list->table_name[i].dms, " data model section.",
    row + 1
   ENDIF
   "; Started at ", curdate"DD-MMM-YYYY ;;D", " ",
   curtime"HH:MM:SS;;M", row + 1, row + 1,
   "set msg=fillstring(132,' ') go", row + 1, "set filename3='",
   table_list->table_name[i].output3d_filename, "' go", row + 1,
   "set trace symbol mark go", row + 1, "select into value(filename3) * from dual",
   row + 1, "detail", row + 1,
   "  '; DM_FIX_SCHEMA Downtime Error Logging file generated after running'", ", row+1", row + 1,
   "  '; fix schema output for the ", table_list->table_name[i].dms, "', row+1",
   row + 1, "  '; data model section.', row+1", row + 1,
   "  '; Started at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'", ", row+1, row+1", row + 1,
   "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go", row + 2
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(table_list->table_name[i].output3_filename)
  *
  FROM dual
  DETAIL
   " ", row + 1
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(table_list->table_name[i].output3d_filename)
  *
  FROM dual
  DETAIL
   " ", row + 1
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(table_list->table_name[i].output3sql_filename)
  *
  FROM dual
  DETAIL
   " ", row + 1
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
#init_file_end
#call_dcl_begin
 SELECT INTO value(table_list->table_name[i].output2_filename)
  *
  FROM dual
  DETAIL
   row + 1, row + 1, "select into value(filename3) * from dual",
   row + 1, "detail", row + 1,
   "  row+1", row + 1, "  '; Now attempting to run *.sql script from sqlplus ...', row+2",
   row + 1, "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go", row + 1,
   row + 1, "; The following CALL DCL() will attempt to", row + 1,
   "; run the *.sql script from sqlplus", row + 1
   IF ((env_data->oper_sys != "AIX"))
    dcl_str->str = build("@CCLUSERDIR:",table_list->table_name[i].output2com_filename)
   ELSE
    dcl_str->str = concat("$ORACLE_HOME/bin/sqlplus ",trim(env_data->connect_str)," @$CCLUSERDIR/",
     trim(table_list->table_name[i].output2sql_filename))
   ENDIF
   "free record dcl_com go", row + 1, "record dcl_com ( 1 str = c100 1 len = i4) go",
   row + 1, "set dcl_com->str = '", dcl_str->str,
   "' go", row + 1, "set dcl_com->len = size(trim(dcl_com->str)) go",
   row + 1, "set status = 0 go", row + 1,
   "call dcl(dcl_com->str,dcl_com->len,status) go", row + 1, row + 1,
   "select into value(filename3) * from dual", row + 1, "detail",
   row + 1, "  row+1", row + 1,
   "  '; Finished running *.sql script from sqlplus', row+1", row + 1,
   "  '; Please look at CCLUSERDIR:",
   table_list->table_name[i].output3sql_filename, "', row+1", row + 1,
   "  '; to check for errors from sqlplus', row+2", row + 1,
   "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go",
   row + 1
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
#call_dcl_end
#terminate_file_begin
 SELECT INTO value(table_list->table_name[i].output2_filename)
  *
  FROM dual
  DETAIL
   "execute dm_user_last_updt go", row + 1, "select into value(filename3) * from dual",
   row + 1, "detail", row + 1,
   "  '; End of Uptime Error Logging file generated after running',row+1", row + 1,
   "  '; fix schema output for the ",
   table_list->table_name[i].dms, "', row+1", row + 1,
   "  '; data model section.', row+1", row + 1,
   "  '; Ended at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'",
   row + 1, "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go", row + 1,
   row + 1, row + 1, row + 1,
   "; End of file", row + 1, "; Ended at ",
   curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
   row + 1, "%o"
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
 SELECT INTO value(table_list->table_name[i].output2d_filename)
  *
  FROM dual
  DETAIL
   "execute dm_user_last_updt go", row + 1, "select into value(filename3) * from dual",
   row + 1, "detail", row + 1,
   "  '; End of Downtime Error Logging file generated after running',row+1", row + 1,
   "  '; fix schema output for the ",
   table_list->table_name[i].dms, "', row+1", row + 1,
   "  '; data model section.', row+1", row + 1,
   "  '; Ended at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'",
   row + 1, "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go", row + 1,
   row + 1, row + 1, row + 1,
   "; End of file", row + 1, "; Ended at ",
   curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
   row + 1, "%o"
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
 SELECT INTO value(table_list->table_name[i].output2sql_filename)
  *
  FROM dual
  DETAIL
   "REM ** End of file", row + 1, "REM ** Ended at ",
   curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
   row + 1, "select concat('End of file at ',to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'))",
   " from dual;",
   row + 1
   IF ((env_data->oper_sys != "AIX"))
    "spool off"
   ELSE
    "spool off", row + 1, "exit"
   ENDIF
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
#terminate_file_end
#exit_program
#end_program
END GO
