CREATE PROGRAM ec_profiler_m116:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl:"
  FROM med_admin_event mae,
   task_activity ta,
   nurse_unit nu,
   prsnl p
  PLAN (mae
   WHERE mae.beg_dt_tm >= cnvtdatetime(request->start_dt_tm)
    AND mae.end_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND mae.source_application_flag=1)
   JOIN (ta
   WHERE ta.event_id=mae.event_id
    AND ta.task_dt_tm >= cnvtdatetime(request->start_dt_tm)
    AND ta.task_dt_tm <= cnvtdatetime(request->stop_dt_tm))
   JOIN (nu
   WHERE nu.location_cd=ta.location_cd)
   JOIN (p
   WHERE p.person_id=ta.performed_prsnl_id)
  ORDER BY nu.loc_facility_cd, p.position_cd
  HEAD REPORT
   facilitycnt = 0
  HEAD nu.loc_facility_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = nu.loc_facility_cd, positioncnt = 0
  HEAD p.position_cd
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, detailcnt = 0
  DETAIL
   detailcnt = (detailcnt+ 1)
  FOOT  p.position_cd
   reply->facilities[facilitycnt].positions[positioncnt].detail_cnt = 1, stat = alterlist(reply->
    facilities[facilitycnt].positions[positioncnt].details,1), reply->facilities[facilitycnt].
   positions[positioncnt].details[1].detail_name = "",
   reply->facilities[facilitycnt].positions[positioncnt].details[1].detail_value_txt = cnvtstring(
    detailcnt)
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
