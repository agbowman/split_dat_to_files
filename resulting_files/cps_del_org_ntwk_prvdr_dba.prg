CREATE PROGRAM cps_del_org_ntwk_prvdr:dba
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
    1 org_ntwk_prvdr_qual = i2
    1 org_ntwk_prvdr[10]
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
 CALL del_org_ntwk_prvdr(action_begin,action_end)
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
 SUBROUTINE del_org_ntwk_prvdr(del_begin,del_end)
   FOR (x = del_begin TO del_end)
     SET active_code = 0.0
     IF ((request->org_ntwk_prvdr[x].active_status_cd=0))
      SELECT INTO "nl:"
       FROM code_value c
       WHERE c.code_set=48
        AND c.cdf_meaning="INACTIVE"
       DETAIL
        active_code = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     UPDATE  FROM org_ntwk_prvdr o
      SET o.active_ind = false, o.active_status_cd = nullcheck(active_code,request->org_ntwk_prvdr[x]
        .active_status_cd,
        IF ((request->org_ntwk_prvdr[x].active_status_cd=0)) 0
        ELSE 1
        ENDIF
        ), o.active_status_prsnl_id = reqinfo->updt_id,
       o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_cnt = (o.updt_cnt+ 1), o
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       o.updt_id = reqinfo->updt_id, o.updt_applctx = reqinfo->updt_applctx, o.updt_task = reqinfo->
       updt_task
      WHERE (o.org_ntwk_prvdr_id=request->org_ntwk_prvdr[x].org_ntwk_prvdr_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->org_ntwk_prvdr[x].org_ntwk_prvdr_id = request->org_ntwk_prvdr[x].org_ntwk_prvdr_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
