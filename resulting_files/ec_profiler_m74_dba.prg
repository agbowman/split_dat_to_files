CREATE PROGRAM ec_profiler_m74:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dpharmacy = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 SELECT INTO "nl:"
  pharmind =
  IF (o.catalog_type_cd=dpharmacy) 1
  ELSE 0
  ENDIF
  FROM order_notification n,
   orders o,
   prsnl p
  PLAN (n
   WHERE n.caused_by_flag=0
    AND n.notification_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm))
   JOIN (o
   WHERE o.order_id=n.order_id
    AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm)))
   JOIN (p
   WHERE p.person_id=n.to_prsnl_id)
  ORDER BY p.position_cd, pharmind
  HEAD REPORT
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = 0.0
  HEAD p.position_cd
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
  HEAD pharmind
   actioncnt = 0
  DETAIL
   actioncnt = (actioncnt+ 1)
  FOOT  pharmind
   detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
   facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
    facilities[facilitycnt].positions[positioncnt].details,detailcnt)
   IF (pharmind)
    reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "Pharmacy"
   ELSE
    reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "Other"
   ENDIF
   reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = trim(
    cnvtstring(actioncnt))
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
