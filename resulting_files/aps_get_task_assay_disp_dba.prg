CREATE PROGRAM aps_get_task_assay_disp:dba
 RECORD reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 task_assay_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET num_of_details = value(size(request->task_qual,5))
 SELECT INTO "nl:"
  d1.*
  FROM (dummyt d1  WITH seq = value(num_of_details))
  HEAD REPORT
   stat = alterlist(reply->qual,num_of_details), cnt = 0
  DETAIL
   cnt = (cnt+ 1), reply->qual[cnt].task_assay_cd = request->task_qual[cnt].task_assay_cd
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
