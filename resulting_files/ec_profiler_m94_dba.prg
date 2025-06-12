CREATE PROGRAM ec_profiler_m94:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE binstrumentimgind = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dtable d
  WHERE d.table_name="INSTRUMENT_IMAGE"
  DETAIL
   binstrumentimgind = 1
  WITH nocounter
 ;end select
 IF (binstrumentimgind=1)
  SELECT INTO "nl:"
   FROM order_action oa,
    orders o,
    result r,
    perform_result pr,
    instrument_image ii,
    encounter e,
    prsnl p
   PLAN (oa
    WHERE oa.action_sequence=1
     AND oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm))
    JOIN (o
    WHERE o.order_id=oa.order_id
     AND ((o.template_order_id+ 0)=0)
     AND o.current_start_dt_tm > cnvtdatetime(request->start_dt_tm))
    JOIN (r
    WHERE r.order_id=o.order_id)
    JOIN (pr
    WHERE pr.result_id=r.result_id
     AND pr.result_status_cd=r.result_status_cd)
    JOIN (ii
    WHERE ii.result_id=pr.result_id
     AND ii.repeat_nbr=pr.repeat_nbr
     AND ii.instrument_image_id > 0.0
     AND ii.result_image_name > " "
     AND ii.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (p
    WHERE p.person_id=oa.action_personnel_id)
   ORDER BY e.loc_facility_cd, p.position_cd, e.encntr_id
   HEAD e.loc_facility_cd
    facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
     ->facilities,facilitycnt),
    reply->facilities[facilitycnt].facility_cd = e.loc_facility_cd, positioncnt = 0
   HEAD p.position_cd
    positioncnt = (positioncnt+ 1), reply->facilities[facilitycnt].position_cnt = positioncnt, stat
     = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
    reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
    facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, encntrcnt = 0
   HEAD e.encntr_id
    encntrcnt = (encntrcnt+ 1)
   FOOT  p.position_cd
    detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
    facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
     facilities[facilitycnt].positions[positioncnt].details,detailcnt),
    reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "", reply
    ->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = trim(
     cnvtstring(encntrcnt))
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
