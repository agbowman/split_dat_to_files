CREATE PROGRAM ec_profiler_m17:dba
 SELECT INTO "nl"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   tracking_item ti,
   allergy a,
   prsnl p,
   encounter e
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.cdf_meaning="ER")
   JOIN (tg
   WHERE tg.child_value=0
    AND (tg.tracking_group_cd=(cv.code_value+ 0)))
   JOIN (tc
   WHERE tc.tracking_group_cd=tg.tracking_group_cd
    AND tc.checkin_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND tc.checkout_dt_tm >= cnvtdatetime(request->start_dt_tm))
   JOIN (ti
   WHERE (ti.tracking_id=(tc.tracking_id+ 0)))
   JOIN (a
   WHERE (a.encntr_id=(ti.encntr_id+ 0))
    AND a.created_dt_tm >= tc.checkin_dt_tm
    AND a.created_dt_tm >= cnvtdatetime(request->start_dt_tm)
    AND a.created_dt_tm <= tc.checkout_dt_tm
    AND a.created_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND a.updt_dt_tm >= cnvtdatetime(request->start_dt_tm))
   JOIN (e
   WHERE e.encntr_id=a.encntr_id)
   JOIN (p
   WHERE p.person_id=a.created_prsnl_id)
  ORDER BY e.loc_facility_cd, p.position_cd, e.encntr_id
  HEAD e.loc_facility_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = e.loc_facility_cd
  HEAD p.position_cd
   encntrcnt = 0, positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[
   facilitycnt].position_cnt = positioncnt,
   stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt), reply->facilities[
   facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->facilities[facilitycnt].
   positions[positioncnt].capability_in_use_ind = 1
  HEAD e.encntr_id
   encntrcnt = (encntrcnt+ 1)
  FOOT  p.position_cd
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
