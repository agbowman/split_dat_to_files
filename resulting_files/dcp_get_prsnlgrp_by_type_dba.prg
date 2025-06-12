CREATE PROGRAM dcp_get_prsnlgrp_by_type:dba
 RECORD reply(
   1 qual[*]
     2 prsnl_group_id = f8
     2 prsnl_group_name = vc
     2 prsnl_group_desc = vc
     2 active_ind = i2
     2 prsnl_group_type_cd = f8
     2 prsnl_group_class_cd = f8
     2 service_resource_cd = f8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET code_value = 0.0
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET active_cd = code_value
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  p.prsnl_group_id
  FROM prsnl_group p
  WHERE (p.prsnl_group_class_cd=request->prsnl_group_class_cd)
   AND p.active_ind=1
   AND p.prsnl_group_id != 0
   AND p.active_status_cd=active_cd
  ORDER BY cnvtupper(p.prsnl_group_name)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].prsnl_group_id = p.prsnl_group_id, reply->qual[count1].prsnl_group_name = p
   .prsnl_group_name, reply->qual[count1].prsnl_group_desc = p.prsnl_group_desc,
   reply->qual[count1].active_ind = p.active_ind, reply->qual[count1].prsnl_group_type_cd = p
   .prsnl_group_type_cd, reply->qual[count1].prsnl_group_class_cd = p.prsnl_group_class_cd,
   reply->qual[count1].service_resource_cd = p.service_resource_cd, reply->qual[count1].updt_cnt = p
   .updt_cnt
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alterlist(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
