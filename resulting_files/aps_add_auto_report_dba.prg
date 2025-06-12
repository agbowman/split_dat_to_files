CREATE PROGRAM aps_add_auto_report:dba
 RECORD rpt(
   1 rpt_cnt = i2
   1 qual[*]
     2 catalog_cd = f8
     2 report_id = f8
     2 section_cnt = i2
     2 section[*]
       3 task_assay_cd = f8
       3 result_type_cd = f8
       3 sign_line_ind = i2
       3 section_sequence = i4
       3 required_ind = i2
 )
 SET rpt_failed = "F"
 SET stat = alterlist(rpt->qual,5)
 SELECT INTO "nl:"
  d.task_assay_cd, p.catalog_cd, p.pending_ind
  FROM ap_prefix_auto_task at,
   prefix_report_r pr,
   profile_task_r p,
   discrete_task_assay d
  PLAN (at
   WHERE (request->prefix_cd=at.prefix_id))
   JOIN (pr
   WHERE at.prefix_id=pr.prefix_id
    AND at.catalog_cd=pr.catalog_cd)
   JOIN (p
   WHERE at.catalog_cd=p.catalog_cd
    AND p.active_ind=1
    AND sysdate BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm)
   JOIN (d
   WHERE p.task_assay_cd=d.task_assay_cd)
  ORDER BY p.catalog_cd
  HEAD REPORT
   rpt_cnt = 0
  HEAD p.catalog_cd
   rpt_cnt = (rpt_cnt+ 1)
   IF (mod(rpt_cnt,5)=1
    AND rpt_cnt != 1)
    stat = alterlist(rpt->qual,(rpt_cnt+ 4))
   ENDIF
   rpt->rpt_cnt = rpt_cnt, rpt->qual[rpt_cnt].catalog_cd = p.catalog_cd, sec_cnt = 0,
   stat = alterlist(rpt->qual[rpt_cnt].section,5)
  DETAIL
   sec_cnt = (sec_cnt+ 1)
   IF (mod(sec_cnt,5)=1
    AND sec_cnt != 1)
    stat = alterlist(rpt->qual[rpt_cnt].section,(sec_cnt+ 4))
   ENDIF
   rpt->qual[rpt_cnt].section[sec_cnt].task_assay_cd = d.task_assay_cd, rpt->qual[rpt_cnt].section[
   sec_cnt].result_type_cd = d.default_result_type_cd, rpt->qual[rpt_cnt].section[sec_cnt].
   sign_line_ind = d.signature_line_ind,
   rpt->qual[rpt_cnt].section[sec_cnt].section_sequence = p.sequence, rpt->qual[rpt_cnt].section[
   sec_cnt].required_ind = p.pending_ind
  FOOT  p.catalog_cd
   stat = alterlist(rpt->qual[rpt_cnt].section,sec_cnt)
  WITH nocounter
 ;end select
 IF (curqual != 0)
  FOR (y = 1 TO rpt->rpt_cnt)
    SELECT INTO "nl:"
     seq_nbr = seq(pathnet_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      rpt->qual[y].report_id = cnvtreal(seq_nbr)
     WITH format, counter
    ;end select
    IF (curqual=0)
     GO TO seq_failed
    ENDIF
    INSERT  FROM case_report cr
     SET cr.case_id = reply->case_id, cr.report_id = rpt->qual[y].report_id, cr.catalog_cd = rpt->
      qual[y].catalog_cd,
      cr.report_sequence = 0, cr.status_cd = status_cd, cr.status_prsnl_id = reqinfo->updt_id,
      cr.status_dt_tm = cnvtdatetime(curdate,curtime), cr.request_dt_tm = cnvtdatetime(request->
       case_received_dt_tm), cr.request_prsnl_id = reqinfo->updt_id,
      cr.updt_dt_tm = cnvtdatetime(curdate,curtime), cr.updt_id = reqinfo->updt_id, cr.updt_task =
      reqinfo->updt_task,
      cr.updt_applctx = reqinfo->updt_applctx, cr.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO cr_failed
    ENDIF
    INSERT  FROM report_task rt
     SET rt.report_id = rpt->qual[y].report_id, rt.service_resource_cd = 0.0, rt
      .responsible_resident_id = request->responsible_resident_id,
      rt.responsible_pathologist_id = request->responsible_pathologist_id, rt.priority_cd = request->
      priority_cd, rt.updt_dt_tm = cnvtdatetime(curdate,curtime),
      rt.updt_id = reqinfo->updt_id, rt.updt_task = reqinfo->updt_task, rt.updt_applctx = reqinfo->
      updt_applctx,
      rt.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO rt_failed
    ENDIF
    INSERT  FROM report_detail_task rt,
      (dummyt d  WITH seq = value(size(rpt->qual[y].section,5)))
     SET rt.case_id = reply->case_id, rt.report_id = rpt->qual[y].report_id, rt.task_assay_cd = rpt->
      qual[y].section[d.seq].task_assay_cd,
      rt.result_type_cd = rpt->qual[y].section[d.seq].result_type_cd, rt.signature_footnote_ind = rpt
      ->qual[y].section[d.seq].sign_line_ind, rt.section_sequence = rpt->qual[y].section[d.seq].
      section_sequence,
      rt.required_ind = rpt->qual[y].section[d.seq].required_ind, rt.status_cd = detail_status_cd, rt
      .updt_dt_tm = cnvtdatetime(curdate,curtime),
      rt.updt_id = reqinfo->updt_id, rt.updt_task = reqinfo->updt_task, rt.updt_applctx = reqinfo->
      updt_applctx,
      rt.updt_cnt = 0
     PLAN (d)
      JOIN (rt
      WHERE (rpt->qual[y].report_id=rt.report_id)
       AND (rpt->qual[y].section[d.seq].task_assay_cd=rt.task_assay_cd))
     WITH nocounter, outerjoin = d, dontexist
    ;end insert
    IF (curqual=0)
     GO TO rdt_failed
    ENDIF
    SET stat = alterlist(reply->rpt_qual,y)
    SET reply->rpt_qual[y].report_id = rpt->qual[y].report_id
    SET reply->rpt_qual[y].catalog_cd = rpt->qual[y].catalog_cd
  ENDFOR
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "NEXTVAL"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "REFERENCE_SEQ"
 SET rpt_failed = "T"
 GO TO exit_script
#cr_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
 SET rpt_failed = "T"
 GO TO exit_script
#rt_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_TASK"
 SET rpt_failed = "T"
 GO TO exit_script
#rdt_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_DETAIL_TASK"
 SET rpt_failed = "T"
#exit_script
 IF (rpt_failed="T")
  SET reply->status_data.status = "P"
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
