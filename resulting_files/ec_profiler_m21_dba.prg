CREATE PROGRAM ec_profiler_m21:dba
 SET powernote_ed_var = uar_get_code_by("MEANING",29520,"POWERNOTEED")
 SET signed_var = uar_get_code_by("MEANING",15570,"SIGNED")
 SELECT INTO "nl"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   tracking_item ti,
   scd_story ss
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
   JOIN (ss
   WHERE ss.encounter_id=ti.encntr_id
    AND ss.entry_mode_cd=powernote_ed_var
    AND ss.story_completion_status_cd=signed_var
    AND ss.active_status_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND ss.active_status_dt_tm BETWEEN tc.checkin_dt_tm AND tc.checkout_dt_tm)
  HEAD REPORT
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = 0.0
  DETAIL
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = 0.0, reply->facilities[
   facilitycnt].positions[positioncnt].capability_in_use_ind = 1
  WITH nocounter, maxrec = 1
 ;end select
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
