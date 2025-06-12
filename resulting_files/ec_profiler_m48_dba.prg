CREATE PROGRAM ec_profiler_m48:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dfacitlitycd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE dbuildingcd = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 SELECT INTO "nl:"
  FROM surgical_case sc,
   sn_case_tracking sct,
   tracking_item ti,
   tracking_checkin tc,
   track_group tg,
   location_group lg1,
   location_group lg2
  PLAN (tc
   WHERE tc.checkin_dt_tm <= cnvtdatetime(request->start_dt_tm)
    AND tc.checkout_dt_tm >= cnvtdatetime(request->stop_dt_tm)
    AND ((tc.tracking_id+ 0) > 0.0))
   JOIN (ti
   WHERE (ti.tracking_id=(tc.tracking_id+ 0))
    AND trim(ti.parent_entity_name)="SURGICAL_CASE"
    AND ((ti.parent_entity_id+ 0) > 0.0)
    AND ti.end_tracking_dt_tm=null
    AND ti.active_ind=1)
   JOIN (sc
   WHERE (sc.surg_case_id=(ti.parent_entity_id+ 0))
    AND sc.checkin_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm))
   JOIN (sct
   WHERE sct.surg_case_id=sc.surg_case_id)
   JOIN (tg
   WHERE tg.tracking_group_cd=tc.tracking_group_cd
    AND tg.child_value=0)
   JOIN (lg1
   WHERE (lg1.child_loc_cd=(tg.parent_value+ 0))
    AND lg1.location_group_type_cd=dbuildingcd
    AND ((lg1.root_loc_cd+ 0)=0)
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.location_group_type_cd=dfacitlitycd
    AND ((lg2.root_loc_cd+ 0)=0)
    AND lg2.active_ind=1)
  ORDER BY lg2.parent_loc_cd, sct.surg_case_id
  HEAD lg2.parent_loc_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = lg2.parent_loc_cd, reply->facilities[facilitycnt].
   position_cnt = 1, stat = alterlist(reply->facilities[facilitycnt].positions,1),
   reply->facilities[facilitycnt].positions[1].position_cd = 0.0, reply->facilities[facilitycnt].
   positions[1].capability_in_use_ind = 1, casecnt = 0
  HEAD sct.surg_case_id
   casecnt = (casecnt+ 1)
  FOOT  lg2.parent_loc_cd
   detailcnt = (reply->facilities[facilitycnt].positions[1].detail_cnt+ 1), reply->facilities[
   facilitycnt].positions[1].detail_cnt = detailcnt, stat = alterlist(reply->facilities[facilitycnt].
    positions[1].details,detailcnt),
   reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[1].details[detailcnt].detail_value_txt = trim(cnvtstring(casecnt
     ))
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
