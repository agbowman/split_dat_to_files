CREATE PROGRAM ct_add_rule:dba
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
  CALL echo(build("Executing CT_ADD_RULE..."))
  SET reply->ct_rule_qual = request->ct_rule_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "CT_RULE"
 CALL add_ct_rule(action_begin,action_end)
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
 SUBROUTINE add_ct_rule(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     DECLARE code_set = i4
     DECLARE cdf_meaning = c12
     DECLARE active_code = f8
     SET code_set = 48
     SET cdf_meaning = "ACTIVE"
     DECLARE activecnt = i4
     SET activecnt = 1
     IF ((request->ct_rule[x].active_status_cd=0))
      SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,activecnt,active_code)
     ENDIF
     SET new_nbr = 0.00
     SELECT INTO "nl:"
      y = seq(ct_rule_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ELSE
      SET request->ct_rule[x].ct_rule_id = new_nbr
     ENDIF
     INSERT  FROM ct_rule c
      SET c.ct_rule_id = new_nbr, c.description =
       IF ((request->ct_rule[x].description="")) null
       ELSE request->ct_rule[x].description
       ENDIF
       , c.action_cd =
       IF ((request->ct_rule[x].action_cd <= 0)) 0
       ELSE request->ct_rule[x].action_cd
       ENDIF
       ,
       c.duration_cd =
       IF ((request->ct_rule[x].duration_cd <= 0)) 0
       ELSE request->ct_rule[x].duration_cd
       ENDIF
       , c.vocab_type_cd =
       IF ((request->ct_rule[x].vocab_type_cd <= 0)) 0
       ELSE request->ct_rule[x].vocab_type_cd
       ENDIF
       , c.beg_effective_dt_tm =
       IF ((request->ct_rule[x].beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
       ELSE cnvtdatetime(request->ct_rule[x].beg_effective_dt_tm)
       ENDIF
       ,
       c.end_effective_dt_tm =
       IF ((request->ct_rule[x].end_effective_dt_tm <= 0)) cnvtdatetime("31-DEC-2100 00:00:00.00")
       ELSE cnvtdatetime(request->ct_rule[x].end_effective_dt_tm)
       ENDIF
       , c.active_ind =
       IF ((request->ct_rule[x].active_ind=false)) true
       ELSE request->ct_rule[x].active_ind
       ENDIF
       , c.active_status_cd =
       IF ((request->ct_rule[x].active_status_cd=0)) active_code
       ELSE request->ct_rule[x].active_status_cd
       ENDIF
       ,
       c.active_status_prsnl_id = reqinfo->updt_id, c.active_status_dt_tm = cnvtdatetime(sysdate), c
       .updt_cnt = 0,
       c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->
       updt_applctx,
       c.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->ct_rule[x].ct_rule_id = request->ct_rule[x].ct_rule_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
