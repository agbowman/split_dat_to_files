CREATE PROGRAM ec_profiler_m3:dba
 SELECT INTO "nl"
  result = build2(trim(nvp.pvc_value),"; Tab: ",trim(nvp2.pvc_value))
  FROM detail_prefs dp,
   name_value_prefs nvp,
   view_prefs vp,
   dummyt d,
   name_value_prefs nvp2
  PLAN (dp
   WHERE dp.application_number=4250111
    AND dp.prsnl_id=0.0)
   JOIN (nvp
   WHERE nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.parent_entity_id=dp.detail_prefs_id
    AND nvp.pvc_name IN ("GENVIEWINFO", "GENSPREADINFO"))
   JOIN (vp
   WHERE vp.application_number=dp.application_number
    AND vp.position_cd=dp.position_cd
    AND vp.prsnl_id=dp.prsnl_id
    AND vp.view_name=dp.view_name
    AND vp.view_seq=dp.view_seq)
   JOIN (d)
   JOIN (nvp2
   WHERE nvp2.parent_entity_name="VIEW_PREFS"
    AND nvp2.parent_entity_id=vp.view_prefs_id
    AND nvp2.pvc_name="VIEW_CAPTION")
  ORDER BY dp.position_cd, result
  HEAD REPORT
   reply->facility_cnt = 1, stat = alterlist(reply->facilities,1), reply->facilities[1].facility_cd
    = 0.0
  HEAD dp.position_cd
   positioncnt = (reply->facilities[1].position_cnt+ 1), reply->facilities[1].position_cnt =
   positioncnt, stat = alterlist(reply->facilities[1].positions,positioncnt),
   reply->facilities[1].positions[positioncnt].position_cd = dp.position_cd, reply->facilities[1].
   positions[positioncnt].capability_in_use_ind = 1
  DETAIL
   detailcnt = (reply->facilities[1].positions[positioncnt].detail_cnt+ 1), reply->facilities[1].
   positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->facilities[1].positions[
    positioncnt].details,detailcnt),
   reply->facilities[1].positions[positioncnt].details[detailcnt].detail_name = "", reply->
   facilities[1].positions[positioncnt].details[detailcnt].detail_value_txt = result
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
