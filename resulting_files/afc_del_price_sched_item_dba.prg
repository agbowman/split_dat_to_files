CREATE PROGRAM afc_del_price_sched_item:dba
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE active_code = f8
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 price_sched_items_qual = i2
    1 price_sched_items[10]
      2 price_sched_id = f8
      2 price_sched_items_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->price_sched_items_qual
  SET reply->price_sched_items_qual = request->price_sched_items_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "PRICE_SCHED_ITEMS"
 CALL del_price_sched_items(action_begin,action_end)
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
 SUBROUTINE del_price_sched_items(del_begin,del_end)
   FOR (x = del_begin TO del_end)
     IF ((request->price_sched_items[x].active_status_cd=0))
      SET code_set = 48
      SET code_value = 0.0
      SET cdf_meaning = "ACTIVE"
      EXECUTE cpm_get_cd_for_cdf
      SET active_code = code_value
      CALL echo(build("the inactive code is : ",active_code))
     ENDIF
     UPDATE  FROM price_sched_items p
      SET p.active_ind = false, p.active_status_cd = nullcheck(active_code,request->
        price_sched_items[x].active_status_cd,
        IF ((request->price_sched_items[x].active_status_cd=0)) 0
        ELSE 1
        ENDIF
        ), p.active_status_prsnl_id = reqinfo->updt_id,
       p.active_status_dt_tm = cnvtdatetime(curdate,curtime), p.updt_cnt = (p.updt_cnt+ 1), p
       .updt_dt_tm = cnvtdatetime(curdate,curtime),
       p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
       updt_task,
       p.end_effective_dt_tm = cnvtdatetime(sysdate)
      WHERE (p.price_sched_id=request->price_sched_items[x].price_sched_id)
       AND (p.bill_item_id=request->price_sched_items[x].bill_item_id)
       AND (p.price_sched_items_id=request->price_sched_items[x].price_sched_items_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->price_sched_items[x].price_sched_id = request->price_sched_items[x].price_sched_id
      SET reply->price_sched_items[x].price_sched_items_id = request->price_sched_items[x].
      price_sched_items_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
