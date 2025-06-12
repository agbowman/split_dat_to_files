CREATE PROGRAM ec_profiler_m9:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl:"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   tracking_item ti,
   orders o,
   order_action oa,
   prsnl p,
   encounter e
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.cdf_meaning="ER")
   JOIN (tg
   WHERE tg.child_value=0
    AND tg.tracking_group_cd=cv.code_value)
   JOIN (tc
   WHERE tc.tracking_group_cd=tg.tracking_group_cd
    AND tc.checkin_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND tc.checkout_dt_tm >= cnvtdatetime(request->start_dt_tm))
   JOIN (ti
   WHERE ti.tracking_id=tc.tracking_id)
   JOIN (o
   WHERE o.person_id=ti.person_id
    AND o.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->stop_dt_tm)
    AND ((o.encntr_id+ 0)=ti.encntr_id)
    AND ((o.template_order_id+ 0)=0.0)
    AND o.orig_ord_as_flag=1)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1
    AND oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND oa.action_dt_tm BETWEEN tc.checkin_dt_tm AND tc.checkout_dt_tm)
   JOIN (p
   WHERE p.person_id=oa.action_personnel_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
  ORDER BY e.loc_facility_cd, p.position_cd, o.order_id
  HEAD e.loc_facility_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = e.loc_facility_cd
  HEAD p.position_cd
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, ordercnt = 0
  HEAD o.order_id
   ordercnt = (ordercnt+ 1)
  FOOT  p.position_cd
   detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
   facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
    facilities[facilitycnt].positions[positioncnt].details,detailcnt),
   reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = trim(
    cnvtstring(ordercnt))
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
