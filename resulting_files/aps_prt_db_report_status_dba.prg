CREATE PROGRAM aps_prt_db_report_status:dba
 RECORD reply(
   1 report_proc_cnt = i4
   1 report_proc_qual[*]
     2 mnemonic = vc
     2 rpt_detail_cnt = i4
     2 rpt_detail_qual[*]
       3 detail_task_assay_cd = f8
       3 detail_task_assay_disp = vc
       3 ris_description = c40
       3 ris_proc_seq = i4
       3 ris_cancelable_ind = c1
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
 SET proc_cnt = 0
 SET detail_cnt = 0
 SELECT INTO "nl:"
  ris.task_assay_cd, p.task_assay_cd, group_mnemonic = oc.primary_mnemonic,
  c1.display, c1.description, ris.processing_sequence
  FROM order_catalog oc,
   profile_task_r p,
   report_inproc_status ris,
   (dummyt d1  WITH seq = 1),
   code_value c1
  PLAN (ris)
   JOIN (p
   WHERE ris.catalog_cd=p.catalog_cd
    AND p.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm)
   JOIN (d1)
   JOIN (c1
   WHERE ris.transcribed_status_cd=c1.code_value
    AND c1.code_set=1305)
   JOIN (oc
   WHERE ris.catalog_cd=oc.catalog_cd)
  ORDER BY group_mnemonic, p.task_assay_cd
  HEAD REPORT
   reply->report_proc_cnt = 0
  HEAD group_mnemonic
   detail_cnt = 0, reply->report_proc_cnt = (reply->report_proc_cnt+ 1), stat = alterlist(reply->
    report_proc_qual,reply->report_proc_cnt),
   reply->report_proc_qual[reply->report_proc_cnt].mnemonic = oc.primary_mnemonic
  HEAD p.task_assay_cd
   detail_cnt = (detail_cnt+ 1), reply->report_proc_qual[reply->report_proc_cnt].rpt_detail_cnt =
   detail_cnt, stat = alterlist(reply->report_proc_qual[reply->report_proc_cnt].rpt_detail_qual,
    detail_cnt),
   reply->report_proc_qual[reply->report_proc_cnt].rpt_detail_qual[detail_cnt].detail_task_assay_cd
    = p.task_assay_cd
  DETAIL
   IF (p.task_assay_cd=ris.task_assay_cd)
    reply->report_proc_qual[reply->report_proc_cnt].rpt_detail_qual[detail_cnt].ris_description = c1
    .display, reply->report_proc_qual[reply->report_proc_cnt].rpt_detail_qual[detail_cnt].
    ris_proc_seq = ris.processing_sequence
    IF (ris.cancelable_ind=1)
     reply->report_proc_qual[reply->report_proc_cnt].rpt_detail_qual[detail_cnt].ris_cancelable_ind
      = "Y"
    ELSE
     reply->report_proc_qual[reply->report_proc_cnt].rpt_detail_qual[detail_cnt].ris_cancelable_ind
      = "N"
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operatonstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "APS_PRT_DB_REPORT_STATUS"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
