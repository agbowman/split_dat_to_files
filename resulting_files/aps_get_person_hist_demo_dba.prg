CREATE PROGRAM aps_get_person_hist_demo:dba
 RECORD reply(
   1 case_blob_bitmap = i4
   1 report_blob_bitmap = i4
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
  FROM pathology_case pc
  PLAN (pc
   WHERE (pc.case_id=request->case_id))
  DETAIL
   reply->case_blob_bitmap = pc.blob_bitmap
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM case_report cr
  PLAN (cr
   WHERE (cr.case_id=request->case_id))
  DETAIL
   reply->report_blob_bitmap = bor(reply->report_blob_bitmap,cr.blob_bitmap)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
END GO
