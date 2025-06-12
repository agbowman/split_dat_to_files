CREATE PROGRAM cps_add_org_ntwk_prvdr:dba
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
    1 org_ntwk_prvdr_qual = i2
    1 org_ntwk_prvdr[*]
      2 org_ntwk_prvdr_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->org_ntwk_prvdr_qual
  SET reply->org_ntwk_prvdr_qual = request->org_ntwk_prvdr_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "ORG_NTWK_PRVDR"
 CALL add_org_ntwk_prvdr(action_begin,action_end)
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
 SUBROUTINE add_org_ntwk_prvdr(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET active_code = 0.0
     IF ((request->org_ntwk_prvdr[x].active_status_cd=0))
      SELECT INTO "nl:"
       FROM code_value c
       WHERE c.code_set=48
        AND c.cdf_meaning="ACTIVE"
       DETAIL
        active_code = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     SET new_nbr = 0
     SELECT INTO "nl:"
      y = seq(health_plan_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ELSE
      SET request->org_ntwk_prvdr[x].org_ntwk_prvdr_id = new_nbr
     ENDIF
     INSERT  FROM org_ntwk_prvdr o
      SET o.org_ntwk_prvdr_id = new_nbr, o.network_id =
       IF ((request->org_ntwk_prvdr[x].network_id <= 0)) 0
       ELSE request->org_ntwk_prvdr[x].network_id
       ENDIF
       , o.organization_id =
       IF ((request->org_ntwk_prvdr[x].organization_id <= 0)) 0
       ELSE request->org_ntwk_prvdr[x].organization_id
       ENDIF
       ,
       o.specialty_cd =
       IF ((request->org_ntwk_prvdr[x].specialty_cd <= 0)) 0
       ELSE request->org_ntwk_prvdr[x].specialty_cd
       ENDIF
       , o.beg_effective_dt_tm =
       IF ((request->org_ntwk_prvdr[x].beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
       ELSE cnvtdatetime(request->org_ntwk_prvdr[x].beg_effective_dt_tm)
       ENDIF
       , o.end_effective_dt_tm =
       IF ((request->org_ntwk_prvdr[x].end_effective_dt_tm <= 0)) cnvtdatetime(
         "31-DEC-2100 00:00:00.00")
       ELSE cnvtdatetime(request->org_ntwk_prvdr[x].end_effective_dt_tm)
       ENDIF
       ,
       o.active_ind =
       IF ((request->org_ntwk_prvdr[x].active_ind_ind=false)) true
       ELSE request->org_ntwk_prvdr[x].active_ind
       ENDIF
       , o.active_status_cd =
       IF ((request->org_ntwk_prvdr[x].active_status_cd=0)) active_code
       ELSE request->org_ntwk_prvdr[x].active_status_cd
       ENDIF
       , o.active_status_prsnl_id = reqinfo->updt_id,
       o.active_status_dt_tm = cnvtdatetime(sysdate), o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(
        sysdate),
       o.updt_id = reqinfo->updt_id, o.updt_applctx = reqinfo->updt_applctx, o.updt_task = reqinfo->
       updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->org_ntwk_prvdr[x].org_ntwk_prvdr_id = request->org_ntwk_prvdr[x].org_ntwk_prvdr_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
