CREATE PROGRAM dcp_get_task_discrete_r:dba
 RECORD reply(
   1 taskdiscreter[*]
     2 required_ind = i2
     2 sequence = i4
     2 task_assay_cd = f8
     2 task_assay_display = vc
     2 acknowledge_ind = i2
     2 document_ind = i2
     2 view_only_ind = i2
     2 offset_min_nbr = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ack_result_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002164,
   "ACKRESULTMIN"))
 DECLARE ncnt = i4 WITH protect, noconstant(0)
 CALL echo(build("ack_result_type_cd: ",ack_result_type_cd))
 SELECT INTO "nl:"
  codevaluedisplay = uar_get_code_display(tdr.task_assay_cd)
  FROM task_discrete_r tdr,
   dta_offset_min dom
  PLAN (tdr
   WHERE (tdr.reference_task_id=request->reference_task_id)
    AND tdr.active_ind=1)
   JOIN (dom
   WHERE dom.task_assay_cd=outerjoin(tdr.task_assay_cd)
    AND dom.active_ind=outerjoin(1)
    AND dom.offset_min_type_cd=outerjoin(ack_result_type_cd)
    AND dom.end_effective_dt_tm >= outerjoin(cnvtdatetime("31-DEC-2100")))
  ORDER BY tdr.sequence
  HEAD REPORT
   ncnt = 0
  DETAIL
   ncnt = (ncnt+ 1),
   CALL echo(build("nCnt: ",ncnt))
   IF (ncnt > size(reply->taskdiscreter,5))
    stat = alterlist(reply->taskdiscreter,(ncnt+ 10))
   ENDIF
   reply->taskdiscreter[ncnt].required_ind = tdr.required_ind, reply->taskdiscreter[ncnt].sequence =
   tdr.sequence, reply->taskdiscreter[ncnt].task_assay_cd = tdr.task_assay_cd,
   reply->taskdiscreter[ncnt].task_assay_display = codevaluedisplay, reply->taskdiscreter[ncnt].
   acknowledge_ind = tdr.acknowledge_ind, reply->taskdiscreter[ncnt].document_ind = tdr.document_ind,
   reply->taskdiscreter[ncnt].view_only_ind = tdr.view_only_ind, reply->taskdiscreter[ncnt].
   offset_min_nbr = dom.offset_min_nbr,
   CALL echo(build("CodeValueDisplay: ",codevaluedisplay))
  FOOT REPORT
   stat = alterlist(reply->taskdiscreter,ncnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.operationname = "SELECT"
 SET reply->status_data.operationstatus = "T"
 SET reply->status_data.status = "S"
END GO
