CREATE PROGRAM afc_upt_cost_adj_flex:dba
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
 CALL echo("upt_cost_adj_flex")
 CALL echorecord(request)
 IF (validate(reply->status_data.status,"Z")="Z")
  FREE SET reply
  RECORD reply(
    1 cost_adj_flex_qual = i2
    1 cost_adj_flex_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->cost_adj_flex_qual = request->cost_adj_flex_qual
 SET reply->status_data.status = "F"
 CALL echo("executing afc_upt_cost_adj_flex...")
 SET table_name = "COST_ADJ_FLEX"
 CALL upt_cost_adj_flex(action_begin,action_end)
 CALL echo(failed)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
  CALL echo("Commit is True")
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
 SUBROUTINE upt_cost_adj_flex(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     CALL echo("x:")
     CALL echo(x)
     IF ((request->cost_adj_flex[x].action_type="UPT"))
      UPDATE  FROM cost_adj_flex c
       SET c.cost_adj_sched_id = request->cost_adj_flex[x].cost_adj_sched_id, c.parent_entity_id =
        request->cost_adj_flex[x].parent_entity_id, c.parent_entity_name = request->cost_adj_flex[x].
        parent_entity_name,
        c.min_charge_amt = request->cost_adj_flex[x].min_charge_amt, c.updt_cnt = 0, c.updt_dt_tm =
        cnvtdatetime(sysdate),
        c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
        updt_task
       WHERE (c.cost_adj_flex_id=request->cost_adj_flex[x].cost_adj_flex_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET failed = insert_error
       RETURN
      ELSE
       SET reply->cost_adj_flex_id = request->cost_adj_flex[x].cost_adj_flex_id
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
