CREATE PROGRAM ec_profiler_m2:dba
 SELECT INTO "nl"
  FROM app_prefs ap,
   name_value_prefs nvp
  PLAN (ap
   WHERE ap.prsnl_id=0
    AND ap.application_number=4250111)
   JOIN (nvp
   WHERE nvp.parent_entity_id=ap.app_prefs_id
    AND nvp.pvc_name="TOOLBAR_STYLE"
    AND nvp.active_ind=1)
  HEAD REPORT
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = 0.0
  DETAIL
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = ap.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
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
