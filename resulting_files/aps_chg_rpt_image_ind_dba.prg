CREATE PROGRAM aps_chg_rpt_image_ind:dba
#script
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET success = "S"
 SET orig_updt_cnt = 0
 SELECT INTO "nl:"
  cr.report_id
  FROM case_report cr,
   (dummyt d  WITH seq = value(cnvtint(size(request->report_qual,5))))
  PLAN (d)
   JOIN (cr
   WHERE (cr.report_id=request->report_qual[d.seq].report_id)
    AND (request->report_qual[d.seq].report_id != 0))
  DETAIL
   orig_updt_cnt = cr.updt_cnt
  WITH nocounter, forupdate(cr)
 ;end select
 IF (curqual=0)
  GO TO lock_case_failed
 ENDIF
 IF ((request->updt_cnt != orig_updt_cnt))
  GO TO update_cnt_changed
 ENDIF
 UPDATE  FROM case_report cr,
   (dummyt d  WITH seq = value(cnvtint(size(request->report_qual,5))))
  SET cr.blob_bitmap = request->report_qual[d.seq].blob_bitmap, cr.updt_cnt = (cr.updt_cnt+ 1)
  PLAN (d)
   JOIN (cr
   WHERE (cr.report_id=request->report_qual[d.seq].report_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  GO TO update_failed
 ENDIF
 GO TO exit_script
#update_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
 SET success = "T"
 GO TO exit_script
#update_cnt_changed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE_CNT_CHANGED"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
 SET success = "T"
 GO TO exit_script
#lock_case_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
 SET success = "T"
 GO TO exit_script
#exit_script
 IF (success="S")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
