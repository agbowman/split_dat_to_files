CREATE PROGRAM dcp_upd_task_discrete_r:dba
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
 SET updatecnt = 0
 SET errmsg = fillstring(132," ")
 SET failed = "F"
 SET numbertochange = size(request->taskdiscreter,5)
 FOR (x = 1 TO numbertochange)
   SELECT INTO "NL:"
    FROM task_discrete_r tdr
    WHERE (tdr.reference_task_id=request->taskdiscreter[x].reference_task_id)
     AND (tdr.task_assay_cd=request->taskdiscreter[x].task_assay_cd)
    DETAIL
     updatecnt = (updatecnt+ 1)
    WITH nocounter, forupdate(tdr)
   ;end select
 ENDFOR
 IF (updatecnt != numbertochange)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO numbertochange)
  UPDATE  FROM task_discrete_r tdr
   SET tdr.required_ind = request->taskdiscreter[x].required_ind, tdr.sequence = request->
    taskdiscreter[x].sequence, tdr.updt_cnt = (tdr.updt_cnt+ 1),
    tdr.updt_dt_tm = cnvtdatetime(curdate,curtime3), tdr.updt_id = reqinfo->updt_id, tdr.updt_applctx
     = reqinfo->updt_applctx,
    tdr.updt_task = reqinfo->updt_task, tdr.document_ind = request->taskdiscreter[x].document_ind,
    tdr.acknowledge_ind = request->taskdiscreter[x].acknowledge_ind,
    tdr.view_only_ind = request->taskdiscreter[x].view_only_ind
   WHERE (tdr.reference_task_id=request->taskdiscreter[x].reference_task_id)
    AND (tdr.task_assay_cd=request->taskdiscreter[x].task_assay_cd)
   WITH nocounter
  ;end update
  IF (curqual != 1)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.operationname = "Update"
  SET reply->status_data.operationstatus = "F"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.targetobjectname = "ScriptMessage"
  SET reply->status_data.targetobjectvalue = "Exit -- Locked Records Not Equal to Updated Records"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
