CREATE PROGRAM ec_profiler_m73:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dpending = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE dopened = f8 WITH constant(uar_get_code_by("MEANING",79,"OPENED"))
 DECLARE drevrslt = f8 WITH constant(uar_get_code_by("MEANING",6027,"REVIEW RESUL"))
 DECLARE dsavedoc = f8 WITH constant(uar_get_code_by("MEANING",6027,"SAVED DOC"))
 DECLARE dnewrslt = f8 WITH constant(uar_get_code_by("MEANING",6027,"NEW RESULT"))
 DECLARE dendorse = f8 WITH constant(uar_get_code_by("MEANING",6026,"ENDORSE"))
 DECLARE ddoc = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE dgrpdoc = f8 WITH constant(uar_get_code_by("MEANING",53,"GRPDOC"))
 DECLARE dmdoc = f8 WITH constant(uar_get_code_by("MEANING",53,"MDOC"))
 SELECT INTO "nl:"
  FROM task_activity ta,
   task_activity_assignment taa,
   prsnl p
  PLAN (taa
   WHERE taa.assign_person_id > 0.0
    AND taa.updt_dt_tm >= cnvtdatetime(request->start_dt_tm)
    AND taa.updt_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND taa.task_status_cd IN (dpending, dopened)
    AND taa.active_ind=1)
   JOIN (ta
   WHERE ta.task_id=taa.task_id
    AND ta.task_activity_cd IN (drevrslt, dsavedoc, dnewrslt)
    AND ((ta.task_type_cd+ 0)=dendorse)
    AND ta.event_class_cd IN (ddoc, dgrpdoc, dmdoc)
    AND ta.active_ind=1)
   JOIN (p
   WHERE p.person_id=taa.assign_prsnl_id)
  ORDER BY p.position_cd
  HEAD REPORT
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = 0.0
  HEAD p.position_cd
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, actioncnt = 0
  DETAIL
   actioncnt = (actioncnt+ 1)
  FOOT  p.position_cd
   detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
   facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
    facilities[facilitycnt].positions[positioncnt].details,detailcnt),
   reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "", reply->
   facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = trim(
    cnvtstring(actioncnt))
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
