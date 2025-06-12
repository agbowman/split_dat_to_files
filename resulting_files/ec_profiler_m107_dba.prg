CREATE PROGRAM ec_profiler_m107:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dverified = f8 WITH constant(uar_get_code_by("MEANING",1305,"VERIFIED"))
 DECLARE dcompleted = f8 WITH constant(uar_get_code_by("MEANING",1305,"COMPLETED"))
 DECLARE dperformed = f8 WITH constant(uar_get_code_by("MEANING",1305,"PERFORMED"))
 SELECT INTO "nl:"
  FROM pathology_case pc,
   case_report cr,
   encntr_loc_hist elh
  PLAN (cr
   WHERE cr.status_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND cr.status_cd IN (dverified, dcompleted, dperformed))
   JOIN (pc
   WHERE pc.case_id=cr.case_id)
   JOIN (elh
   WHERE elh.encntr_id=pc.encntr_id
    AND elh.beg_effective_dt_tm <= cr.status_dt_tm
    AND elh.end_effective_dt_tm >= cr.status_dt_tm)
  ORDER BY elh.loc_facility_cd
  HEAD elh.loc_facility_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd, reply->facilities[facilitycnt].
   position_cnt = 1, stat = alterlist(reply->facilities[facilitycnt].positions,1),
   reply->facilities[facilitycnt].positions[1].position_cd = 0.0, reply->facilities[facilitycnt].
   positions[1].capability_in_use_ind = 1, resultcnt = 0
  DETAIL
   resultcnt = (resultcnt+ 1)
  FOOT  elh.loc_facility_cd
   detailcnt = (reply->facilities[facilitycnt].positions[1].detail_cnt+ 1), reply->facilities[
   facilitycnt].positions[1].detail_cnt = detailcnt, stat = alterlist(reply->facilities[facilitycnt].
    positions[1].details,detailcnt),
   reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[1].details[detailcnt].detail_value_txt = trim(cnvtstring(
     resultcnt))
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
