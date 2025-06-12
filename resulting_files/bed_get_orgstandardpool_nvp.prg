CREATE PROGRAM bed_get_orgstandardpool_nvp
 DECLARE val = vc
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 FREE SET reply
 RECORD reply(
   1 pool_ind = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 SET val = fillstring(1," ")
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="SYSTEMPARAM"
    AND bnv.br_name="ORGSTANDARDPOOL")
  DETAIL
   val = bnv.br_value
  WITH nocounter
 ;end select
 IF (val="0")
  SET reply->pool_ind = 0
 ELSE
  SET reply->pool_ind = 1
 ENDIF
 GO TO exitscript
#exitscript
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET reply->error_msg = concat("  >>PROGRAM NAME: BED_GET_ORGSTANDARDPOOL_NVP","  >>ERROR MSG: ",
   error_msg)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
