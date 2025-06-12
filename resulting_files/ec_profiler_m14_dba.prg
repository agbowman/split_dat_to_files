CREATE PROGRAM ec_profiler_m14:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl"
  FROM view_prefs vp
  WHERE vp.prsnl_id=0.0
   AND vp.position_cd >= 0.0
   AND vp.application_number > 0.0
   AND vp.frame_type="CHART"
   AND vp.view_name="EASYSCRIPT"
  ORDER BY vp.position_cd
  HEAD REPORT
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = 0.0
  HEAD vp.position_cd
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = vp.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, detailcnt = (reply->
   facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1),
   reply->facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(
    reply->facilities[facilitycnt].positions[positioncnt].details,detailcnt), reply->facilities[
   facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "",
   reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = ""
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
