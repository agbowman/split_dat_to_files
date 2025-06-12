CREATE PROGRAM afc_upt_price_sched_interval:dba
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
    1 item_interval_qual = i2
    1 item_interval[10]
      2 item_interval_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->item_interval_qual
  SET reply->item_interval_qual = request->item_interval_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "ITEM_INTERVAL_TABLE"
 CALL upt_item_interval_table(action_begin,action_end)
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
 SUBROUTINE upt_item_interval_table(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET count1 = 0
     SET active_status_code = 0
     UPDATE  FROM item_interval_table i
      SET i.interval_id = evaluate(request->item_interval[x].interval_id,0.0,i.interval_id,- (1.0),
        0.0,
        request->item_interval[x].interval_id), i.parent_entity_id = evaluate(request->item_interval[
        x].parent_entity_id,0.0,i.parent_entity_id,- (1.0),0.0,
        request->item_interval[x].parent_entity_id), i.parent_entity_name = request->item_interval[x]
       .parent_entity_name,
       i.interval_template_cd = evaluate(request->item_interval[x].interval_template_cd,0.0,i
        .interval_template_cd,- (1.0),0.0,
        request->item_interval[x].interval_template_cd), i.price = evaluate(request->item_interval[x]
        .price,0.0,i.price,- (1.0),0.0,
        request->item_interval[x].price), i.units = request->item_interval[x].units,
       i.updt_cnt = (i.updt_cnt+ 1), i.updt_dt_tm = cnvtdatetime(sysdate), i.updt_id = reqinfo->
       updt_id,
       i.updt_applctx = reqinfo->updt_applctx, i.updt_task = reqinfo->updt_task
      WHERE (i.item_interval_id=request->item_interval[x].item_interval_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->item_interval[x].item_interval_id = request->item_interval[x].item_interval_id
     ENDIF
     UPDATE  FROM price_sched_items p
      SET p.interval_template_cd = request->item_interval[x].interval_template_cd, p.updt_cnt = (p
       .updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
       p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
       updt_task
      WHERE (p.price_sched_items_id=request->item_interval[x].parent_entity_id)
      WITH nocounter
     ;end update
   ENDFOR
 END ;Subroutine
#end_program
END GO
