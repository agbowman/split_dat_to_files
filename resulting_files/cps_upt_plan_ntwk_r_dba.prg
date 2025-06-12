CREATE PROGRAM cps_upt_plan_ntwk_r:dba
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
    1 plan_ntwk_r_qual = i2
    1 plan_ntwk_r[*]
      2 plan_ntwk_r_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET action_begin = 1
  SET action_end = request->plan_ntwk_r_qual
  SET reply->plan_ntwk_r_qual = request->plan_ntwk_r_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "PLAN_NTWK_R"
 CALL upt_plan_ntwk_r(action_begin,action_end)
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
 SUBROUTINE upt_plan_ntwk_r(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET count1 = 0
     SET active_status_code = 0
     SELECT INTO "nl:"
      p.*
      FROM plan_ntwk_r p
      WHERE (p.plan_ntwk_r_id=request->plan_ntwk_r[x].plan_ntwk_r_id)
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1
       IF ((request->plan_ntwk_r[x].active_status_cd > 0))
        active_status_code = p.active_status_cd
       ENDIF
      WITH forupdate(p)
     ;end select
     IF (curqual=0)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM plan_ntwk_r p
      SET p.health_plan_id = evaluate(request->plan_ntwk_r[x].health_plan_id,0.0,p.health_plan_id,- (
        1.0),0.0,
        request->plan_ntwk_r[x].health_plan_id), p.network_id = evaluate(request->plan_ntwk_r[x].
        network_id,0.0,p.network_id,- (1.0),0.0,
        request->plan_ntwk_r[x].network_id), p.beg_effective_dt_tm = evaluate(request->plan_ntwk_r[x]
        .beg_effective_dt_tm,0.0,p.beg_effective_dt_tm,blank_date,null,
        cnvtdatetime(request->plan_ntwk_r[x].beg_effective_dt_tm)),
       p.end_effective_dt_tm = evaluate(request->plan_ntwk_r[x].end_effective_dt_tm,0.0,p
        .end_effective_dt_tm,blank_date,null,
        cnvtdatetime(request->plan_ntwk_r[x].end_effective_dt_tm)), p.active_ind = nullcheck(p
        .active_ind,request->plan_ntwk_r[x].active_ind,
        IF ((request->plan_ntwk_r[x].active_ind_ind=false)) 0
        ELSE 1
        ENDIF
        ), p.active_status_cd = nullcheck(p.active_status_cd,request->plan_ntwk_r[x].active_status_cd,
        IF ((request->plan_ntwk_r[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ),
       p.active_status_prsnl_id = nullcheck(p.active_status_prsnl_id,reqinfo->updt_id,
        IF ((request->plan_ntwk_r[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), p.active_status_dt_tm = nullcheck(p.active_status_dt_tm,cnvtdatetime(sysdate),
        IF ((request->plan_ntwk_r[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), p.updt_cnt = (p.updt_cnt+ 1),
       p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->
       updt_applctx,
       p.updt_task = reqinfo->updt_task
      WHERE (p.plan_ntwk_r_id=request->plan_ntwk_r[x].plan_ntwk_r_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->plan_ntwk_r[x].plan_ntwk_r_id = request->plan_ntwk_r[x].plan_ntwk_r_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
