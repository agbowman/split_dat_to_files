CREATE PROGRAM afc_del_bce_event_log:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 bce_event_log_qual = i2
    1 bce_event_log[*]
      2 bce_event_log_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->bce_event_log_qual
  SET reply->bce_event_log_qual = request->bce_event_log_qual
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE active_code = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,active_code)
 SET table_name = "BCE_EVENT_LOG"
 CALL del_bce_event_log(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE del_bce_event_log(del_begin,del_end)
   FOR (x = del_begin TO del_end)
    UPDATE  FROM bce_event_log b
     SET b.active_ind = false, b.active_status_cd = active_code, b.active_status_prsnl_id = reqinfo->
      updt_id,
      b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_cnt = (b.updt_cnt+ 1), b
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
      updt_task
     WHERE (b.bce_event_log_id=request->bce_event_log[x].bce_event_log_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = update_error
     RETURN
    ELSE
     SET stat = alterlist(reply->bce_event_log,x)
     SET reply->bce_event_log[x].bce_event_log_id = request->bce_event_log[x].bce_event_log_id
    ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
