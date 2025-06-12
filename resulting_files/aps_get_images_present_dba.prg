CREATE PROGRAM aps_get_images_present:dba
 RECORD reply(
   1 section_qual[*]
     2 task_assay_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET max_section_cnt = size(request->section_qual,5)
 SET section_cnt = 0
 SELECT INTO "nl:"
  rdi.report_detail_id
  FROM report_detail_image rdi,
   (dummyt d  WITH seq = value(max_section_cnt))
  PLAN (d)
   JOIN (rdi
   WHERE (rdi.report_id=request->report_id)
    AND (rdi.task_assay_cd=request->section_qual[d.seq].task_assay_cd))
  HEAD REPORT
   stat = alterlist(reply->section_qual,10)
  DETAIL
   section_cnt = (section_cnt+ 1)
   IF (mod(section_cnt,10)=1)
    stat = alterlist(reply->section_qual,(section_cnt+ 9))
   ENDIF
   reply->section_qual[section_cnt].task_assay_cd = rdi.task_assay_cd
  FOOT REPORT
   stat = alterlist(reply->section_qual,section_cnt)
  WITH nocounter
 ;end select
 IF (section_cnt=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_DETAIL_IMAGE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
