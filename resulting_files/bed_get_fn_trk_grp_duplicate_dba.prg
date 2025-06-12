CREATE PROGRAM bed_get_fn_trk_grp_duplicate:dba
 FREE SET reply
 RECORD reply(
   1 duplicate_ind = i2
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
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="FNTRKGRP_PREFIX"
    AND (bnv.br_value=request->trk_grp_prefix))
  DETAIL
   reply->duplicate_ind = 1
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
