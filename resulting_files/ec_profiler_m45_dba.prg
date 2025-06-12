CREATE PROGRAM ec_profiler_m45:dba
 SELECT INTO "nl"
  FROM view_prefs vp,
   name_value_prefs nvp
  PLAN (vp
   WHERE vp.prsnl_id=0
    AND vp.position_cd >= 0
    AND vp.application_number=600005
    AND vp.frame_type="CHART"
    AND vp.view_name="MARSUMMARY")
   JOIN (nvp
   WHERE nvp.parent_entity_id=vp.view_prefs_id)
  HEAD REPORT
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = 0.0
  DETAIL
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = 0.0, reply->facilities[
   facilitycnt].positions[positioncnt].capability_in_use_ind = 1
  WITH nocounter, maxrec = 1
 ;end select
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
