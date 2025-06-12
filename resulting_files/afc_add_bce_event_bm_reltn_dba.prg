CREATE PROGRAM afc_add_bce_event_bm_reltn:dba
 SET action_begin = 1
 SET action_end = request->bill_mod_reltn_qual
 CALL add_bce_event_bm_reltn(action_begin,action_end)
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
 CALL echorecord(request)
 CALL echo("here 1")
 SUBROUTINE add_bce_event_bm_reltn(add_begin,add_end)
   FOR (count1 = add_begin TO add_end)
     SET new_nbr = 0
     SELECT INTO "nl:"
      y = seq(bce_event_log_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     CALL echo(build("new_nbr is ",new_nbr))
     CALL echorecord(request)
     INSERT  FROM bce_event_bill_mod_reltn b
      SET b.bce_event_bill_mod_reltn_id = new_nbr, b.bce_event_log_id =
       IF ((request->bill_mod_reltn[count1].bce_event_log_id <= 0)) 0
       ELSE request->bill_mod_reltn[count1].bce_event_log_id
       ENDIF
       , b.bill_item_mod_id =
       IF ((request->bill_mod_reltn[count1].bill_mod_id <= 0)) 0
       ELSE request->bill_mod_reltn[count1].bill_mod_id
       ENDIF
       ,
       b.prompt_value =
       IF ((request->bill_mod_reltn[count1].prompt_value='""')) null
       ELSE request->bill_mod_reltn[count1].prompt_value
       ENDIF
       , b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
       updt_task
      WITH nocounter
     ;end insert
   ENDFOR
 END ;Subroutine
#end_program
END GO
