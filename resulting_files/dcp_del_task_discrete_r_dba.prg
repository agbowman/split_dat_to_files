CREATE PROGRAM dcp_del_task_discrete_r:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH protect, noconstant("")
 DECLARE numbertochange = i4 WITH protect, noconstant(size(request->taskdiscreter,5))
 DECLARE loopidx = i4 WITH protect, noconstant(0)
 DECLARE referencetaskid = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 IF (numbertochange=0)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET referencetaskid = request->taskdiscreter[1].reference_task_id
 FOR (x = 1 TO size(request->taskdiscreter,5))
  DELETE  FROM task_discrete_r tdr
   WHERE tdr.reference_task_id=referencetaskid
    AND (tdr.task_assay_cd=request->taskdiscreter[x].task_assay_cd)
    AND tdr.active_ind=1
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDFOR
 SELECT INTO "NL:"
  FROM order_task_xref otx
  WHERE otx.reference_task_id=referencetaskid
  WITH nocounter, forupdate(otx)
 ;end select
 SELECT INTO "nl:"
  FROM task_discrete_r tdr
  WHERE tdr.reference_task_id=referencetaskid
   AND tdr.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual=0)
  UPDATE  FROM order_task_xref otx
   SET otx.order_task_type_flag = 0, otx.updt_cnt = (otx.updt_cnt+ 1), otx.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    otx.updt_id = reqinfo->updt_id, otx.updt_applctx = reqinfo->updt_applctx, otx.updt_task = reqinfo
    ->updt_task
   WHERE otx.reference_task_id=referencetaskid
   WITH nocounter
  ;end update
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.operationname = "Delete"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "ScriptMessage"
  SET reply->status_data.targetobjectvalue = "Exit -- Delete Failed"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
