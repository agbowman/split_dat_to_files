CREATE PROGRAM afc_rpl_price_sched:dba
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
    1 price_sched_qual = i2
    1 price_sched[10]
      2 price_sched_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->price_sched_qual
  SET reply->price_sched_qual = request->price_sched_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "PRICE_SCHED"
 CALL rpl_price_sched(action_begin,action_end)
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
 SUBROUTINE rpl_price_sched(rpl_begin,rpl_end)
   FOR (x = rpl_begin TO rpl_end)
     SET cur_updt_cnt = 0
     SELECT INTO "nl:"
      p.*
      FROM price_sched p
      WHERE (p.price_sched_id=request->price_sched[x].price_sched_id)
      DETAIL
       cur_updt_cnt = p.updt_cnt
      WITH forupdate(p)
     ;end select
     IF (curqual=0)
      SET failed = lock_error
      RETURN
     ENDIF
     SET cur_updt_cnt += 1
     UPDATE  FROM price_sched p
      SET p.price_sched_desc = request->price_sched[x].price_sched_desc, p.warning_dt_tm =
       IF ((request->price_sched[x].warning_dt_tm=0)) null
       ELSE cnvtdatetime(request->price_sched[x].warning_dt_tm)
       ENDIF
       , p.warning_prsnl_id =
       IF ((request->price_sched[x].warning_prsnl_id=0)) 0
       ELSE request->price_sched[x].warning_prsnl_id
       ENDIF
       ,
       p.warning_type_cd =
       IF ((request->price_sched[x].warning_type_cd=0)) 0
       ELSE request->price_sched[x].warning_type_cd
       ENDIF
       , p.beg_effective_dt_tm =
       IF ((request->price_sched[x].beg_effective_dt_tm=0)) cnvtdatetime(sysdate)
       ELSE cnvtdatetime(request->price_sched[x].beg_effective_dt_tm)
       ENDIF
       , p.end_effective_dt_tm =
       IF ((request->price_sched[x].end_effective_dt_tm=0)) cnvtdatetime("31-dec-2100 00:00:00")
       ELSE cnvtdatetime(request->price_sched[x].end_effective_dt_tm)
       ENDIF
       ,
       p.updt_cnt = cur_updt_cnt, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id = reqinfo->
       updt_id,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task
      WHERE (p.price_sched_id=request->price_sched[x].price_sched_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->price_sched[x].price_sched_id = request->price_sched[x].price_sched_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
