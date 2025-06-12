CREATE PROGRAM afc_del_bill_item_internal:dba
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
 SUBROUTINE del_bill_item(del_begin,del_end)
   FOR (x = del_begin TO del_end)
     SET active_code = 0.0
     IF ((request->bill_item[x].active_status_cd=0))
      SELECT INTO "nl:"
       FROM code_value c
       WHERE c.code_set=48
        AND c.cdf_meaning="INACTIVE"
       DETAIL
        active_code = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     UPDATE  FROM price_sched_items psi
      SET psi.active_ind = false, psi.active_status_cd = nullcheck(active_code,request->bill_item[x].
        active_status_cd,
        IF ((request->bill_item[x].active_status_cd=0)) 0
        ELSE 1
        ENDIF
        ), psi.active_status_prsnl_id = reqinfo->updt_id,
       psi.active_status_dt_tm = cnvtdatetime(curdate,curtime), psi.updt_cnt = (psi.updt_cnt+ 1), psi
       .updt_dt_tm = cnvtdatetime(curdate,curtime),
       psi.updt_id = reqinfo->updt_id, psi.updt_applctx = reqinfo->updt_applctx, psi.updt_task =
       reqinfo->updt_task
      WHERE (psi.bill_item_id=request->bill_item[x].bill_item_id)
      WITH nocounter
     ;end update
     SET add_on_code = 0.0
     SELECT INTO "nl:"
      c.code_value
      FROM code_value c
      WHERE c.code_set=13019
       AND c.cdf_meaning="ADD ON"
      DETAIL
       add_on_code = c.code_value
      WITH nocounter
     ;end select
     CALL echo(build("add_on_code: ",add_on_code))
     CALL echo(build("bill_item_id: ",request->bill_item[x].bill_item_id))
     UPDATE  FROM bill_item_modifier bim
      SET bim.active_ind = false, bim.active_status_cd = nullcheck(active_code,request->bill_item[x].
        active_status_cd,
        IF ((request->bill_item[x].active_status_cd=0)) 0
        ELSE 1
        ENDIF
        ), bim.active_status_prsnl_id = reqinfo->updt_id,
       bim.active_status_dt_tm = cnvtdatetime(curdate,curtime), bim.updt_cnt = (bim.updt_cnt+ 1), bim
       .updt_dt_tm = cnvtdatetime(curdate,curtime),
       bim.updt_id = reqinfo->updt_id, bim.updt_applctx = reqinfo->updt_applctx, bim.updt_task =
       reqinfo->updt_task
      WHERE (((bim.bill_item_id=request->bill_item[x].bill_item_id)) OR (bim.bill_item_type_cd=
      add_on_code
       AND bim.key1=trim(cnvtstring(request->bill_item[x].bill_item_id,17,2),3)))
      WITH nocounter
     ;end update
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
      SET failed = update_error
      RETURN
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
