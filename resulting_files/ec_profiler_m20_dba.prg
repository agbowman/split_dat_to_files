CREATE PROGRAM ec_profiler_m20:dba
 DECLARE dfacilitycd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE dbuildingcd = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE dsignedvar = f8 WITH constant(uar_get_code_by("MEANING",15570,"SIGNED"))
 SELECT INTO "nl"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   tracking_item ti,
   location_group lg1,
   location_group lg2,
   scd_story ss,
   scd_story_pattern ssp,
   scr_pattern sp,
   prsnl p
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
   WHERE (lg1.child_loc_cd=(tg.parent_value+ 0))
    AND lg1.location_group_type_cd=dbuildingcd
    AND ((lg1.root_loc_cd+ 0)=0)
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.location_group_type_cd=dfacilitycd
    AND ((lg2.root_loc_cd+ 0)=0)
    AND lg2.active_ind=1)
   JOIN (ss
   WHERE ss.encounter_id=ti.encntr_id
    AND ss.story_completion_status_cd=dsignedvar
    AND ss.active_status_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND ss.active_status_dt_tm BETWEEN tc.checkin_dt_tm AND tc.checkout_dt_tm)
   JOIN (ssp
   WHERE ssp.scd_story_id=ss.scd_story_id)
   JOIN (sp
   WHERE sp.scr_pattern_id=ssp.scr_pattern_id)
   JOIN (p
   WHERE p.person_id=ss.author_id)
  ORDER BY lg2.parent_loc_cd, p.position_cd, sp.scr_pattern_id
  HEAD REPORT
   facilitycnt = 0
  HEAD lg2.parent_loc_cd
   positioncnt = 0, facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt,
   stat = alterlist(reply->facilities,facilitycnt), reply->facilities[facilitycnt].facility_cd = lg2
   .parent_loc_cd
  HEAD p.position_cd
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
  HEAD sp.scr_pattern_id
   powernotecnt = 0, detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1
   ), reply->facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt,
   stat = alterlist(reply->facilities[facilitycnt].positions[positioncnt].details,detailcnt)
  DETAIL
   powernotecnt = (powernotecnt+ 1)
  FOOT  sp.scr_pattern_id
   reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = sp.display,
   reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt =
   cnvtstring(powernotecnt)
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
