CREATE PROGRAM aps_get_db_reports_status:dba
 RECORD reply(
   1 detail_proc_cnt = i4
   1 detail_proc_qual[10]
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 transcribed_status_cd = f8
     2 processing_sequence = i4
     2 sequence = i4
     2 cancelable_ind = i2
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.sequence, ris.transcribed_status_cd, ris.processing_sequence
  FROM profile_task_r p,
   report_inproc_status ris,
   (dummyt d1  WITH seq = 1)
  PLAN (p
   WHERE (p.catalog_cd=request->catalog_cd)
    AND p.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm)
   JOIN (d1)
   JOIN (ris
   WHERE p.catalog_cd=ris.catalog_cd
    AND p.task_assay_cd=ris.task_assay_cd)
  HEAD REPORT
   reply->detail_proc_cnt = 0
  DETAIL
   reply->detail_proc_cnt = (reply->detail_proc_cnt+ 1)
   IF (mod(reply->detail_proc_cnt,10)=1
    AND (reply->detail_proc_cnt != 1))
    stat = alter(reply->detail_proc_qual,(reply->detail_proc_cnt+ 9))
   ENDIF
   reply->detail_proc_qual[reply->detail_proc_cnt].sequence = p.sequence, reply->detail_proc_qual[
   reply->detail_proc_cnt].task_assay_cd = p.task_assay_cd
   IF (p.task_assay_cd=ris.task_assay_cd)
    reply->detail_proc_qual[reply->detail_proc_cnt].transcribed_status_cd = ris.transcribed_status_cd,
    reply->detail_proc_qual[reply->detail_proc_cnt].processing_sequence = ris.processing_sequence,
    reply->detail_proc_qual[reply->detail_proc_cnt].cancelable_ind = ris.cancelable_ind,
    reply->detail_proc_qual[reply->detail_proc_cnt].updt_cnt = ris.updt_cnt
   ENDIF
  WITH outerjoin = d1
 ;end select
 IF (mod(reply->detail_proc_cnt,10) != 1)
  SET stat = alter(reply->detail_proc_qual,reply->detail_proc_cnt)
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET_REPORTS_STATUS"
  SET failed = "T"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
