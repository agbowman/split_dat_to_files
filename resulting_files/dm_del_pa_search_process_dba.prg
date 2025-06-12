CREATE PROGRAM dm_del_pa_search_process:dba
 PAINT
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
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
 SET failed = false
 SET inactive_active_ind = 0
 SET emsg = fillstring(132," ")
 SET ecode = 0
 SET inactive_cd = 0
 SET meaning = "INACTIVE"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning=meaning
   AND c.code_set=48
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   inactive_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = select_error
  GO TO exit_script
 ENDIF
 IF ((request->search_process_id != 0))
  UPDATE  FROM pa_search_process
   SET active_ind = inactive_active_ind, active_status_cd = inactive_cd, updt_cnt = (updt_cnt+ 1),
    updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = reqinfo->updt_id, updt_task = reqinfo->
    updt_task,
    updt_applctx = reqinfo->updt_applctx
   WHERE (search_process_id=request->search_process_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = update_error
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE_ERROR"
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
 ENDIF
 IF (failed != false)
  ROLLBACK
  CALL clear(1,1)
  SET text1 = fillstring(75," ")
  SET text2 = fillstring(75," ")
  SET text1 = "Script failed."
  SET text2 = concat("Error type = ",reply->status_data.subeventstatus[1].operationname)
  CALL text(5,5,text1)
  CALL text(7,5,text2)
 ELSE
  COMMIT
 ENDIF
END GO
