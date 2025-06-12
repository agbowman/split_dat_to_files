CREATE PROGRAM ec_profiler_m84:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl"
  FROM view_prefs vp
  WHERE vp.application_number=600005
   AND vp.prsnl_id=0.0
   AND vp.position_cd >= 0.0
   AND vp.frame_type="ORG"
   AND vp.view_name="HOMEVIEW"
  ORDER BY vp.position_cd
  HEAD REPORT
   reply->facility_cnt = 1, stat = alterlist(reply->facilities,1), reply->facilities[1].facility_cd
    = 0.0,
   positioncnt = 0
  HEAD vp.position_cd
   positioncnt = (reply->facilities[1].position_cnt+ 1), reply->facilities[1].position_cnt =
   positioncnt, stat = alterlist(reply->facilities[1].positions,positioncnt),
   reply->facilities[1].positions[positioncnt].position_cd = vp.position_cd, reply->facilities[1].
   positions[positioncnt].capability_in_use_ind = 1, personcnt = 0,
   reply->facilities[1].positions[positioncnt].detail_cnt = 1, stat = alterlist(reply->facilities[1].
    positions[positioncnt].details,1), reply->facilities[1].positions[positioncnt].details[1].
   detail_name = "",
   reply->facilities[1].positions[positioncnt].details[1].detail_value_txt = ""
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
