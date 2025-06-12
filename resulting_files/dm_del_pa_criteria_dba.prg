CREATE PROGRAM dm_del_pa_criteria:dba
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
 SET child_rec_error = 16
 SET failed = false
 SET emsg = fillstring(132," ")
 SET ecode = 0
 SET crit_id = 0
 SET table_name = fillstring(30," ")
 IF ((request->search_process_id != 0))
  SET table_name = "PA_CRITERIA"
  SELECT INTO "nl:"
   pac.criteria_id
   FROM pa_criteria pac
   WHERE (pac.search_process_id=request->criteria[1].search_process_id)
    AND pac.key1=trim(cnvtupper(request->key1[1].key1))
    AND pac.key2=trim(cnvtupper(request->key2[1].key2))
    AND pac.key3=trim(cnvtupper(request->key3[1].key3))
    AND pac.key4=trim(cnvtupper(request->key4[1].key4))
   DETAIL
    crit_id = pac.criteria_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed = none_found
   SET reply->status_data.subeventstatus[1].operationname = "NONE_FOUND"
   GO TO exit_script
  ENDIF
  SET table_name = "CRITERIA_VALUE"
  SELECT INTO "nl:"
   pacv.criteria_field
   FROM pa_criteria_value pacv
   WHERE criteria_id=crit_id
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SET failed = child_rec_error
   SET reply->status_data.subeventstatus[1].operationname = "CHILD_REC_ERROR"
   GO TO exit_script
  ENDIF
  SET table_name = "PA_CRITERIA"
  DELETE  FROM pa_criteria
   WHERE criteria_id=crit_id
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET failed = delete_error
   SET reply->status_data.subeventstatus[1].operationname = "DELETE_ERROR"
   GO TO exit_script
  ENDIF
 ELSE
  SET failed = pass_info_error
  SET reply->status_data.subeventstatus[1].operationname = "PASS_INFO_ERROR"
  GO TO exit_script
 ENDIF
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
