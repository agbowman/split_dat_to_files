CREATE PROGRAM afc_rpl_bill_item_modifier:dba
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
    1 bill_item_modifier_qual = i2
    1 bill_item_modifier[10]
      2 bill_item_mod_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->bill_item_modifier_qual
  SET reply->bill_item_modifier_qual = request->bill_item_modifier_qual
 ENDIF
 SET code_value = 0.0
 SET bctype_cd = 0.0
 SET code_set = 14002
 SET cdf_meaning = "CHARGE POINT"
 EXECUTE cpm_get_cd_for_cdf
 SET bctype_cd = code_value
 SET reply->status_data.status = "F"
 SET table_name = "BILL_ITEM_MODIFIER"
 CALL rpl_bill_item_modifier(action_begin,action_end)
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
 SUBROUTINE rpl_bill_item_modifier(rpl_begin,rpl_end)
   FOR (x = rpl_begin TO rpl_end)
     SET cur_updt_cnt = 0
     SELECT INTO "nl:"
      b.*
      FROM bill_item_modifier b
      WHERE (b.bill_item_mod_id=request->bill_item_modifier[x].bill_item_mod_id)
      DETAIL
       cur_updt_cnt = b.updt_cnt
      WITH forupdate(b)
     ;end select
     IF (curqual=0)
      SET failed = lock_error
      RETURN
     ENDIF
     SET cur_updt_cnt += 1
     UPDATE  FROM bill_item_modifier b
      SET b.key1_entity_name =
       IF ((request->bill_item_modifier[x].key1_id > 0)) "CODE_VALUE"
       ENDIF
       , b.key2_entity_name =
       IF ((request->bill_item_modifier[x].key2_id > 0)
        AND (request->bill_item_modifier[x].bill_item_type_cd=bctype_cd)) "CODE_VALUE"
       ENDIF
       , b.bill_item_id =
       IF ((request->bill_item_modifier[x].bill_item_id=0)) 0
       ELSE request->bill_item_modifier[x].bill_item_id
       ENDIF
       ,
       b.bill_item_type_cd =
       IF ((request->bill_item_modifier[x].bill_item_type_cd=0)) 0
       ELSE request->bill_item_modifier[x].bill_item_type_cd
       ENDIF
       , b.key1_id = request->bill_item_modifier[x].key1_id, b.key2_id = request->bill_item_modifier[
       x].key2_id,
       b.key3_id = request->bill_item_modifier[x].key3_id, b.key4_id = request->bill_item_modifier[x]
       .key4_id, b.key5_id = request->bill_item_modifier[x].key5_id,
       b.key6 = request->bill_item_modifier[x].key6, b.key7 = request->bill_item_modifier[x].key7, b
       .key8 = request->bill_item_modifier[x].key8,
       b.key9 = request->bill_item_modifier[x].key9, b.key10 = request->bill_item_modifier[x].key10,
       b.key11 = request->bill_item_modifier[x].key11,
       b.key12 = request->bill_item_modifier[x].key12, b.key13 = request->bill_item_modifier[x].key13,
       b.key14 = request->bill_item_modifier[x].key14,
       b.key15 = request->bill_item_modifier[x].key15, b.beg_effective_dt_tm =
       IF ((request->bill_item_modifier[x].beg_effective_dt_tm=0)) cnvtdatetime(sysdate)
       ELSE cnvtdatetime(request->bill_item_modifier[x].beg_effective_dt_tm)
       ENDIF
       , b.end_effective_dt_tm =
       IF ((request->bill_item_modifier[x].end_effective_dt_tm=0)) cnvtdatetime(
         "31-dec-2100 00:00:00")
       ELSE cnvtdatetime(request->bill_item_modifier[x].end_effective_dt_tm)
       ENDIF
       ,
       b.updt_cnt = cur_updt_cnt, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->
       updt_id,
       b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task
      WHERE (b.bill_item_mod_id=request->bill_item_modifier[x].bill_item_mod_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->bill_item_modifier[x].bill_item_mod_id = request->bill_item_modifier[x].
      bill_item_mod_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
