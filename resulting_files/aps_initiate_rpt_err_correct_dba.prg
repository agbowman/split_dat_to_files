CREATE PROGRAM aps_initiate_rpt_err_correct:dba
 RECORD reply_addl(
   1 case_updt_cnt = i4
   1 report_qual[*]
     2 report_index = i4
     2 report_id = f8
     2 report_updt_cnt = i4
     2 status_cd = f8
     2 status_disp = c40
     2 skip_ind = i2
     2 updt_id = f8
     2 updt_name_full_formatted = vc
     2 section_qual[*]
       3 section_index = i4
       3 report_detail_id = f8
       3 section_updt_cnt = i4
       3 image_qual[*]
         4 image_index = i4
         4 blob_ref_id = f8
         4 tbnl_long_blob_id = f8
         4 chartable_note_id = f8
         4 chartable_note_updt_cnt = i4
         4 non_chartable_note_id = f8
         4 non_chartable_note_updt_cnt = i4
         4 image_updt_cnt = i4
     2 image_qual[*]
       3 image_index = i4
       3 blob_ref_id = f8
       3 tbnl_long_blob_id = f8
       3 chartable_note_id = f8
       3 chartable_note_updt_cnt = i4
       3 non_chartable_note_id = f8
       3 non_chartable_note_updt_cnt = i4
       3 image_updt_cnt = i4
 )
 RECORD rpt(
   1 order_id = f8
   1 section[*]
     2 task_assay_cd = f8
     2 event_id = f8
     2 result_type_cd = f8
     2 section_sequence = i4
     2 sign_line_ind = i2
     2 required_ind = i2
 )
#script
 DECLARE n_doc_images = i2 WITH protect, constant(2)
 SET reply->status_data.status = "F"
 SET n_images = 1
 SET failed = "F"
 SET error_cnt = 0
 SET nbr_reports = 0
 SET lr = 0
 SET nbr_sections = 0
 SET ls = 0
 SET nbr_images = 0
 SET li = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET pending_status_cd = 0.0
 SET performed_status_cd = 0.0
 SET correction_status_cd = 0.0
 SET deleted_status_cd = 0.0
 SET code_set = 1305
 SET code_value = 0.0
 SET cdf_meaning = "PENDING"
 EXECUTE cpm_get_cd_for_cdf
 SET pending_status_cd = code_value
 SET code_set = 1305
 SET code_value = 0.0
 SET cdf_meaning = "PERFORMED"
 EXECUTE cpm_get_cd_for_cdf
 SET performed_status_cd = code_value
 SET code_set = 1305
 SET code_value = 0.0
 SET cdf_meaning = "CORRECTINIT"
 EXECUTE cpm_get_cd_for_cdf
 SET correction_status_cd = code_value
 SET code_set = 48
 SET code_value = 0.0
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_status_cd = code_value
 IF ((request->report_qual[1].report_task_exists=0))
  SELECT INTO "nl:"
   ce.order_id, p.catalog_cd, d.task_assay_cd,
   nclinicaleventind = evaluate(nullind(ce.task_assay_cd),0,1,0)
   FROM clinical_event ce,
    profile_task_r p,
    discrete_task_assay d
   PLAN (p
    WHERE (request->report_qual[1].catalog_cd=p.catalog_cd))
    JOIN (d
    WHERE p.task_assay_cd=d.task_assay_cd)
    JOIN (ce
    WHERE outerjoin(d.task_assay_cd)=ce.task_assay_cd
     AND outerjoin(request->report_qual[1].event_id)=ce.parent_event_id
     AND outerjoin(cnvtdatetime(curdate,curtime3)) >= ce.valid_from_dt_tm
     AND outerjoin(cnvtdatetime(curdate,curtime3)) <= ce.valid_until_dt_tm
     AND outerjoin(deleted_status_cd) != ce.record_status_cd)
   HEAD REPORT
    sec_cnt = 0, stat = alterlist(rpt->section,5)
   DETAIL
    IF (((nclinicaleventind=1) OR (p.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm)) )
     sec_cnt = (sec_cnt+ 1)
     IF (mod(sec_cnt,5)=1
      AND sec_cnt != 1)
      stat = alterlist(rpt->section,(sec_cnt+ 4))
     ENDIF
     rpt->section[sec_cnt].task_assay_cd = d.task_assay_cd, rpt->section[sec_cnt].result_type_cd = d
     .default_result_type_cd, rpt->section[sec_cnt].sign_line_ind = d.signature_line_ind,
     rpt->section[sec_cnt].section_sequence = p.sequence, rpt->section[sec_cnt].required_ind = p
     .pending_ind
     IF (nclinicaleventind=1)
      rpt->section[sec_cnt].event_id = ce.event_id, rpt->order_id = ce.order_id
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(rpt->section,sec_cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","CLINICAL_EVENT")
   GO TO exit_script
  ENDIF
  INSERT  FROM report_task rt
   SET rt.report_id = request->report_qual[1].report_id, rt.order_id = rpt->order_id, rt
    .service_resource_cd = request->report_qual[1].service_resource_cd,
    rt.responsible_resident_id = request->report_qual[1].responsible_resident_id, rt
    .responsible_pathologist_id = request->report_qual[1].responsible_pathologist_id, rt.priority_cd
     = request->report_qual[1].priority_cd,
    rt.updt_id = reqinfo->updt_id, rt.updt_dt_tm = cnvtdatetime(curdate,curtime3), rt.updt_task =
    reqinfo->updt_task,
    rt.updt_applctx = reqinfo->updt_applctx, rt.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","REPORT_TASK")
   GO TO exit_script
  ENDIF
  INSERT  FROM report_detail_task rt,
    (dummyt d  WITH seq = value(cnvtint(size(rpt->section,5))))
   SET rt.case_id = request->case_id, rt.report_id = request->report_qual[1].report_id, rt.event_id
     = rpt->section[d.seq].event_id,
    rt.task_assay_cd = rpt->section[d.seq].task_assay_cd, rt.result_type_cd = rpt->section[d.seq].
    result_type_cd, rt.section_sequence = rpt->section[d.seq].section_sequence,
    rt.signature_footnote_ind = rpt->section[d.seq].sign_line_ind, rt.required_ind = rpt->section[d
    .seq].required_ind, rt.status_cd =
    IF ((rpt->section[d.seq].event_id=0.0)) pending_status_cd
    ELSE performed_status_cd
    ENDIF
    ,
    rt.updt_dt_tm = cnvtdatetime(curdate,curtime), rt.updt_id = reqinfo->updt_id, rt.updt_task =
    reqinfo->updt_task,
    rt.updt_applctx = reqinfo->updt_applctx, rt.updt_cnt = 0
   PLAN (d)
    JOIN (rt
    WHERE (request->report_qual[1].report_id=rt.report_id)
     AND (rpt->section[d.seq].task_assay_cd=rt.task_assay_cd))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","REPORT_DETAIL_TASK")
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   rt.*
   FROM report_task rt
   WHERE (request->report_qual[1].report_id=rt.report_id)
   DETAIL
    row + 0
   WITH forupdate(rt)
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","REPORT_TASK")
   GO TO exit_script
  ENDIF
  UPDATE  FROM report_task rt
   SET rt.service_resource_cd = request->report_qual[1].service_resource_cd, rt.priority_cd = request
    ->report_qual[1].priority_cd, rt.responsible_resident_id = request->report_qual[1].
    responsible_resident_id,
    rt.responsible_pathologist_id = request->report_qual[1].responsible_pathologist_id, rt.updt_dt_tm
     = cnvtdatetime(curdate,curtime), rt.updt_id = reqinfo->updt_id,
    rt.updt_task = reqinfo->updt_task, rt.updt_applctx = reqinfo->updt_applctx, rt.updt_cnt = (rt
    .updt_cnt+ 1)
   WHERE (request->report_qual[1].report_id=rt.report_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","REPORT_TASK")
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  cr.*
  FROM case_report cr
  WHERE (request->report_qual[1].report_id=cr.report_id)
  DETAIL
   row + 0
  WITH forupdate(cr)
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","CASE_REPORT")
  GO TO exit_script
 ENDIF
 UPDATE  FROM case_report cr
  SET cr.status_cd = correction_status_cd, cr.status_prsnl_id = reqinfo->updt_id, cr.status_dt_tm =
   cnvtdatetime(curdate,curtime),
   cr.updt_dt_tm = cnvtdatetime(curdate,curtime), cr.updt_id = reqinfo->updt_id, cr.updt_task =
   reqinfo->updt_task,
   cr.updt_applctx = reqinfo->updt_applctx, cr.updt_cnt = (cr.updt_cnt+ 1)
  WHERE (request->report_qual[1].report_id=cr.report_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL handle_errors("UPDATE","F","TABLE","CASE_REPORT")
  GO TO exit_script
 ENDIF
 IF ((request->report_qual[1].primary_rpt_ind=1))
  SELECT INTO "nl:"
   pc.case_id
   FROM pathology_case pc
   WHERE (request->case_id=pc.case_id)
   DETAIL
    row + 0
   WITH forupdate(pc)
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","PATHOLOGY_CASE")
   GO TO exit_script
  ENDIF
  UPDATE  FROM pathology_case pc
   SET pc.main_report_cmplete_dt_tm = null, pc.updt_dt_tm = cnvtdatetime(curdate,curtime), pc.updt_id
     = reqinfo->updt_id,
    pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc
    .updt_cnt+ 1)
   WHERE (request->case_id=pc.case_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","PATHOLOGY_CASE")
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   crc.catalog_cd
   FROM cyto_report_control crc
   WHERE (request->report_qual[1].catalog_cd=crc.catalog_cd)
   DETAIL
    row + 0
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SELECT INTO "nl:"
    cse.*
    FROM cyto_screening_event cse
    WHERE (request->case_id=cse.case_id)
     AND cse.verify_ind=1
     AND cse.active_ind=1
    DETAIL
     row + 0
    WITH forupdate(cse)
   ;end select
   IF (curqual != 0)
    UPDATE  FROM cyto_screening_event cse
     SET cse.verify_ind = 0, cse.updt_dt_tm = cnvtdatetime(curdate,curtime), cse.updt_id = reqinfo->
      updt_id,
      cse.updt_task = reqinfo->updt_task, cse.updt_applctx = reqinfo->updt_applctx, cse.updt_cnt = (
      cse.updt_cnt+ 1)
     WHERE (request->case_id=cse.case_id)
      AND cse.verify_ind=1
      AND cse.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL handle_errors("UPDATE","F","TABLE","CYTO_SCREENING_EVENT")
     GO TO exit_script
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    aqi.*
    FROM ap_qa_info aqi
    WHERE (request->case_id=aqi.case_id)
     AND aqi.active_ind=1
    DETAIL
     row + 0
    WITH forupdate(aqi)
   ;end select
   IF (curqual != 0)
    UPDATE  FROM ap_qa_info aqi
     SET aqi.active_ind = 0, aqi.updt_dt_tm = cnvtdatetime(curdate,curtime), aqi.updt_id = reqinfo->
      updt_id,
      aqi.updt_task = reqinfo->updt_task, aqi.updt_applctx = reqinfo->updt_applctx, aqi.updt_cnt = (
      aqi.updt_cnt+ 1)
     WHERE (request->case_id=aqi.case_id)
      AND aqi.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL handle_errors("UPDATE","F","TABLE","AP_QA_INFO")
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (band(request->report_qual[1].blob_bitmap,bor(n_images,n_doc_images)))
  SET request->initiated_by_err_correct_ind = 1
  CALL echo("Executing aps_add_departmental_images...")
  EXECUTE aps_add_departmental_images
  CALL echo("Finished executing aps_add_departmental_images...")
  IF ((reply->status_data.status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
   SET failed = "T"
 END ;Subroutine
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
