CREATE PROGRAM dm_del_prg_arch_req:dba
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
 SET no_req_error = 16
 SET failed = false
 SET emsg = fillstring(132," ")
 SET ecode = 0
 SET table_name = fillstring(30," ")
 SET table_name = "PA_REQUEST"
 IF (trim(request->purge_archive_flag) != ""
  AND trim(request->key_col_name) != ""
  AND trim(request->key_col_value) != "")
  SET meaning = fillstring(12," ")
  IF (cnvtupper(request->purge_archive_flag)="P")
   SET meaning = "PURGE_PEND"
  ELSEIF (cnvtupper(request->purge_archive_flag)="A")
   SET meaning = "ARCH_PEND"
  ENDIF
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv,
    pa_request par
   WHERE par.purge_archive_cd=cv.code_value
    AND par.key_col_name=trim(cnvtupper(request->key_col_name))
    AND par.key_col_value=trim(cnvtupper(request->key_col_value))
    AND cv.cdf_meaning=meaning
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed = delete_error
   SET reply->status_data.subeventstatus[1].operationname = "DELETE_ERROR"
   GO TO exit_script
  ENDIF
  SET del_cd = 0
  SET table_name = "CODE_VALUE"
  SELECT
   IF (cnvtupper(request->purge_archive_flag)="P")
    WHERE cv.code_set=14259
     AND cv.active_ind=true
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND cv.cdf_meaning="PURGE_CANCEL"
   ELSEIF (cnvtupper(request->purge_archive_flag)="A")
    WHERE cv.code_set=14259
     AND cv.active_ind=true
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND cv.cdf_meaning="ARCH_CANCEL"
   ELSE
   ENDIF
   INTO "nl:"
   cv.code_value
   FROM code_value cv
   DETAIL
    del_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed = select_error
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   GO TO exit_script
  ENDIF
  SET table_name = "PA_REQUEST"
  UPDATE  FROM pa_request par
   SET par.purge_archive_cd = del_cd, par.updt_cnt = (updt_cnt+ 1), par.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    par.updt_id = reqinfo->updt_id, par.updt_task = reqinfo->updt_task, par.updt_applctx = reqinfo->
    updt_applctx
   WHERE par.key_col_name=trim(cnvtupper(request->key_col_name))
    AND par.key_col_value=trim(cnvtupper(request->key_col_value))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = no_req_error
   SET reply->status_data.subeventstatus[1].operationname = "NO_REQ_ERROR"
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
