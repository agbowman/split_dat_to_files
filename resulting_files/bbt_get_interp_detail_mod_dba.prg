CREATE PROGRAM bbt_get_interp_detail_mod:dba
 RECORD reply(
   1 qual[*]
     2 interp_id = f8
     2 order_catalog_cd = f8
     2 order_catalog_cd_disp = vc
     2 service_resource_cd = f8
     2 service_resource_cd_disp = vc
     2 interp_type_cd = f8
     2 interp_type_cd_disp = vc
     2 interp_option_cd = f8
     2 interp_option_cd_disp = vc
     2 system_ind = i4
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  it.*
  FROM interp_task_assay it
  WHERE (it.task_assay_cd=request->task_assay_cd)
   AND it.active_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].interp_id = it
   .interp_id,
   reply->qual[count].order_catalog_cd = it.order_cat_cd, reply->qual[count].service_resource_cd = it
   .service_resource_cd, reply->qual[count].interp_type_cd = it.interp_type_cd,
   reply->qual[count].interp_option_cd = it.interp_option_cd, reply->qual[count].system_ind = it
   .generate_interp_flag, reply->qual[count].updt_cnt = it.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
