CREATE PROGRAM afc_ens_bce_event_log:dba
 RECORD reply(
   1 bce_event_log_qual = i2
   1 bce_event_log[*]
     2 bce_event_log_id = f8
   1 new_batch_num = f8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
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
 SET failed = false
 SET table_name = fillstring(50," ")
 SET hafc_ens_bce_event_log = 0
 SET istatus = 0
 DECLARE default_mode_batch_number = f8
 SET serrmsg = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET table_name = "BCE_EVENT_LOG"
 IF ((request->bce_event_log_qual > 0))
  SET reply->bce_event_log_qual = request->bce_event_log_qual
  FOR (inx0 = 1 TO request->bce_event_log_qual)
    CASE (request->bce_event_log[inx0].action_type)
     OF "ADD":
      SET action_begin = inx0
      SET action_end = inx0
      EXECUTE afc_add_bce_event_log
      IF (failed != false)
       GO TO check_error
      ENDIF
     OF "UPT":
      SET action_begin = inx0
      SET action_end = inx0
      EXECUTE afc_upt_bce_event_log
      IF (failed != false)
       GO TO check_error
      ENDIF
     OF "DEL":
      SET action_begin = inx0
      SET action_end = inx0
      EXECUTE afc_del_bce_event_log
      IF (failed != false)
       GO TO check_error
      ENDIF
     ELSE
      SET failed = true
      GO TO check_error
    ENDCASE
  ENDFOR
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
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
 ENDIF
#end_program
END GO
