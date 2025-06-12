CREATE PROGRAM cps_upt_org_plan_reltn:dba
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
    1 org_plan_reltn_qual = i2
    1 org_plan_reltn[10]
      2 org_plan_reltn_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->org_plan_reltn_qual
  SET reply->org_plan_reltn_qual = request->org_plan_reltn_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "ORG_PLAN_RELTN"
 CALL upt_org_plan_reltn(action_begin,action_end)
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
 SUBROUTINE upt_org_plan_reltn(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET cur_updt_cnt[value(upt_end)] = 0
     SET count1 = 0
     SELECT INTO "nl:"
      o.*
      FROM org_plan_reltn o,
       (dummyt d  WITH seq = value(upt_end))
      PLAN (d)
       JOIN (o
       WHERE (o.org_plan_reltn_id=request->org_plan_reltn[d.seq].org_plan_reltn_id))
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1, cur_updt_cnt[count1] = o.updt_cnt
      WITH forupdate(o)
     ;end select
     IF (count1 != upt_end)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM org_plan_reltn o,
       (dummyt d  WITH seq = 1)
      SET o.seq = 1, o.health_plan_id = nullcheck(o.health_plan_id,request->org_plan_reltn[x].
        health_plan_id,
        IF ((request->org_plan_reltn[x].health_plan_id=0)) 0
        ELSE 1
        ENDIF
        ), o.org_plan_reltn_cd = nullcheck(o.org_plan_reltn_cd,request->org_plan_reltn[x].
        org_plan_reltn_cd,1),
       o.organization_id = nullcheck(o.organization_id,request->org_plan_reltn[x].organization_id,
        IF ((request->org_plan_reltn[x].organization_id=0)) 0
        ELSE 1
        ENDIF
        ), o.beg_effective_dt_tm = nullcheck(o.beg_effective_dt_tm,cnvtdatetime(request->
         org_plan_reltn[x].beg_effective_dt_tm),
        IF ((request->org_plan_reltn[x].beg_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), o.end_effective_dt_tm = nullcheck(o.end_effective_dt_tm,cnvtdatetime(request->
         org_plan_reltn[x].end_effective_dt_tm),
        IF ((request->org_plan_reltn[x].end_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ),
       o.contributor_system_cd = nullcheck(o.contributor_system_cd,request->org_plan_reltn[x].
        contributor_system_cd,
        IF ((request->org_plan_reltn[x].contributor_system_cd=0)) 0
        ELSE 1
        ENDIF
        ), o.group_nbr = nullcheck(o.group_nbr,request->org_plan_reltn[x].group_nbr,1), o.group_name
        = nullcheck(o.group_name,request->org_plan_reltn[x].group_name,1),
       o.policy_nbr = nullcheck(o.policy_nbr,request->org_plan_reltn[x].policy_nbr,1), o
       .contract_code = nullcheck(o.contract_code,request->org_plan_reltn[x].contract_code,1), o
       .active_ind = nullcheck(o.active_ind,request->org_plan_reltn[x].active_ind,
        IF ((request->org_plan_reltn[x].active_ind_ind=false)) 0
        ELSE 1
        ENDIF
        ),
       o.active_status_cd = nullcheck(o.active_status_cd,request->org_plan_reltn[x].active_status_cd,
        IF ((request->org_plan_reltn[x].active_status_cd=0)) 0
        ELSE 1
        ENDIF
        ), o.active_status_prsnl_id = nullcheck(o.active_status_prsnl_id,request->org_plan_reltn[x].
        active_status_prsnl_id,
        IF ((request->org_plan_reltn[x].active_status_prsnl_id=0)) 0
        ELSE 1
        ENDIF
        ), o.active_status_dt_tm = nullcheck(o.active_status_dt_tm,cnvtdatetime(request->
         org_plan_reltn[x].active_status_dt_tm),
        IF ((request->org_plan_reltn[x].active_status_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ),
       o.updt_cnt = (cur_updt_cnt[d.seq]+ 1), o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_id
        = reqinfo->updt_id,
       o.updt_applctx = reqinfo->updt_applctx, o.updt_task = reqinfo->updt_task
      PLAN (d)
       JOIN (o
       WHERE (o.org_plan_reltn_id=request->org_plan_reltn[x].org_plan_reltn_id))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->org_plan_reltn[x].org_plan_reltn_id = request->org_plan_reltn[x].org_plan_reltn_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
