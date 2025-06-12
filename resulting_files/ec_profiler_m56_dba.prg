CREATE PROGRAM ec_profiler_m56:dba
 SELECT INTO "nl:"
  FROM view_prefs vp
  WHERE vp.prsnl_id=0
   AND vp.position_cd >= 0
   AND vp.application_number=600005
   AND vp.frame_type="ORG"
   AND vp.view_name IN ("SHIFTASSIGNM", "STAFFASSIGNM")
  ORDER BY vp.position_cd, vp.view_name
  HEAD REPORT
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = 0.0
  HEAD vp.position_cd
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = vp.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
  HEAD vp.view_name
   detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
   facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
    facilities[facilitycnt].positions[positioncnt].details,detailcnt),
   reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = trim(vp
    .view_name)
  WITH nocounter
 ;end select
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
