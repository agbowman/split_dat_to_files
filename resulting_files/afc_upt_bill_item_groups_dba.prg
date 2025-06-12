CREATE PROGRAM afc_upt_bill_item_groups:dba
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
    1 bill_item_groups_qual = i2
    1 bill_item_groups[10]
      2 bill_item_groups_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->bill_item_groups_qual
  SET reply->bill_item_groups_qual = request->bill_item_groups_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "BILL_ITEM_GROUPS"
 CALL upt_bill_item_groups(action_begin,action_end)
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
 SUBROUTINE upt_bill_item_groups(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET count1 = 0
     SET active_status_code = 0
     SELECT INTO "nl:"
      b.*
      FROM bill_item_groups b
      WHERE (b.bill_item_groups_id=request->bill_item_groups[x].bill_item_groups_id)
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1
       IF ((request->bill_item_groups[x].active_status_cd > 0))
        active_status_code = b.active_status_cd
       ENDIF
      WITH forupdate(b)
     ;end select
     IF (curqual=0)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM bill_item_groups b
      SET b.bill_item_id = evaluate(request->bill_item_groups[x].bill_item_id,0.0,b.bill_item_id,- (
        1.0),0.0,
        request->bill_item_groups[x].bill_item_id), b.ext_description = evaluate(request->
        bill_item_groups[x].ext_description," ",b.ext_description,'""',null,
        request->bill_item_groups[x].ext_description), b.group_name = evaluate(request->
        bill_item_groups[x].group_name," ",b.group_name,'""',null,
        request->bill_item_groups[x].group_name),
       b.beg_effective_dt_tm = evaluate(request->bill_item_groups[x].beg_effective_dt_tm,0.0,b
        .beg_effective_dt_tm,blank_date,null,
        cnvtdatetime(request->bill_item_groups[x].beg_effective_dt_tm)), b.end_effective_dt_tm =
       evaluate(request->bill_item_groups[x].end_effective_dt_tm,0.0,b.end_effective_dt_tm,blank_date,
        null,
        cnvtdatetime(request->bill_item_groups[x].end_effective_dt_tm)), b.active_ind = nullcheck(b
        .active_ind,request->bill_item_groups[x].active_ind,
        IF ((request->bill_item_groups[x].active_ind=false)) 0
        ELSE 1
        ENDIF
        ),
       b.active_status_cd = nullcheck(b.active_status_cd,request->bill_item_groups[x].
        active_status_cd,
        IF ((request->bill_item_groups[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), b.active_status_prsnl_id = nullcheck(b.active_status_prsnl_id,reqinfo->updt_id,
        IF ((request->bill_item_groups[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), b.active_status_dt_tm = nullcheck(b.active_status_dt_tm,cnvtdatetime(sysdate),
        IF ((request->bill_item_groups[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ),
       b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->
       updt_id,
       b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task
      WHERE (b.bill_item_groups_id=request->bill_item_groups[x].bill_item_groups_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->bill_item_groups[x].bill_item_groups_id = request->bill_item_groups[x].
      bill_item_groups_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
