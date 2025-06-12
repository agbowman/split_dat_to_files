CREATE PROGRAM dm_first_schema_refresh:dba
 FREE SET all
 FREE SET feature_table_list
 RECORD feature_table_list(
   1 table_name[*]
     2 tname = c32
     2 fill_status = i4
     2 backout_ind = i4
     2 feature_number = f8
     2 schema_dt_tm = dq8
     2 schema_status = c30
     2 error_flag = i4
   1 table_count = i4
   1 nbr_errors = i4
   1 param_error = i4
 )
 FREE SET feature_list
 RECORD feature_list(
   1 feature_number[*]
     2 feature_nbr = i4
   1 feature_count = i4
 )
 SET dom_name = cnvtupper( $1)
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
   maxcol = 512, maxrow = 1
 ;end select
 IF (dom_name != "2B"
  AND dom_name != "3B"
  AND dom_name != "0B"
  AND dom_name != "0C")
  SET error_flg = 1
  SET err_str = "Incorrect specified status: possible values 2B and 3B"
 ENDIF
 IF (error_flg > 0)
  SET error_flg = 0
  SELECT INTO value(filename5)
   *
   FROM dual
   DETAIL
    "Error = ", err_str, row + 1,
    row + 1
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
  GO TO exit_script
 ENDIF
 SET feature_table_list->table_count = 0
 SET stat = alterlist(feature_table_list->table_name,10)
 SET feature_list->feature_count = 0
 SET stat = alterlist(feature_list->feature_number,10)
 SELECT DISTINCT INTO "nl:"
  b.table_name
  FROM dm_features a,
   dm_feature_tables_env b
  WHERE ((a.feature_status=dom_name) OR (a.feature_number=1
   AND ((b.table_name="CSM_LST_CONTACT") OR (((b.table_name="DISPENSE_HX") OR (((b.table_name=
  "FILL_PRINT_ORD_HX") OR (((b.table_name="HAPLOTYPE_CHART") OR (((b.table_name="ORDER_DISPENSE") OR
  (((b.table_name="PHA_PRODUCT") OR (b.table_name="SCH_EVENT_ATTACH")) )) )) )) )) )) ))
   AND a.feature_number=b.feature_number
   AND b.environment=env
  DETAIL
   feature_table_list->table_count = (feature_table_list->table_count+ 1)
   IF (mod(feature_table_list->table_count,10)=1
    AND (feature_table_list->table_count != 1))
    stat = alterlist(feature_table_list->table_name,(feature_table_list->table_count+ 9))
   ENDIF
   feature_table_list->table_name[feature_table_list->table_count].tname = b.table_name, feature_list
   ->feature_count = (feature_list->feature_count+ 1)
   IF (mod(feature_list->feature_count,10)=1
    AND (feature_list->feature_count != 1))
    stat = alterlist(feature_list->feature_number,(feature_list->feature_count+ 9))
   ENDIF
   feature_list->feature_number[feature_list->feature_count].feature_nbr = a.feature_number
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_str = concat("No tables found in dm_feature_tables_env for features in dm_features ",
   "or no feature was found in dm_features with the required status")
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
 FOR (cnt = 1 TO feature_table_list->table_count)
   SET feature_table_list->table_name[cnt].backout_ind = 0
   SET feature_table_list->table_name[cnt].error_flag = 0
   FREE SET maxdate
   RECORD maxdate(
     1 var_dt_tm = dq8
   )
   SET maxdate->var_dt_tm = 0
   SELECT
    IF (dom_name="0B")
     WHERE (a.table_name=feature_table_list->table_name[cnt].tname)
      AND b.feature_status >= "2C"
      AND b.feature_status != "2F"
      AND b.feature_status != "3F"
      AND a.feature_number=b.feature_number
      AND a.environment=env
    ELSEIF (dom_name="0C")
     WHERE (a.table_name=feature_table_list->table_name[cnt].tname)
      AND b.feature_status >= "3C"
      AND b.feature_status != "3F"
      AND a.feature_number=b.feature_number
      AND a.environment=env
    ELSE
     WHERE (a.table_name=feature_table_list->table_name[cnt].tname)
      AND b.feature_status >= dom_name
      AND b.feature_status != "2F"
      AND b.feature_status != "3F"
      AND a.feature_number=b.feature_number
      AND a.environment=env
    ENDIF
    INTO "nl:"
    a.schema_dt_tm
    FROM dm_feature_tables_env a,
     dm_features b
    DETAIL
     IF ((a.schema_dt_tm > maxdate->var_dt_tm))
      maxdate->var_dt_tm = a.schema_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0
    AND ((dom_name="0b") OR (dom_name="0c")) )
    CALL echo(concat("FEATURE 0B ",feature_table_list->table_name[cnt].tname," = 0"))
    SET feature_table_list->table_name[cnt].backout_ind = 1
    SET feature_table_list->table_name[cnt].schema_dt_tm = cnvtdatetime(curdate,curtime3)
    SET p = format(feature_table_list->table_name[cnt].schema_dt_tm,"MM/DD/YY HH:MM;;D")
    CALL echo(p)
   ENDIF
   SET p = format(maxdate->var_dt_tm,"MM/DD/YY HH:MM;;D")
   IF ((feature_table_list->table_name[cnt].backout_ind=0))
    SELECT INTO "nl:"
     a.feature_number, a.table_name, a.schema_dt_tm,
     a.table_env_status
     FROM dm_feature_tables_env a
     WHERE (a.table_name=feature_table_list->table_name[cnt].tname)
      AND a.schema_dt_tm=cnvtdatetime(maxdate->var_dt_tm)
      AND a.environment=env
     DETAIL
      IF (a.table_env_status="2")
       feature_table_list->table_name[cnt].fill_status = 1, error_flg = 1, err_str = concat("Table ",
        a.table_name," has a FAIL fill status.")
      ELSE
       feature_table_list->table_name[cnt].fill_status = 0
      ENDIF
      feature_table_list->table_name[cnt].feature_number = a.feature_number, feature_table_list->
      table_name[cnt].schema_dt_tm = a.schema_dt_tm
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (error_flg=1)
  SELECT INTO value(filename5)
   *
   FROM dual
   DETAIL
    "Error = ", err_str, row + 1,
    row + 1
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
 ENDIF
 SET pardate = cnvtdatetime(curdate,curtime3)
 SET cntw = 0
 SET feature_table_list->param_error = 0
 SET feature_table_list->nbr_errors = 0
 FOR (cntw = 1 TO feature_table_list->table_count)
   IF ((feature_table_list->table_name[cntw].fill_status != 1)
    AND (feature_table_list->table_name[cntw].backout_ind != 1))
    SET p = format(feature_table_list->table_name[cntw].schema_dt_tm,"MM/DD/YY HH:MM;;D")
    CALL echo(p)
    CALL echo(concat("table_nameB",feature_table_list->table_name[cntw].tname))
    EXECUTE dm_schema_comp "A", trim(feature_table_list->table_name[cntw].tname), cnvtdatetime(
     feature_table_list->table_name[cntw].schema_dt_tm)
    CALL echo(cnvtstring(feature_table_list->nbr_errors))
    IF ((feature_table_list->param_error=1))
     SET feature_table_list->param_error = 0
     SET feature_table_list->nbr_errors = 1
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
     CALL update_dm_feature_tbls3(re_dummy)
    ENDIF
    IF ((feature_table_list->nbr_errors > 0))
     SET feature_table_list->table_name[cntw].error_flag = feature_table_list->nbr_errors
     SET feature_table_list->nbr_errors = 0
     CALL update_dm_feature_tbls3(re_dummy)
    ELSE
     CALL update_dm_feature_tbls2(re_dummy)
    ENDIF
   ENDIF
 ENDFOR
 EXECUTE dm_schema_refresh parfile, pardate, 1
 FOR (cnt = 1 TO feature_table_list->table_count)
   CALL echo(concat("table_name: ",feature_table_list->table_name[cnt].tname))
   SET p = format(feature_table_list->table_name[cnt].schema_dt_tm,"MM/DD/YY HH:MM;;D")
   CALL echo(p)
 ENDFOR
 CALL compile(outfile1,logfile1)
 CALL compile(outfile2,logfile2)
 SUBROUTINE update_dm_feature_tbls3(dummy)
  FOR (cntf = 1 TO feature_list->feature_count)
    UPDATE  FROM dm_feature_tables_env
     SET table_env_status = "3"
     WHERE environment=env
      AND (table_name=feature_table_list->table_name[cntw].tname)
      AND (feature_number=feature_list->feature_number[cntf].feature_nbr)
      AND schema_dt_tm <= cnvtdatetime(feature_table_list->table_name[cntw].schema_dt_tm)
    ;end update
  ENDFOR
  COMMIT
 END ;Subroutine
 SUBROUTINE update_dm_feature_tbls2(dummy)
  FOR (cntf = 1 TO feature_list->feature_count)
    UPDATE  FROM dm_feature_tables_env
     SET table_env_status = "1"
     WHERE environment=env
      AND (table_name=feature_table_list->table_name[cntw].tname)
      AND (feature_number=feature_list->feature_number[cntf].feature_nbr)
      AND schema_dt_tm <= cnvtdatetime(feature_table_list->table_name[cntw].schema_dt_tm)
    ;end update
  ENDFOR
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
