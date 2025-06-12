CREATE PROGRAM aps_get_rpt_hist_grping:dba
 RECORD reply(
   1 task_assay_cnt = i2
   1 task_assay_qual[1]
     2 task_assay_cd = f8
     2 collating_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET max_task_assay_cnt = 1
 SET task_assay_cnt = 0
 SELECT INTO "nl:"
  rh.grouping_cd, rh.task_assay_cd, rh.collating_seq
  FROM report_history_grouping_r rh
  WHERE (rh.grouping_cd=request->grouping_cd)
  ORDER BY rh.collating_seq
  HEAD REPORT
   task_assay_cnt = 0
  DETAIL
   task_assay_cnt = (task_assay_cnt+ 1)
   IF (task_assay_cnt > max_task_assay_cnt)
    stat = alter(reply->task_assay_qual,task_assay_cnt), max_task_assay_cnt = task_assay_cnt
   ENDIF
   reply->task_assay_qual[task_assay_cnt].task_assay_cd = rh.task_assay_cd, reply->task_assay_qual[
   task_assay_cnt].collating_seq = rh.collating_seq
  FOOT REPORT
   reply->task_assay_cnt = task_assay_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_HIST_GRPING"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
