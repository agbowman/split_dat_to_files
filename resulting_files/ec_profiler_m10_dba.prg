CREATE PROGRAM ec_profiler_m10:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dbuilding = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE dfacility = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 SELECT INTO "nl:"
  FROM surgical_case sc,
   sch_appt sa,
   location_group lg,
   location_group lg2
  PLAN (sc
   WHERE ((sc.sch_event_id+ 0) > 0.0)
    AND ((sc.cancel_reason_cd+ 0)=0.0)
    AND sc.create_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND sc.surg_start_dt_tm >= cnvtdatetime(request->start_dt_tm))
   JOIN (sa
   WHERE sa.sch_event_id=sc.sch_event_id)
   JOIN (lg
   WHERE (lg.child_loc_cd=(sa.appt_location_cd+ 0))
    AND ((lg.root_loc_cd+ 0)=0.0)
    AND lg.location_group_type_cd=dbuilding
    AND lg.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg.parent_loc_cd
    AND ((lg2.root_loc_cd+ 0)=0.0)
    AND lg2.location_group_type_cd=dfacility
    AND lg2.active_ind=1)
  ORDER BY lg2.parent_loc_cd
  HEAD REPORT
   facilitycnt = 0
  HEAD lg2.parent_loc_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = lg2.parent_loc_cd, reply->facilities[facilitycnt].
   position_cnt = 1, stat = alterlist(reply->facilities[facilitycnt].positions,1),
   reply->facilities[facilitycnt].positions[1].position_cd = 0.0, reply->facilities[facilitycnt].
   positions[1].capability_in_use_ind = 1, detailcnt = 0,
   apptcnt = 0
  DETAIL
   apptcnt = (apptcnt+ 1)
  FOOT  lg2.parent_loc_cd
   detailcnt = (reply->facilities[facilitycnt].positions[1].detail_cnt+ 1), reply->facilities[
   facilitycnt].positions[1].detail_cnt = detailcnt, stat = alterlist(reply->facilities[facilitycnt].
    positions[1].details,detailcnt),
   reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[1].details[detailcnt].detail_value_txt = trim(cnvtstring(apptcnt
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
