CREATE PROGRAM bbt_get_interp_id:dba
 RECORD reply(
   1 interp_id = f8
   1 order_catalog_cd = f8
   1 interp_type_cd = f8
   1 interp_option_cd = f8
   1 bb_phases_cd = f8
   1 system_ind = i4
   1 updt_cnt = i4
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
  it.*
  FROM interp_task_assay it
  WHERE (it.task_assay_cd=request->task_assay_cd)
   AND (it.service_resource_cd=request->service_resource_cd)
   AND (it.order_cat_cd=request->order_catalog_cd)
   AND it.active_ind=1
  DETAIL
   reply->interp_id = it.interp_id, reply->order_catalog_cd = it.order_cat_cd, reply->interp_type_cd
    = it.interp_type_cd,
   reply->interp_option_cd = it.interp_option_cd, reply->system_ind = it.generate_interp_flag, reply
   ->updt_cnt = it.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
