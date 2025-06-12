CREATE PROGRAM ec_profiler_m78:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl:"
  FROM hm_expect hm,
   hm_expect_series hms
  PLAN (hm
   WHERE hm.active_ind=1
    AND hm.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND hm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (hms
   WHERE hms.expect_series_id=hm.expect_series_id
    AND hms.active_ind=1
    AND hms.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND hms.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY hms.expect_series_name
  HEAD REPORT
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = 0.0, positioncnt = (reply->facilities[facilitycnt].
   position_cnt+ 1), reply->facilities[facilitycnt].position_cnt = positioncnt,
   stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt), reply->facilities[
   facilitycnt].positions[positioncnt].position_cd = 0.0, reply->facilities[facilitycnt].positions[
   positioncnt].capability_in_use_ind = 1
  HEAD hms.expect_series_name
   detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
   facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
    facilities[facilitycnt].positions[positioncnt].details,detailcnt),
   reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = hms
   .expect_series_name
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
