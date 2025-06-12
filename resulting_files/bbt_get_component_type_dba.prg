CREATE PROGRAM bbt_get_component_type:dba
 RECORD reply(
   1 component_cd = f8
   1 component_cd_disp = c40
   1 component_cd_mean = c12
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
  s.*
  FROM interp_task_assay ita,
   service_directory s
  PLAN (ita
   WHERE (ita.task_assay_cd=request->assay_cd)
    AND ita.active_ind=1)
   JOIN (s
   WHERE s.catalog_cd=ita.order_cat_cd)
  DETAIL
   reply->component_cd = s.bb_processing_cd
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO
