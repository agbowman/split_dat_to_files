CREATE PROGRAM ct_upt_rule:dba
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
    1 ct_rule_qual = i2
    1 ct_rule[10]
      2 ct_rule_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  CALL echo(build("EXECUTING CT_UPT_RULE....."))
  SET reply->ct_rule_qual = request->ct_rule_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "CT_RULE"
 CALL upt_ct_rule(action_begin,action_end)
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
 SUBROUTINE upt_ct_rule(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET count1 = 0
     SET active_status_code = 0
     SELECT INTO "nl:"
      c.*
      FROM ct_rule c
      WHERE (c.ct_rule_id=request->ct_rule[x].ct_rule_id)
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1
       IF ((request->ct_rule[x].active_status_cd > 0))
        active_status_code = c.active_status_cd
       ENDIF
      WITH forupdate(c)
     ;end select
     IF (curqual=0)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM ct_rule c
      SET c.description = evaluate(request->ct_rule[x].description," ",c.description,'""',null,
        request->ct_rule[x].description), c.action_cd = evaluate(request->ct_rule[x].action_cd,0.0,c
        .action_cd,- (1.0),0.0,
        request->ct_rule[x].action_cd), c.duration_cd = evaluate(request->ct_rule[x].duration_cd,0.0,
        c.duration_cd,- (1.0),0.0,
        request->ct_rule[x].duration_cd),
       c.vocab_type_cd = evaluate(request->ct_rule[x].vocab_type_cd,0.0,c.vocab_type_cd,- (1.0),0.0,
        request->ct_rule[x].vocab_type_cd), c.beg_effective_dt_tm = evaluate(request->ct_rule[x].
        beg_effective_dt_tm,0.0,c.beg_effective_dt_tm,blank_date,null,
        cnvtdatetime(request->ct_rule[x].beg_effective_dt_tm)), c.end_effective_dt_tm = evaluate(
        request->ct_rule[x].end_effective_dt_tm,0.0,c.end_effective_dt_tm,blank_date,null,
        cnvtdatetime(request->ct_rule[x].end_effective_dt_tm)),
       c.active_ind = nullcheck(c.active_ind,request->ct_rule[x].active_ind,
        IF ((request->ct_rule[x].active_ind=false)) 0
        ELSE 1
        ENDIF
        ), c.active_status_cd = nullcheck(c.active_status_cd,request->ct_rule[x].active_status_cd,
        IF ((request->ct_rule[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), c.active_status_prsnl_id = nullcheck(c.active_status_prsnl_id,reqinfo->updt_id,
        IF ((request->ct_rule[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ),
       c.active_status_dt_tm = nullcheck(c.active_status_dt_tm,cnvtdatetime(sysdate),
        IF ((request->ct_rule[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(sysdate),
       c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
       updt_task
      WHERE (c.ct_rule_id=request->ct_rule[x].ct_rule_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->ct_rule[x].ct_rule_id = request->ct_rule[x].ct_rule_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
