CREATE PROGRAM ec_profiler_m92:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE bradencpathrind = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dtable d
  WHERE d.table_name="RAD_ENCNTR_PATH_R"
  DETAIL
   bradencpathrind = 1
  WITH nocounter
 ;end select
 IF (bradencpathrind=1)
  SELECT INTO "nl:"
   FROM order_radiology o,
    rad_encntr_path_r rep,
    encounter e,
    prsnl p
   PLAN (o
    WHERE o.complete_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm))
    JOIN (rep
    WHERE rep.catalog_cd=o.catalog_cd)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (p
    WHERE p.person_id=o.order_physician_id)
   ORDER BY e.loc_facility_cd, p.position_cd, e.encntr_id
   HEAD e.loc_facility_cd
    facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
     ->facilities,facilitycnt),
    reply->facilities[facilitycnt].facility_cd = e.loc_facility_cd
   HEAD p.position_cd
    positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
    position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt
     ),
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
