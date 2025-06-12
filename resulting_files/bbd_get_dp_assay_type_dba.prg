CREATE PROGRAM bbd_get_dp_assay_type:dba
 RECORD reply(
   1 assays[*]
     2 task_assay_cd = f8
     2 bb_processing_cd = f8
     2 bb_processing_cd_disp = c40
     2 bb_processing_cd_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET nbr_of_assays = size(request->assays,5)
 SET count = 0
 SELECT INTO "nl:"
  s.*
  FROM (dummyt d1  WITH seq = value(nbr_of_assays)),
   interp_task_assay ita,
   service_directory s
  PLAN (d1)
   JOIN (ita
   WHERE (ita.task_assay_cd=request->assays[d1.seq].task_assay_cd)
    AND (((ita.service_resource_cd=request->assays[d1.seq].service_resource_cd)) OR (ita
   .service_resource_cd=0))
    AND ita.active_ind=1)
   JOIN (s
   WHERE s.catalog_cd=ita.order_cat_cd
    AND s.active_ind=1)
  ORDER BY ita.task_assay_cd, ita.service_resource_cd DESC
  HEAD ita.task_assay_cd
   count = (count+ 1), stat = alterlist(reply->assays,count), reply->assays[count].task_assay_cd =
   ita.task_assay_cd,
   reply->assays[count].bb_processing_cd = s.bb_processing_cd
  HEAD ita.service_resource_cd
   row + 1
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO
