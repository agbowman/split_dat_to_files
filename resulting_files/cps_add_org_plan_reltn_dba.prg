CREATE PROGRAM cps_add_org_plan_reltn:dba
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
 CALL add_org_plan_reltn(action_begin,action_end)
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
 SUBROUTINE add_org_plan_reltn(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET active_code = 0.0
     IF ((request->org_plan_reltn[x].active_status_cd=0))
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
      SET request->org_plan_reltn[x].org_plan_reltn_id = new_nbr
     ENDIF
     INSERT  FROM org_plan_reltn o
      SET o.org_plan_reltn_id = new_nbr, o.health_plan_id =
       IF ((request->org_plan_reltn[x].health_plan_id=0)) 0
       ELSE request->org_plan_reltn[x].health_plan_id
       ENDIF
       , o.org_plan_reltn_cd =
       IF ((request->org_plan_reltn[x].org_plan_reltn_cd=0)) 0
       ELSE request->org_plan_reltn[x].org_plan_reltn_cd
       ENDIF
       ,
       o.organization_id =
       IF ((request->org_plan_reltn[x].organization_id=0)) 0
       ELSE request->org_plan_reltn[x].organization_id
       ENDIF
       , o.contributor_system_cd =
       IF ((request->org_plan_reltn[x].contributor_system_cd=0)) 0
       ELSE request->org_plan_reltn[x].contributor_system_cd
       ENDIF
       , o.group_nbr = request->org_plan_reltn[x].group_nbr,
       o.group_name = request->org_plan_reltn[x].group_name, o.beg_effective_dt_tm =
       IF ((request->org_plan_reltn[x].beg_effective_dt_tm <= 0)) cnvtdatetime(curdate,curtime)
       ELSE cnvtdatetime(request->org_plan_reltn[x].beg_effective_dt_tm)
       ENDIF
       , o.end_effective_dt_tm =
       IF ((request->org_plan_reltn[x].end_effective_dt_tm <= 0)) cnvtdatetime("31-DEC-2100")
       ELSE cnvtdatetime(request->org_plan_reltn[x].end_effective_dt_tm)
       ENDIF
       ,
       o.active_ind =
       IF ((request->org_plan_reltn[x].active_ind_ind=false)) true
       ELSE request->org_plan_reltn[x].active_ind
       ENDIF
       , o.active_status_cd =
       IF ((request->org_plan_reltn[x].active_status_cd=0)) active_code
       ELSE request->org_plan_reltn[x].active_status_cd
       ENDIF
       , o.active_status_prsnl_id =
       IF ((request->org_plan_reltn[x].active_status_prsnl_id=0)) reqinfo->updt_id
       ELSE request->org_plan_reltn[x].active_status_prsnl_id
       ENDIF
       ,
       o.active_status_dt_tm =
       IF ((request->org_plan_reltn[x].active_status_dt_tm <= 0)) cnvtdatetime(curdate,curtime)
       ELSE cnvtdatetime(request->org_plan_reltn[x].active_status_dt_tm)
       ENDIF
       , o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime),
       o.updt_id = reqinfo->updt_id, o.updt_applctx = reqinfo->updt_applctx, o.updt_task = reqinfo->
       updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->org_plan_reltn[x].org_plan_reltn_id = request->org_plan_reltn[x].org_plan_reltn_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
