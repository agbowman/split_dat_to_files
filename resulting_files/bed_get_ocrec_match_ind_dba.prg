CREATE PROGRAM bed_get_ocrec_match_ind:dba
 FREE SET reply
 RECORD reply(
   1 new_match_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->new_match_ind = 1
 SELECT INTO "nl:"
  FROM br_oc_work b
  PLAN (b
   WHERE (b.catalog_type=request->catalog_type)
    AND (b.activity_type=request->activity_type)
    AND b.match_orderable_cd > 0)
  DETAIL
   reply->new_match_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_name_value n
  PLAN (n
   WHERE n.br_nv_key1="NEW_PHASE_X_MATCH")
  DETAIL
   reply->new_match_ind = 0
  WITH nocounter
 ;end select
 CALL echorecord(reply)
 SET reply->status_data.status = "S"
END GO
