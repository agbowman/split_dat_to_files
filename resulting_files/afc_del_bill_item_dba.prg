CREATE PROGRAM afc_del_bill_item:dba
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE active_code = f8
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
 SET failedme = false
 SET table_name = fillstring(50," ")
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 bill_item_qual = i2
    1 bill_item[10]
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->bill_item_qual
  SET reply->bill_item_qual = request->bill_item_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "BILL_ITEM"
 CALL del_bill_item(action_begin,action_end)
 IF (failedme != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failedme=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failedme)
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
 SUBROUTINE del_bill_item(del_begin,del_end)
   FOR (x = del_begin TO del_end)
     IF ((request->bill_item[x].active_status_cd=0))
      SET code_set = 48
      SET code_value = 0.0
      SET cdf_meaning = "ACTIVE"
      EXECUTE cpm_get_cd_for_cdf
      SET active_code = code_value
      CALL echo(build("the inactive code is : ",active_code))
     ENDIF
     UPDATE  FROM bill_item b
      SET b.active_ind = false, b.active_status_cd = nullcheck(active_code,request->bill_item[x].
        active_status_cd,
        IF ((request->bill_item[x].active_status_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.active_status_prsnl_id = reqinfo->updt_id,
       b.active_status_dt_tm = cnvtdatetime(curdate,curtime), b.updt_cnt = (b.updt_cnt+ 1), b
       .updt_dt_tm = cnvtdatetime(curdate,curtime),
       b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
       updt_task
      WHERE (b.bill_item_id=request->bill_item[x].bill_item_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failedme = update_error
      RETURN
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
