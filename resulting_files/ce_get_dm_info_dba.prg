CREATE PROGRAM ce_get_dm_info:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 DECLARE cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  dm.info_char
  FROM dm_info dm
  WHERE (dm.info_name=request->info_name)
  DETAIL
   cnt += 1, reply->status = dm.info_char
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
