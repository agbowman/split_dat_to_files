CREATE PROGRAM dcp_updt_syn_views_at_oc_level:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET errmsg = fillstring(132,"")
 FOR (cnt = 1 TO request->catalogcodecount)
  IF (trim(request->health_plan_view) > "")
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.health_plan_view = trim(request->health_plan_view), ocs.updt_id = reqinfo->updt_id, ocs
     .updt_task = reqinfo->updt_task,
     ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (ocs.updt_cnt+ 1)
    WHERE (ocs.catalog_cd=request->catalog_code_list[cnt].catalog_cd)
     AND ocs.active_ind=1
    WITH nocounter
   ;end update
  ENDIF
  IF (trim(request->health_plan_view)="")
   SET failed = "T"
   SET reply->status_data.targetobjectname = "ScriptMessage"
   SET reply->status_data.targetobjectvalue = "No Views have been received"
   GO TO exit_script
  ENDIF
 ENDFOR
#exit_script
 SET errorcode = error(errmsg,1)
 IF (errorcode != 0)
  SET failed = "T"
  SET reply->status_data.targetobjectname = "ErrorMessage"
  SET reply->status_data.targetobjectvalue = errmsg
 ENDIF
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.operationname = "Update"
  SET reply->status_data.status = "F"
  SET reply->status_data.operationstatus = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
