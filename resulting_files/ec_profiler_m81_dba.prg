CREATE PROGRAM ec_profiler_m81:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl"
  FROM application_context ac,
   prsnl p
  PLAN (ac
   WHERE ac.application_number=961000
    AND ac.start_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm))
   JOIN (p
   WHERE p.person_id=ac.person_id)
  ORDER BY p.position_cd
  HEAD REPORT
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = 0.0, positioncnt = 0
  HEAD p.position_cd
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, reply->facilities[
   facilitycnt].positions[positioncnt].detail_cnt = 1,
   stat = alterlist(reply->facilities[facilitycnt].positions[positioncnt].details,1), reply->
   facilities[facilitycnt].positions[positioncnt].details[1].detail_name = "", reply->facilities[
   facilitycnt].positions[positioncnt].details[1].detail_value_txt = ""
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
