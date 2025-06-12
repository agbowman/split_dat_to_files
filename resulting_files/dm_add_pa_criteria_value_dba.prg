CREATE PROGRAM dm_add_pa_criteria_value:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 ccl_error_msg = c132
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET pass_info_error = 14
 SET ccl_error = 15
 SET criteria_id_error = 16
 SET failed = false
 SET emsg = fillstring(132," ")
 SET ecode = 0
 SET init_updt_cnt = 0
 SET nbr_of_cv = 0
 SET table_name = fillstring(30," ")
 SET table_name = "PA_CRITERIA"
 SELECT INTO "nl:"
  p.criteria_id
  FROM pa_criteria p
  WHERE (p.criteria_id=request->criteria_id)
 ;end select
 IF (curqual=0)
  SET failed = criteria_id_error
  SET reply->status_data.subeventstatus[1].operationname = "CRITERIA_ID_ERROR"
  GO TO exit_script
 ENDIF
 SET table_name = "PA_CRITERIA_VALUE"
 SET nbr_of_cv = size(request->crit_value,5)
 FOR (cv_cnt = 1 TO nbr_of_cv)
   IF ((request->criteria_id != 0)
    AND trim(request->crit_value[cv_cnt].criteria_field) != "")
    INSERT  FROM pa_criteria_value
     SET criteria_id = request->criteria_id, criteria_field = trim(cnvtupper(request->crit_value[
        cv_cnt].criteria_field)), value =
      IF ((request->crit_value[cv_cnt].value_null_ind=1)) null
      ELSE trim(cnvtupper(request->crit_value[cv_cnt].value))
      ENDIF
      ,
      updt_cnt = init_updt_cnt, updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = reqinfo->
      updt_id,
      updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = insert_error
     SET reply->status_data.subeventstatus[1].operationname = "INSERT_ERROR"
     GO TO exit_script
    ENDIF
   ELSE
    SET failed = pass_info_error
    SET reply->status_data.subeventstatus[1].operationname = "PASS_INFO_ERROR"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
  SET reply->status_data.subeventstatus[1].operationname = "CCL_ERROR"
  SET reply->ccl_error_msg = emsg
 ENDIF
 IF (failed != false)
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ENDIF
END GO
