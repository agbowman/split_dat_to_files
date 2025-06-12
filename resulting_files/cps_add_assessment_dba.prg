CREATE PROGRAM cps_add_assessment:dba
 RECORD reply(
   1 dsm_assessment_id = f8
   1 qual[*]
     2 dsm_component_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET number_total = size(request->qual,5)
 SET stat = alterlist(reply->qual,number_total)
 SELECT INTO "nl:"
  nextseqnum = seq(problem_seq,nextval)"#################;rp0"
  FROM dual
  DETAIL
   reply->dsm_assessment_id = cnvtreal(nextseqnum)
  WITH format
 ;end select
 FOR (x = 1 TO number_total)
   SELECT INTO "nl:"
    nextseqnum = seq(problem_seq,nextval)"#################;rp0"
    FROM dual
    DETAIL
     reply->qual[x].dsm_component_id = cnvtreal(nextseqnum)
    WITH format
   ;end select
 ENDFOR
 INSERT  FROM dsm_assessment da
  SET da.dsm_assessment_id = reply->dsm_assessment_id, da.person_id = request->person_id, da
   .encntr_id = request->encntr_id,
   da.diag_prsnl_id = request->diag_prsnl_id, da.diag_dt_tm = cnvtdatetime(curdate,curtime3), da
   .active_ind = request->active_ind,
   da.active_status_cd = reqdata->active_status_cd, da.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), da.active_status_prsnl_id = reqinfo->updt_id,
   da.beg_effective_dt_tm = cnvtdatetime(request->beg_effective_dt_tm), da.end_effective_dt_tm =
   cnvtdatetime(request->end_effective_dt_tm), da.assessment_type_cd = request->assessment_type_cd,
   da.assessment_dt_tm = cnvtdatetime(request->assessment_dt_tm), da.cgi1_cd = request->cgi1_cd, da
   .cgi2_cd = request->cgi2_cd,
   da.updt_dt_tm = cnvtdatetime(curdate,curtime3), da.updt_id = reqinfo->updt_id, da.updt_task =
   reqinfo->updt_task,
   da.updt_applctx = reqinfo->updt_applctx, da.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (number_total > 0)
  INSERT  FROM dsm_component dc,
    (dummyt d  WITH seq = value(number_total))
   SET dc.dsm_assessment_id = reply->dsm_assessment_id, dc.dsm_component_id = reply->qual[d.seq].
    dsm_component_id, dc.nomenclature_id = request->qual[d.seq].nomenclature_id,
    dc.axis_flag = request->qual[d.seq].axis_flag, dc.component_desc1 = request->qual[d.seq].
    component_desc1, dc.component_desc2 = request->qual[d.seq].component_desc2,
    dc.component_seq = request->qual[d.seq].component_seq, dc.primary_diag_ind = request->qual[d.seq]
    .primary_diag_ind, dc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    dc.updt_id = reqinfo->updt_id, dc.updt_task = reqinfo->updt_task, dc.updt_applctx = reqinfo->
    updt_applctx,
    dc.updt_cnt = 0
   PLAN (d)
    JOIN (dc)
   WITH nocounter
  ;end insert
  IF (curqual=number_total)
   SET reqinfo->commit_ind = 1
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  IF (curqual=1)
   SET reqinfo->commit_ind = 1
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
