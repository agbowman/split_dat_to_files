CREATE PROGRAM ec_profiler_m49:dba
 DECLARE ddptaction = f8 WITH constant(uar_get_code_by("MEANING",20500,"DPT_ACTION"))
 SELECT INTO "nl"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   track_prefs tp,
   track_comp_prefs tcp
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.cdf_meaning="OTHER")
   JOIN (tg
   WHERE tg.child_value=0
    AND tg.tracking_group_cd=cv.code_value)
   JOIN (tc
   WHERE tc.tracking_group_cd=tg.tracking_group_cd)
   JOIN (tp
   WHERE tp.comp_name_unq=concat(cnvtstring(tc.tracking_group_cd),";",cnvtstring(ddptaction))
    AND tp.comp_type_cd=ddptaction)
   JOIN (tcp
   WHERE tcp.track_pref_id=tp.track_pref_id
    AND tcp.sub_comp_name != "LONG_TEXT_REFERENCE")
  ORDER BY tcp.sub_comp_name
  HEAD REPORT
   reply->facility_cnt = 1, stat = alterlist(reply->facilities,1), reply->facilities[1].facility_cd
    = 0.0,
   reply->facilities[1].position_cnt = 1, stat = alterlist(reply->facilities[1].positions,1), reply->
   facilities[1].positions[1].position_cd = 0.0,
   reply->facilities[1].positions[1].capability_in_use_ind = 1
  HEAD tcp.sub_comp_name
   detailcnt = (reply->facilities[1].positions[1].detail_cnt+ 1), reply->facilities[1].positions[1].
   detail_cnt = detailcnt, stat = alterlist(reply->facilities[1].positions[1].details,detailcnt),
   reply->facilities[1].positions[1].details[detailcnt].detail_name = "Action Items", reply->
   facilities[1].positions[1].details[detailcnt].detail_value_txt = trim(tcp.sub_comp_name)
  WITH nocounter
 ;end select
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
