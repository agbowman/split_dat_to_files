CREATE PROGRAM bb_ref_get_isbt_attribute_r:dba
 RECORD reply(
   1 isbt_attribute_r[*]
     2 bb_isbt_attribute_r_id = f8
     2 attribute_cd = f8
     2 bb_isbt_attribute_id = f8
     2 update_cnt = i4
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
 SET stat = alterlist(reply->isbt_attribute_r,10)
 SELECT INTO "nl:"
  *
  FROM bb_isbt_attribute_r bia
  PLAN (bia
   WHERE bia.active_ind=1)
  DETAIL
   ncnt = (ncnt+ 1)
   IF (mod(ncnt,10)=1
    AND ncnt != 1)
    stat = alterlist(reply->isbt_attribute_r,(ncnt+ 10))
   ENDIF
   reply->isbt_attribute_r[ncnt].bb_isbt_attribute_r_id = bia.bb_isbt_attribute_r_id, reply->
   isbt_attribute_r[ncnt].attribute_cd = bia.attribute_cd, reply->isbt_attribute_r[ncnt].
   bb_isbt_attribute_id = bia.bb_isbt_attribute_id,
   reply->isbt_attribute_r[ncnt].update_cnt = bia.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->isbt_attribute_r,ncnt)
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
