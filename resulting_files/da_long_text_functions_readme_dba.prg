CREATE PROGRAM da_long_text_functions_readme:dba
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
 SET readme_data->message = "Readme failure.  Starting da_long_text_functions_readme script."
 DECLARE v_obj_cnt = i4 WITH protect, noconstant(0)
 DECLARE v_loop = i4 WITH protect, noconstant(0)
 DECLARE v_obj_name = vc WITH protect, noconstant("")
 DECLARE v_obj_type = vc WITH protect, noconstant("")
 DECLARE v_ret_type = vc WITH protect, noconstant("")
 DECLARE v_errmsg = vc WITH protect, noconstant("")
 DECLARE v_declare = vc WITH protect, noconstant("")
 DECLARE v_dynstr = vc WITH protect, noconstant("")
 FREE RECORD ccl_obj
 RECORD ccl_obj(
   1 obj[*]
     2 object_name = vc
     2 object_type = vc
     2 return_dtype = vc
     2 exists_ind = i2
     2 syn_exists = i2
     2 status = i4
 )
 EXECUTE dm_readme_include_sql "cer_install:omf_long_text_functions.sql"
 IF ((dm_sql_reply->status="F"))
  SET dm_sql_reply->msg = concat(dm_sql_reply->msg," (cer_install:cclsqlutc.sql)")
  GO TO exit_script
 ENDIF
 SET v_obj_name = "OMF_GET_LONG_TEXT"
 SET v_obj_type = "FUNCTION"
 SET v_ret_type = "C4000"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET ccl_obj->obj[v_obj_cnt].return_dtype = v_ret_type
 SET v_obj_name = "OMF_GET_LONG_TEXT_FULL"
 SET v_obj_type = "FUNCTION"
 SET v_ret_type = "C32000"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET ccl_obj->obj[v_obj_cnt].return_dtype = v_ret_type
 SET v_obj_name = "OMF_GET_LONG_TEXT_REF"
 SET v_obj_type = "FUNCTION"
 SET v_ret_type = "C4000"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET ccl_obj->obj[v_obj_cnt].return_dtype = v_ret_type
 SET v_obj_name = "OMF_GET_LONG_TEXT_REF_FULL"
 SET v_obj_type = "FUNCTION"
 SET v_ret_type = "C32000"
 SET v_obj_cnt += 1
 SET stat = alterlist(ccl_obj->obj,v_obj_cnt)
 SET ccl_obj->obj[v_obj_cnt].object_name = v_obj_name
 SET ccl_obj->obj[v_obj_cnt].object_type = v_obj_type
 SET ccl_obj->obj[v_obj_cnt].return_dtype = v_ret_type
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
  FROM omf_function f,
   (dummyt d  WITH seq = size(ccl_obj->obj,5))
  PLAN (d)
   JOIN (f
   WHERE (cnvtupper(f.function_name)=ccl_obj->obj[d.seq].object_name))
  DETAIL
   ccl_obj->obj[d.seq].status = 1
  WITH nocounter
 ;end select
 IF (error(v_errmsg,1) != 0)
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg = concat("Failed to query omf_function: ",v_errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM omf_function f,
   (dummyt d  WITH seq = value(size(ccl_obj->obj,5)))
  SET f.function_name = ccl_obj->obj[d.seq].object_name, f.return_dtype = ccl_obj->obj[d.seq].
   return_dtype, f.updt_dt_tm = cnvtdatetime(curdate,curtime),
   f.updt_id = reqinfo->updt_id, f.updt_task = reqinfo->updt_task, f.updt_applctx = reqinfo->
   updt_applctx,
   f.updt_cnt = 0
  PLAN (d
   WHERE (ccl_obj->obj[d.seq].status=0))
   JOIN (f)
  WITH nocounter
 ;end insert
 IF (error(v_errmsg,1) != 0)
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg = concat("Failed to insert new function(s) : ",v_errmsg)
  ROLLBACK
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
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "All functions in omf_long_text_functions.sql compiled successfully."
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
