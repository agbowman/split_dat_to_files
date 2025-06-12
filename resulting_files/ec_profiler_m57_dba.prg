CREATE PROGRAM ec_profiler_m57:dba
 SELECT INTO "nl:"
  FROM dcp_shift_assignment dsa
  PLAN (dsa
   WHERE dsa.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND ((dsa.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
    AND dsa.active_ind=1)
  ORDER BY dsa.loc_facility_cd, dsa.encntr_id
  HEAD REPORT
   facilitycnt = 0
  HEAD dsa.loc_facility_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = dsa.loc_facility_cd, positioncnt = (reply->
   facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].position_cnt =
   positioncnt,
   stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt), reply->facilities[
   facilitycnt].positions[positioncnt].position_cd = 0.0, reply->facilities[facilitycnt].positions[
   positioncnt].capability_in_use_ind = 1,
   encntrcnt = 0
  HEAD dsa.encntr_id
   encntrcnt = (encntrcnt+ 1)
  FOOT  dsa.loc_facility_cd
   detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
   facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
    facilities[facilitycnt].positions[positioncnt].details,detailcnt),
   reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = trim(
    cnvtstring(encntrcnt))
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
