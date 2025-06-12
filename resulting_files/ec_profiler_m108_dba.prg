CREATE PROGRAM ec_profiler_m108:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl:"
  FROM order_radiology o,
   rad_exam re,
   encntr_loc_hist elh
  PLAN (o
   WHERE o.complete_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm))
   JOIN (re
   WHERE re.order_id=o.order_id
    AND re.complete_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= re.complete_dt_tm
    AND elh.end_effective_dt_tm >= re.complete_dt_tm)
  ORDER BY elh.loc_facility_cd
  HEAD elh.loc_facility_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd, reply->facilities[facilitycnt].
   position_cnt = 1, stat = alterlist(reply->facilities[facilitycnt].positions,1),
   reply->facilities[facilitycnt].positions[1].position_cd = 0.0, reply->facilities[facilitycnt].
   positions[1].capability_in_use_ind = 1, resultcnt = 0
  DETAIL
   resultcnt = (resultcnt+ 1)
  FOOT  elh.loc_facility_cd
   detailcnt = (reply->facilities[facilitycnt].positions[1].detail_cnt+ 1), reply->facilities[
   facilitycnt].positions[1].detail_cnt = detailcnt, stat = alterlist(reply->facilities[facilitycnt].
    positions[1].details,detailcnt),
   reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[1].details[detailcnt].detail_value_txt = trim(cnvtstring(
     resultcnt))
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
