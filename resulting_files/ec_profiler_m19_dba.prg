CREATE PROGRAM ec_profiler_m19:dba
 DECLARE dauthcd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE dfacilitycd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE dbuildingcd = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 SELECT INTO "nl"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   tracking_item ti,
   location_group lg1,
   location_group lg2,
   dcp_forms_activity dfa,
   dcp_forms_ref dfr
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.cdf_meaning="ER")
   JOIN (tg
   WHERE tg.tracking_group_cd=cv.code_value
    AND tg.child_table="TRACK_ASSOC")
   JOIN (tc
   WHERE tc.tracking_group_cd=tg.tracking_group_cd
    AND tc.checkin_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND tc.checkout_dt_tm >= cnvtdatetime(request->start_dt_tm))
   JOIN (ti
   WHERE ti.tracking_id=tc.tracking_id)
   JOIN (lg1
   WHERE lg1.child_loc_cd=tg.parent_value
    AND lg1.location_group_type_cd=dbuildingcd
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.location_group_type_cd=dfacilitycd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (dfa
   WHERE dfa.person_id=ti.person_id
    AND dfa.last_activity_dt_tm >= cnvtdatetime(request->start_dt_tm)
    AND dfa.form_status_cd=dauthcd
    AND ((dfa.encntr_id+ 0)=ti.encntr_id)
    AND dfa.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm))
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND dfr.active_ind=1)
  ORDER BY lg2.parent_loc_cd, dfr.dcp_forms_ref_id, dfa.dcp_forms_activity_id
  HEAD REPORT
   faciltycnt = 0
  HEAD lg2.parent_loc_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = lg2.parent_loc_cd, positioncnt = (reply->facilities[
   facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].position_cnt = positioncnt,
   stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt), reply->facilities[
   facilitycnt].positions[positioncnt].position_cd = 0.0, reply->facilities[facilitycnt].positions[
   positioncnt].capability_in_use_ind = 1
  HEAD dfr.dcp_forms_ref_id
   formscnt = 0, detailcnt = (reply->facilities[facilitycnt].positions[1].detail_cnt+ 1), reply->
   facilities[facilitycnt].positions[1].detail_cnt = detailcnt,
   stat = alterlist(reply->facilities[facilitycnt].positions[1].details,detailcnt)
  HEAD dfa.dcp_forms_activity_id
   formscnt = (formscnt+ 1)
  FOOT  dfr.dcp_forms_ref_id
   reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_name = dfr.definition, reply
   ->facilities[facilitycnt].positions[1].details[detailcnt].detail_value_txt = cnvtstring(formscnt)
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
