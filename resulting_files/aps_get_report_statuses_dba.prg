CREATE PROGRAM aps_get_report_statuses:dba
 RECORD reply(
   1 status_qual[5]
     2 task_assay_cd = f8
     2 processing_sequence = i4
     2 transcribed_status_cd = f8
     2 transcribed_status_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET stat_cnt = 0
 SELECT INTO "nl:"
  rs.task_assay_cd, rs.processing_sequence, rs.transcribed_status_cd
  FROM report_inproc_status rs
  PLAN (rs
   WHERE (rs.catalog_cd=request->catalog_cd))
  ORDER BY rs.processing_sequence DESC
  HEAD REPORT
   stat_cnt = 0
  DETAIL
   stat_cnt = (stat_cnt+ 1)
   IF (mod(stat_cnt,5)=1
    AND stat_cnt != 1)
    stat = alter(reply->status_qual,(stat_cnt+ 4))
   ENDIF
   reply->status_qual[stat_cnt].task_assay_cd = rs.task_assay_cd, reply->status_qual[stat_cnt].
   processing_sequence = rs.processing_sequence, reply->status_qual[stat_cnt].transcribed_status_cd
    = rs.transcribed_status_cd
  WITH nocounter
 ;end select
 SET stat = alter(reply->status_qual,stat_cnt)
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_INPROC_STATUS"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
