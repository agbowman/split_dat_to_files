CREATE PROGRAM ce_get_ce_prefs:dba
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 DECLARE cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  cp.pref_value
  FROM ce_prefs cp
  WHERE (cp.pref_name=request->pref_name)
  DETAIL
   cnt = (cnt+ 1), reply->pref_value = cp.pref_value
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
