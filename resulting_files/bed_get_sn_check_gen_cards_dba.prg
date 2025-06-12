CREATE PROGRAM bed_get_sn_check_gen_cards:dba
 FREE SET reply
 RECORD reply(
   1 gen_pref_cards_exist_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->gen_pref_cards_exist_ind = 0
 SELECT INTO "NL:"
  FROM preference_card pc
  WHERE pc.catalog_cd > 0.0
   AND pc.prsnl_id=0.0
   AND pc.surg_area_cd > 0.0
  DETAIL
   reply->gen_pref_cards_exist_ind = 1
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
