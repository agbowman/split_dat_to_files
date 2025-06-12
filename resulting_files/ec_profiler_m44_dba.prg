CREATE PROGRAM ec_profiler_m44:dba
 DECLARE dpowernote_cd = f8 WITH constant(uar_get_code_by("MEANING",29520,"POWERNOTE"))
 DECLARE dipencclass = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE signed_var = f8 WITH constant(uar_get_code_by("MEANING",15570,"SIGNED"))
 FREE RECORD ipenctypes
 RECORD ipenctypes(
   1 qual[*]
     2 encntr_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value_group cvg,
   code_value cv
  PLAN (cvg
   WHERE cvg.parent_code_value=dipencclass)
   JOIN (cv
   WHERE cv.code_value=cvg.child_code_value
    AND cv.code_set=71
    AND cv.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ipenctypes->qual,(cnt+ 9))
   ENDIF
   ipenctypes->qual[cnt].encntr_type_cd = cvg.child_code_value
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl"
   FROM scd_story ss,
    scd_story_pattern ssp,
    scr_pattern sp,
    encntr_loc_hist elh,
    prsnl p
   PLAN (ss
    WHERE ss.entry_mode_cd=dpowernote_cd
     AND ss.story_completion_status_cd=signed_var
     AND ss.active_status_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm))
    JOIN (ssp
    WHERE ssp.scd_story_id=ss.scd_story_id)
    JOIN (sp
    WHERE sp.scr_pattern_id=ssp.scr_pattern_id)
    JOIN (elh
    WHERE elh.encntr_id=ss.encounter_id
     AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
     AND expand(idx,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx].
     encntr_type_cd)
     AND elh.active_ind=1
     AND ss.active_status_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
    JOIN (p
    WHERE p.person_id=ss.author_id)
   ORDER BY elh.loc_facility_cd, p.position_cd, sp.scr_pattern_id
   HEAD REPORT
    facilitycnt = 0
   HEAD elh.loc_facility_cd
    positioncnt = 0, facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt,
    stat = alterlist(reply->facilities,facilitycnt), reply->facilities[facilitycnt].facility_cd = elh
    .loc_facility_cd
   HEAD p.position_cd
    positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
    position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt
     ),
    reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
    facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
   HEAD sp.scr_pattern_id
    powernotecnt = 0, detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+
    1), reply->facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt,
    stat = alterlist(reply->facilities[facilitycnt].positions[positioncnt].details,detailcnt)
   DETAIL
    powernotecnt = (powernotecnt+ 1)
   FOOT  sp.scr_pattern_id
    reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = sp.display,
    reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt =
    cnvtstring(powernotecnt)
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
