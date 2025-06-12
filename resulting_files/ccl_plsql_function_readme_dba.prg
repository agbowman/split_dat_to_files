CREATE PROGRAM ccl_plsql_function_readme:dba
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
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure.  Starting ccl_plsql_function_readme script."
 DECLARE v_obj_cnt = i4 WITH protect, noconstant(0)
 DECLARE v_loop = i4 WITH protect, noconstant(0)
 DECLARE v_obj_name = vc WITH protect, noconstant("")
 DECLARE v_errmsg = vc WITH protect, noconstant("")
 DECLARE v_declare = vc WITH protect, noconstant("")
 DECLARE v_dynstr = vc WITH protect, noconstant("")
 DECLARE v_missing_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD ccl_obj
 RECORD ccl_obj(
   1 obj[*]
     2 object_name = vc
     2 object_type = vc
     2 exists_ind = i2
     2 syn_exists = i2
 )
 IF (findfile("cer_install:cclsqlutc.plb")=1)
  IF (cursys="AIX")
   SET stat = remove("cer_install:cclsqlutc.plb")
  ELSE
   SET stat = remove("cer_install:cclsqlutc.plb;*")
  ENDIF
  IF (stat=0)
   GO TO end_script
  ENDIF
 ENDIF
 IF (findfile("cer_install:cclsqlutc2.plb")=1)
  IF (cursys="AIX")
   SET stat = remove("cer_install:cclsqlutc2.plb")
  ELSE
   SET stat = remove("cer_install:cclsqlutc2.plb;*")
  ENDIF
  IF (stat=0)
   GO TO end_script
  ENDIF
 ENDIF
 IF (currdb="ORACLE")
  EXECUTE dm_readme_include_sql "cer_install:cclsqlutc.sql"
  IF ((dm_sql_reply->status="F"))
   SET dm_sql_reply->msg = concat(dm_sql_reply->msg," (cer_install:cclsqlutc.sql)")
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql "cer_install:cclsqlutc2.sql"
  IF ((dm_sql_reply->status="F"))
   SET dm_sql_reply->msg = concat(dm_sql_reply->msg," (cer_install:cclsqlutc2.sql)")
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql "cer_install:cclutilfun.sql"
  IF ((dm_sql_reply->status="F"))
   SET dm_sql_reply->msg = concat(dm_sql_reply->msg," (cer_install:cclutilfun.sql)")
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql "cer_install:cclobjtab.sql"
  IF ((dm_sql_reply->status="F"))
   SET dm_sql_reply->msg = concat(dm_sql_reply->msg," (cer_install:cclobjtab.sql)")
   GO TO exit_script
  ENDIF
  IF (curutc=1)
   CALL echo("compiling cer_install:cclsql_cnvtdatetimeutc.sql..")
   EXECUTE dm_readme_include_sql "cer_install:cclsql_cnvtdatetimeutc.sql"
   IF ((dm_sql_reply->status="F"))
    SET dm_sql_reply->msg = concat(dm_sql_reply->msg," (cer_install:cclsql_cnvtdatetimeutc.sql)")
    GO TO exit_script
   ENDIF
  ELSE
   CALL echo("compiling cer_install:cclsql_cnvtdatetimeutc_local.sql..")
   EXECUTE dm_readme_include_sql "cer_install:cclsql_cnvtdatetimeutc_local.sql"
   IF ((dm_sql_reply->status="F"))
    SET dm_sql_reply->msg = concat(dm_sql_reply->msg,
     " (cer_install:cclsql_cnvtdatetimeutc_local.sql)")
    GO TO exit_script
   ENDIF
  ENDIF
  SET v_obj_cnt = 0
 ELSE
  SET readme_data->message = "Readme failure. CURRDB != ORACLE."
  GO TO end_script
 ENDIF
 SET v_obj_name = "CCLSQL_UTC_CNVT"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_UTC_CNVT2"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_UTC_RULE"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_DATETIMEZONEBYINDEX"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_TZABBREV"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_CNVTUTC"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_CNVTDATETIMEUTC"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_DATETIMEDIFF"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_ENCOUNTERTZ"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_DATETIMETRUNC"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_IS_NUMERIC"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_IS_NUMERIC2"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_BITAND"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_BITOR"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_BITXOR"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_BITNOT"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_BITTEST"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_FUNVER"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_TO_NUMBER"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_COMPILEVER"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_GETOFFSET"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_BUILDOFFSETDATE"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLSQL_GETTIMECHANGE"
 SET v_obj_type = "FUNCTION"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJROW_C"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJROW_D"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJROW_N"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_C1"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_C2"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_C3"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_C4"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_C5"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_D1"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_D2"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_D3"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_D4"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_D5"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_N1"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_N2"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_N3"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_N4"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET v_obj_name = "CCLOBJTAB_N5"
 SET v_obj_type = "TYPE"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 FOR (v_loop = 1 TO size(ccl_obj->obj,5))
   SET v_dynstr = concat("execute dm_readme_include_sql_chk ^",ccl_obj->obj[v_loop].object_name,
    "^, ^",ccl_obj->obj[v_loop].object_type,"^ go")
   CALL parser(v_dynstr)
   IF ((dm_sql_reply->status="F"))
    SET dm_sql_reply->msg = concat("Failed on dm_readme_include_sql_chk for ",ccl_obj->obj[v_loop].
     object_name)
    GO TO exit_script
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM user_objects uo,
   (dummyt d  WITH seq = size(ccl_obj->obj,5))
  PLAN (d)
   JOIN (uo
   WHERE (uo.object_name=ccl_obj->obj[d.seq].object_name)
    AND (uo.object_type=ccl_obj->obj[d.seq].object_type))
  DETAIL
   ccl_obj->obj[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 IF (error(v_errmsg,1) != 0)
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg = concat("Failed to query user_objects: ",v_errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM all_synonyms s,
   (dummyt d  WITH seq = size(ccl_obj->obj,5))
  PLAN (d)
   JOIN (s
   WHERE s.owner="PUBLIC"
    AND (s.synonym_name=ccl_obj->obj[d.seq].object_name))
  DETAIL
   ccl_obj->obj[d.seq].syn_exists = 1
  WITH nocounter
 ;end select
 IF (error(v_errmsg,1) != 0)
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg = concat("Failed to load synonyms: ",v_errmsg)
  GO TO exit_script
 ENDIF
 FOR (v_loop = 1 TO size(ccl_obj->obj,5))
   IF ((ccl_obj->obj[v_loop].exists_ind=1))
    SET v_declare = concat("rdb asis(^ grant execute on ",ccl_obj->obj[v_loop].object_name,
     " to v500_read ^) go ")
    CALL parser(trim(v_declare))
    IF (error(v_errmsg,1) != 0)
     SET dm_sql_reply->status = "F"
     SET dm_sql_reply->msg = concat("Failed to grant privileges on '",ccl_obj->obj[v_loop].
      object_name,"': ",v_errmsg)
     GO TO exit_script
    ENDIF
    IF ((ccl_obj->obj[v_loop].syn_exists=0))
     SET v_declare = concat("rdb asis(^ create or replace public synonym ",ccl_obj->obj[v_loop].
      object_name," for v500.",ccl_obj->obj[v_loop].object_name," ^) go")
     CALL parser(v_declare)
     IF (error(v_errmsg,1) != 0)
      SET dm_sql_reply->status = "F"
      SET dm_sql_reply->msg = concat("Failed to create public synonym for '",ccl_obj->obj[v_loop].
       object_name,"': ",v_errmsg)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message =
 "All functions in cclsqlutc.sql, cclsqlutc2.sql, cclutilfun.sql, cclobjtab.sql compiled successfully."
 GO TO end_script
#exit_script
 SET readme_data->status = dm_sql_reply->status
 IF ((readme_data->status="F"))
  IF (textlen(trim(dm_sql_reply->msg)) > 0)
   SET readme_data->message = dm_sql_reply->msg
  ELSE
   SET readme_data->message = "Readme failure. No reason found in dm_sql_reply->msg."
  ENDIF
 ENDIF
#end_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
