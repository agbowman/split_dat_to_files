CREATE PROGRAM cps_ens_org_plan_reltn:dba
 RECORD reply(
   1 org_plan_reltn_qual = i4
   1 org_plan_reltn[10] = i4
     2 org_plan_reltn_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET cps_ens_org_plan_reltn = 0
 SET istatus = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET table_name = "ORG_PLAN_RELTN"
 FOR (inx0 = 1 TO request->org_plan_reltn_qual)
   CASE (request->org_plan_reltn[inx0].action_type)
    OF "ADD":
     SET action_begin = inx0
     SET action_end = inx0
     EXECUTE cps_add_org_plan_reltn
     IF (failed != false)
      GO TO check_error
     ENDIF
    OF "UPT":
     SET action_begin = inx0
     SET action_end = inx0
     IF ((request->org_plan_reltn[inx0].org_plan_reltn_id=0))
      SET failed = update_error
      GO TO check_error
     ENDIF
     SELECT INTO "nl:"
      h.*
      FROM org_plan_reltn h
      WHERE (h.org_plan_reltn_id=request->org_plan_reltn[inx0].org_plan_reltn_id)
       AND h.active_ind=true
      DETAIL
       request->org_plan_reltn[inx0].org_plan_reltn_id = h.org_plan_reltn_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = update_error
      GO TO error_check
     ELSE
      EXECUTE cps_upt_org_plan_reltn
      IF (failed != false)
       GO TO check_error
      ENDIF
     ENDIF
    ELSE
     SET failed = true
     GO TO check_error
   ENDCASE
 ENDFOR
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
  CALL echo("NO ERROR")
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    CALL echo("INSERT ERROR!")
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    CALL echo("UPDATE ERROR!")
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
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
 ENDIF
#end_program
END GO
