CREATE PROGRAM ec_profiler_m72:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dendorse = f8 WITH constant(uar_get_code_by("MEANING",4001982,"ENDORSE"))
 DECLARE dpending = f8 WITH constant(uar_get_code_by("MEANING",4001983,"PENDING"))
 SELECT INTO "nl:"
  FROM ce_prcs_queue cep,
   ce_event_action cea,
   clinical_event ce,
   prsnl p
  PLAN (cep
   WHERE cep.queue_type_cd=dendorse
    AND cep.queue_status_cd=dpending
    AND cep.create_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm))
   JOIN (cea
   WHERE cep.ce_event_action_id=cea.ce_event_action_id)
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (p
   WHERE p.person_id=cea.assign_prsnl_id)
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
