CREATE PROGRAM dm_add_pa_criteria:dba
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
 SET proc_id_error = 16
 SET failed = false
 SET new_id = 0
 SET emsg = fillstring(132," ")
 SET ecode = 0
 SET process_active_ind = 0
 SET init_updt_cnt = 0
 SET table_name = fillstring(30," ")
 IF ((request->search_process_id != 0))
  SET table_name = "PA_SEARCH_PROCESS"
  SELECT INTO "nl:"
   p.search_process_id
   FROM pa_search_process p
   WHERE (p.search_process_id=request->search_process_id)
   DETAIL
    process_active_ind = p.active_ind
   WITH nocounter
  ;end select
  IF (((curqual=0) OR (process_active_ind=0)) )
   SET failed = proc_id_error
   SET reply->status_data.subeventstatus[1].operationname = "PROC_ID_ERROR"
   GO TO exit_script
  ENDIF
  SET table_name = "PA_CRITERIA"
  SELECT INTO "nl:"
   dm_x = seq(criteria_seq,nextval)
   FROM dual
   DETAIL
    new_id = cnvtreal(dm_x)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed = gen_nbr_error
   SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR_ERROR"
   GO TO exit_script
  ENDIF
  INSERT  FROM pa_criteria
   SET criteria_id = new_id, search_process_id = request->search_process_id, description = trim(
     cnvtupper(request->description)),
    key1 = trim(cnvtupper(request->key1)), key2 = trim(cnvtupper(request->key2)), key3 = trim(
     cnvtupper(request->key3)),
    key4 = trim(cnvtupper(request->key4)), updt_cnt = init_updt_cnt, updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    updt_id = reqinfo->updt_id, updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx
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
