CREATE PROGRAM ec_profiler_m99:dba
 DECLARE manual_request = i4 WITH constant(1)
 DECLARE expedite_request = i4 WITH constant(2)
 DECLARE distribution_request = i4 WITH constant(3)
 DECLARE dsenttodmscd = f8 WITH constant(uar_get_code_by("MEANING",367571,"SENTTODMS"))
 DECLARE dpreviewedcd = f8 WITH constant(uar_get_code_by("MEANING",367571,"PREVIEWED"))
 DECLARE darchivedcd = f8 WITH constant(uar_get_code_by("MEANING",367571,"ARCHIVED"))
 DECLARE darchivednotdisplayed = f8 WITH constant(uar_get_code_by("MEANING",367571,"ARCHNOTDISP"))
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl:"
  FROM cr_report_request rr,
   encounter e,
   prsnl p
  PLAN (rr
   WHERE ((rr.report_request_id+ 0) > 0)
    AND rr.request_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND rr.report_status_cd IN (dsenttodmscd, dpreviewedcd, darchivedcd, darchivednotdisplayed))
   JOIN (e
   WHERE e.encntr_id=rr.encntr_id)
   JOIN (p
   WHERE p.person_id=rr.request_prsnl_id)
  ORDER BY e.loc_facility_cd, p.position_cd
  HEAD REPORT
   facilitycnt = 0
  HEAD e.loc_facility_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = e.loc_facility_cd, positioncnt = 0
  HEAD p.position_cd
   positioncnt = (positioncnt+ 1), reply->facilities[facilitycnt].position_cnt = positioncnt, stat =
   alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
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
