CREATE PROGRAM dcp_add_task_discrete_r:dba
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
 DECLARE rowcnt = i4 WITH protect, noconstant(0)
 DECLARE referencetaskid = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 IF (numbertochange=0)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET referencetaskid = request->taskdiscreter[1].reference_task_id
 FOR (x = 1 TO numbertochange)
   INSERT  FROM task_discrete_r tdr
    SET tdr.reference_task_id = referencetaskid, tdr.task_assay_cd = request->taskdiscreter[x].
     task_assay_cd, tdr.required_ind = request->taskdiscreter[x].required_ind,
     tdr.sequence = request->taskdiscreter[x].sequence, tdr.updt_cnt = 0, tdr.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     tdr.updt_id = reqinfo->updt_id, tdr.updt_applctx = reqinfo->updt_applctx, tdr.active_ind = 1,
     tdr.updt_task = reqinfo->updt_task, tdr.document_ind = request->taskdiscreter[x].document_ind,
     tdr.acknowledge_ind = request->taskdiscreter[x].acknowledge_ind,
     tdr.view_only_ind = request->taskdiscreter[x].view_only_ind
    WITH nocounter
   ;end insert
   CALL echo("Here it the QualCount it should be 1")
   CALL echo(curqual)
   IF (curqual != 1)
    SET failed = "T"
    GO TO exit_script
   ENDIF
 ENDFOR
 SELECT INTO "NL:"
  FROM order_task_xref otx
  WHERE otx.reference_task_id=referencetaskid
  HEAD REPORT
   rowcnt = 0
  DETAIL
   rowcnt = (rowcnt+ 1)
  WITH nocounter, forupdate(otx)
 ;end select
 IF (rowcnt >= 1)
  UPDATE  FROM order_task_xref otx
   SET otx.order_task_type_flag = 2, otx.updt_cnt = (otx.updt_cnt+ 1), otx.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    otx.updt_id = reqinfo->updt_id, otx.updt_applctx = reqinfo->updt_applctx, otx.updt_task = reqinfo
    ->updt_task
   WHERE otx.reference_task_id=referencetaskid
   WITH nocounter
  ;end update
 ENDIF
#exit_script
 IF (failed="T")
  CALL echo("Failed Failed Failed")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.operationname = "Insert"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "Error Message"
  SET reply->status_data.targetobjectvalue = "Failed adding rows"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.operationname = "Insert"
  SET reply->status_data.status = "S"
  SET reply->status_data.operationstatus = "S"
 ENDIF
END GO
