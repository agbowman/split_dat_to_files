CREATE PROGRAM cps_add_health_plan:dba
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
 CALL add_health_plan(action_begin,action_end)
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
 SUBROUTINE add_health_plan(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET active_code = 0.0
     IF ((request->health_plan[x].active_status_cd=0))
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
      SET request->health_plan[x].health_plan_id = new_nbr
     ENDIF
     INSERT  FROM health_plan h
      SET h.health_plan_id = new_nbr, h.data_status_cd =
       IF ((request->health_plan[x].data_status_cd=0)) 0
       ELSE request->health_plan[x].data_status_cd
       ENDIF
       , h.data_status_dt_tm =
       IF ((request->health_plan[x].data_status_dt_tm <= 0)) null
       ELSE cnvtdatetime(request->health_plan[x].data_status_dt_tm)
       ENDIF
       ,
       h.data_status_prsnl_id =
       IF ((request->health_plan[x].data_status_prsnl_id=0)) 0
       ELSE request->health_plan[x].data_status_prsnl_id
       ENDIF
       , h.contributor_system_cd =
       IF ((request->health_plan[x].contributor_system_cd=0)) 0
       ELSE request->health_plan[x].contributor_system_cd
       ENDIF
       , h.plan_class_cd = request->health_plan[x].plan_class_cd,
       h.plan_type_cd =
       IF ((request->health_plan[x].plan_type_cd=0)) 0
       ELSE request->health_plan[x].plan_type_cd
       ENDIF
       , h.plan_name = request->health_plan[x].plan_name, h.plan_desc = request->health_plan[x].
       plan_desc,
       h.financial_class_cd =
       IF ((request->health_plan[x].financial_class_cd=0)) 0
       ELSE request->health_plan[x].financial_class_cd
       ENDIF
       , h.ft_entity_name = request->health_plan[x].ft_entity_name, h.ft_entity_id =
       IF ((request->health_plan[x].ft_entity_id=0)) 0
       ELSE request->health_plan[x].ft_entity_id
       ENDIF
       ,
       h.baby_coverage_cd =
       IF ((request->health_plan[x].baby_coverage_cd=0)) 0
       ELSE request->health_plan[x].baby_coverage_cd
       ENDIF
       , h.comb_baby_bill_cd =
       IF ((request->health_plan[x].comb_baby_bill_cd=0)) 0
       ELSE request->health_plan[x].comb_baby_bill_cd
       ENDIF
       , h.plan_class_cd =
       IF ((request->health_plan[x].plan_class_cd=0)) 0
       ELSE request->health_plan[x].plan_class_cd
       ENDIF
       ,
       h.beg_effective_dt_tm =
       IF ((request->health_plan[x].beg_effective_dt_tm <= 0)) cnvtdatetime(curdate,curtime)
       ELSE cnvtdatetime(request->health_plan[x].beg_effective_dt_tm)
       ENDIF
       , h.end_effective_dt_tm =
       IF ((request->health_plan[x].end_effective_dt_tm <= 0)) cnvtdatetime("31-DEC-2100")
       ELSE cnvtdatetime(request->health_plan[x].end_effective_dt_tm)
       ENDIF
       , h.active_ind =
       IF ((request->health_plan[x].active_ind_ind=false)) true
       ELSE request->health_plan[x].active_ind
       ENDIF
       ,
       h.active_status_cd =
       IF ((request->health_plan[x].active_status_cd=0)) active_code
       ELSE request->health_plan[x].active_status_cd
       ENDIF
       , h.active_status_prsnl_id =
       IF ((request->health_plan[x].active_status_prsnl_id=0)) reqinfo->updt_id
       ELSE request->health_plan[x].active_status_prsnl_id
       ENDIF
       , h.active_status_dt_tm =
       IF ((request->health_plan[x].active_status_dt_tm <= 0)) cnvtdatetime(curdate,curtime)
       ELSE cnvtdatetime(request->health_plan[x].active_status_dt_tm)
       ENDIF
       ,
       h.updt_cnt = 0, h.updt_dt_tm = cnvtdatetime(curdate,curtime), h.updt_id = reqinfo->updt_id,
       h.updt_applctx = reqinfo->updt_applctx, h.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->health_plan[x].health_plan_id = request->health_plan[x].health_plan_id
      CALL echo("HEALTH_PLAN_ID:",0)
      CALL echo(reply->health_plan[x].health_plan_id)
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
