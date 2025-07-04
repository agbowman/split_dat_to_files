CREATE PROGRAM cps_upt_health_plan:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 health_plan_qual = i2
    1 health_plan[10]
      2 health_plan_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->health_plan_qual
  SET reply->health_plan_qual = request->health_plan_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "HEALTH_PLAN"
 CALL upt_health_plan(action_begin,action_end)
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
 SUBROUTINE upt_health_plan(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET cur_updt_cnt[value(upt_end)] = 0
     SET count1 = 0
     SELECT INTO "nl:"
      h.*
      FROM health_plan h,
       (dummyt d  WITH seq = value(upt_end))
      PLAN (d)
       JOIN (h
       WHERE (h.health_plan_id=request->health_plan[d.seq].health_plan_id))
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 = (count1+ 1), cur_updt_cnt[count1] = h.updt_cnt
      WITH forupdate(h)
     ;end select
     IF (count1 != upt_end)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM health_plan h,
       (dummyt d  WITH seq = 1)
      SET h.seq = 1, h.beg_effective_dt_tm = nullcheck(h.beg_effective_dt_tm,cnvtdatetime(request->
         health_plan[x].beg_effective_dt_tm),
        IF ((request->health_plan[x].beg_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), h.end_effective_dt_tm = nullcheck(h.end_effective_dt_tm,cnvtdatetime(request->health_plan[
         x].end_effective_dt_tm),
        IF ((request->health_plan[x].end_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ),
       h.data_status_cd = nullcheck(h.data_status_cd,request->health_plan[x].data_status_cd,
        IF ((request->health_plan[x].data_status_cd=0)) 0
        ELSE 1
        ENDIF
        ), h.data_status_dt_tm = nullcheck(h.data_status_dt_tm,cnvtdatetime(request->health_plan[x].
         data_status_dt_tm),
        IF ((request->health_plan[x].data_status_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), h.data_status_prsnl_id = nullcheck(h.data_status_prsnl_id,request->health_plan[x].
        data_status_prsnl_id,
        IF ((request->health_plan[x].data_status_prsnl_id=0)) 0
        ELSE 1
        ENDIF
        ),
       h.contributor_system_cd = nullcheck(h.contributor_system_cd,request->health_plan[x].
        contributor_system_cd,
        IF ((request->health_plan[x].contributor_system_cd=0)) 0
        ELSE 1
        ENDIF
        ), h.plan_class_cd = nullcheck(h.plan_class_cd,request->health_plan[x].plan_class_cd,1), h
       .plan_type_cd = nullcheck(h.plan_type_cd,request->health_plan[x].plan_type_cd,1),
       h.plan_name = nullcheck(h.plan_name,request->health_plan[x].plan_name,1), h.plan_desc =
       nullcheck(h.plan_desc,request->health_plan[x].plan_desc,1), h.financial_class_cd = nullcheck(h
        .financial_class_cd,request->health_plan[x].financial_class_cd,1),
       h.ft_entity_name = nullcheck(h.ft_entity_name,request->health_plan[x].ft_entity_name,1), h
       .ft_entity_id = nullcheck(h.ft_entity_id,request->health_plan[x].ft_entity_id,1), h
       .baby_coverage_cd = nullcheck(h.baby_coverage_cd,request->health_plan[x].baby_coverage_cd,1),
       h.comb_baby_bill_cd = nullcheck(h.comb_baby_bill_cd,request->health_plan[x].comb_baby_bill_cd,
        1), h.plan_class_cd = nullcheck(h.plan_class_cd,request->health_plan[x].plan_class_cd,1), h
       .active_status_cd = nullcheck(h.active_status_cd,request->health_plan[x].active_status_cd,
        IF ((request->health_plan[x].active_status_cd=0)) 0
        ELSE 1
        ENDIF
        ),
       h.active_status_prsnl_id = nullcheck(h.active_status_prsnl_id,request->health_plan[x].
        active_status_prsnl_id,
        IF ((request->health_plan[x].active_status_prsnl_id=0)) 0
        ELSE 1
        ENDIF
        ), h.active_status_dt_tm = nullcheck(h.active_status_dt_tm,cnvtdatetime(request->health_plan[
         x].active_status_dt_tm),
        IF ((request->health_plan[x].active_status_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), h.updt_cnt = (cur_updt_cnt[d.seq]+ 1),
       h.updt_dt_tm = cnvtdatetime(curdate,curtime), h.updt_id = reqinfo->updt_id, h.updt_applctx =
       reqinfo->updt_applctx,
       h.updt_task = reqinfo->updt_task
      PLAN (d)
       JOIN (h
       WHERE (h.health_plan_id=request->health_plan[x].health_plan_id))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->health_plan[x].health_plan_id = request->health_plan[x].health_plan_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
