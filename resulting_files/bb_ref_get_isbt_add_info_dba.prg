CREATE PROGRAM bb_ref_get_isbt_add_info:dba
 RECORD reply(
   1 add_info_list[*]
     2 bb_isbt_add_info_id = f8
     2 bb_isbt_product_type_id = f8
     2 attribute_cd = f8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i2
 SET ncnt = 0
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET stat = alterlist(reply->add_info_list,10)
 SELECT INTO "nl:"
  *
  FROM bb_isbt_add_info bia
  PLAN (bia
   WHERE bia.active_ind=1)
  DETAIL
   ncnt = (ncnt+ 1)
   IF (mod(ncnt,10)=1
    AND ncnt != 1)
    stat = alterlist(reply->add_info_list,(ncnt+ 10))
   ENDIF
   reply->add_info_list[ncnt].bb_isbt_add_info_id = bia.bb_isbt_add_info_id, reply->add_info_list[
   ncnt].bb_isbt_product_type_id = bia.bb_isbt_product_type_id, reply->add_info_list[ncnt].
   attribute_cd = bia.attribute_cd,
   reply->add_info_list[ncnt].updt_cnt = bia.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->add_info_list,ncnt)
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
