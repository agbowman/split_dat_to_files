CREATE PROGRAM dm_feature_schema_refresh2:dba
 FREE SET all
 FREE SET max_table_list
 RECORD max_table_list(
   1 table_name[*]
     2 tname = c32
     2 feature_number = f8
     2 schema_dt_tm = dq8
     2 schema_status = c30
   1 table_count = i4
 )
 FREE SET feature_table_list
 RECORD feature_table_list(
   1 table_name[*]
     2 tname = c32
     2 schema_dt_tm = dq8
     2 fill_status = i4
     2 backout_ind = i4
     2 error_flag = i4
   1 table_count = i4
   1 nbr_errors = i4
   1 param_error = i4
 )
 SET parfile = "dm_schema"
 SET outfile1 = concat(parfile,"1.dat")
 SET outfile2 = concat(parfile,"2.dat")
 SET outfile3 = concat(parfile,"3.dat")
 CALL echo(outfile1)
 CALL echo(outfile2)
 CALL echo(outfile3)
 SET logfile1 = concat(parfile,"1.log")
 SET logfile2 = concat(parfile,"2.log")
 SET filename5 = concat(parfile,"5.dat")
 SET err_str = fillstring(255," ")
 SET env = cnvtupper(logical("ENVIRONMENT"))
 CALL echo(concat("environment: ",env))
 SET var_dt_tm = cnvtdatetime(curdate,curtime3)
 SET p = format(var_dt_tm,"MM/DD/YY HH:MM;;D")
 SET err_str = fillstring(200," ")
 SET error_flg = 0
 SET emsg = fillstring(132," ")
 SET ecode = 0
 SET re_dummy = 0
 SELECT INTO value(filename5)
  *
  FROM dual
  DETAIL
   err_str, row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
 SET feature_table_list->table_count = 0
 SET stat = alterlist(feature_table_list->table_name,10)
 SET max_table_list->table_count = 0
 SET stat = alterlist(max_table_list->table_name,10)
 SELECT INTO "nl:"
  a.table_name, a.feature_number, a.schema_dt_tm,
  a.table_env_status
  FROM dm_feature_tables_env a
  WHERE a.table_env_status="3"
   AND a.environment=env
  ORDER BY a.table_name
  DETAIL
   max_table_list->table_count = (max_table_list->table_count+ 1)
   IF (mod(max_table_list->table_count,10)=1
    AND (max_table_list->table_count != 1))
    stat = alterlist(max_table_list->table_name,(max_table_list->table_count+ 9))
   ENDIF
   max_table_list->table_name[max_table_list->table_count].tname = a.table_name, max_table_list->
   table_name[max_table_list->table_count].feature_number = a.feature_number, max_table_list->
   table_name[max_table_list->table_count].schema_dt_tm = a.schema_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_str = concat("No tables were refreshed ")
  SELECT INTO value(filename5)
   *
   FROM dual
   DETAIL
    "Error = ", err_str, row + 1,
    row + 1
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
  CALL echo(err_str)
  GO TO exit_script
 ENDIF
 FREE SET maxdate
 RECORD maxdate(
   1 var_dt_tm = dq8
 )
 SET error_flg = 0
 SET feature_table_list->param_error = 0
 SET feature_table_list->nbr_errors = 0
 SET maxdate->var_dt_tm = 0
 SET v_table_name = fillstring(30," ")
 FOR (cnt = 1 TO max_table_list->table_count)
   IF ((v_table_name != max_table_list->table_name[cnt].tname))
    SET v_table_name = max_table_list->table_name[cnt].tname
    SET feature_table_list->table_count = (feature_table_list->table_count+ 1)
    IF (mod(feature_table_list->table_count,10)=1
     AND (feature_table_list->table_count != 1))
     SET stat = alterlist(feature_table_list->table_name,(feature_table_list->table_count+ 9))
    ENDIF
    SET feature_table_list->table_name[feature_table_list->table_count].tname = v_table_name
    SET feature_table_list->table_name[feature_table_list->table_count].fill_status = 0
    SET feature_table_list->table_name[feature_table_list->table_count].backout_ind = 0
    SET feature_table_list->table_name[feature_table_list->table_count].error_flag = 0
    SET maxdate->var_dt_tm = 0
   ENDIF
   IF ((max_table_list->table_name[cnt].schema_dt_tm > maxdate->var_dt_tm))
    SET maxdate->var_dt_tm = max_table_list->table_name[cnt].schema_dt_tm
   ENDIF
   SET feature_table_list->table_name[feature_table_list->table_count].schema_dt_tm = maxdate->
   var_dt_tm
 ENDFOR
 FOR (cntw = 1 TO feature_table_list->table_count)
   EXECUTE dm_schema_comp "A", trim(feature_table_list->table_name[cntw].tname), cnvtdatetime(
    feature_table_list->table_name[cntw].schema_dt_tm)
   CALL echo(concat("table_name",feature_table_list->table_name[cntw].tname))
   SET p = format(feature_table_list->table_name[cntw].schema_dt_tm,"MM/DD/YY HH:MM;;D")
   CALL echo(p)
   IF ((feature_table_list->param_error=1))
    SET feature_table_list->param_error = 0
    SET feature_table_list->nbr_errors = 0
    SET err_str = concat("Schema compare error. Table ",feature_table_list->table_name[cntw].tname,
     " has bad parameters for DM_SCHEMA_COMP")
    SELECT INTO value(filename5)
     *
     FROM dual
     DETAIL
      "Error = ", err_str, row + 1,
      row + 1
     WITH format = stream, noheading, formfeed = none,
      maxcol = 512, maxrow = 1, append
    ;end select
    CALL echo(err_str)
   ENDIF
   IF ((feature_table_list->nbr_errors > 0))
    SET feature_table_list->table_name[cntw].error_flag = feature_table_list->nbr_errors
    SET err_str = concat("Schema compare error. Table ",feature_table_list->table_name[cntw].tname,
     "has ",cnvtstring(feature_table_list->nbr_errors)," differences")
    SET feature_table_list->nbr_errors = 0
    SELECT INTO value(filename5)
     *
     FROM dual
     DETAIL
      "Error = ", err_str, row + 1,
      row + 1
     WITH format = stream, noheading, formfeed = none,
      maxcol = 512, maxrow = 1, append
    ;end select
    CALL echo(err_str)
    CALL update_dm_table_tbls1(re_dummy)
   ELSE
    CALL update_dm_table_tbls2(re_dummy)
   ENDIF
 ENDFOR
 SUBROUTINE update_dm_table_tbls1(dummy)
  UPDATE  FROM dm_feature_tables_env
   SET table_env_status = "0"
   WHERE environment=env
    AND (table_name=feature_table_list->table_name[cntw].tname)
    AND table_env_status="3"
  ;end update
  COMMIT
 END ;Subroutine
 SUBROUTINE update_dm_table_tbls2(dummy)
  UPDATE  FROM dm_feature_tables_env
   SET table_env_status = "1"
   WHERE environment=env
    AND (table_name=feature_table_list->table_name[cntw].tname)
    AND table_env_status="3"
  ;end update
  COMMIT
 END ;Subroutine
#exit_script
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SELECT INTO value(filename5)
   *
   FROM dual
   DETAIL
    "Error = ", emsg, row + 1,
    row + 1
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
 ENDIF
END GO
