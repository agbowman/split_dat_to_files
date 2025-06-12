CREATE PROGRAM bbt_get_service_resources:dba
 RECORD reply(
   1 qual[*]
     2 resource_cd = f8
     2 resource_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  d.task_assay_cd
  FROM assay_processing_r d
  WHERE (d.task_assay_cd=request->task_assay_cd)
   AND d.active_ind=1
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].resource_cd = d
   .service_resource_cd
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO
