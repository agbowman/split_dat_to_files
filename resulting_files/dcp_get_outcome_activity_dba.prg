CREATE PROGRAM dcp_get_outcome_activity:dba
 RECORD reply(
   1 comp_list[*]
     2 act_pw_comp_id = f8
     2 event_list[*]
       3 event_end_dt_tm = dq8
       3 event_cd = f8
       3 event_class_cd = f8
       3 clinical_event_id = f8
       3 event_id = f8
       3 met_ind = i2
       3 notmet_ind = i2
       3 valid_until_dt_tm = dq8
       3 result_status_cd = f8
       3 event_tag = vc
       3 result_units_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET nbr_to_check = size(request->comp_list,5)
 SELECT INTO "nl:"
  otpx.reference_task_id, otpx.position_cd
  FROM (dummyt d1  WITH seq = value(nbr_to_check)),
   pw_outcome_activity poa,
   clinical_event ce
  PLAN (d1)
   JOIN (poa
   WHERE (poa.act_pw_comp_id=request->comp_list[d1.seq].act_pw_comp_id))
   JOIN (ce
   WHERE poa.event_id=ce.event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100  00:00"))
  ORDER BY poa.act_pw_comp_id
  HEAD REPORT
   compcnt = 0
  HEAD poa.act_pw_comp_id
   compcnt = (compcnt+ 1)
   IF (compcnt > size(reply->comp_list,5))
    stat = alterlist(reply->comp_list,(compcnt+ 5))
   ENDIF
   reply->comp_list[compcnt].act_pw_comp_id = poa.act_pw_comp_id, eventcnt = 0
  DETAIL
   eventcnt = (eventcnt+ 1)
   IF (eventcnt > size(reply->comp_list[compcnt].event_list,5))
    stat = alterlist(reply->comp_list[compcnt].event_list,(eventcnt+ 5))
   ENDIF
   reply->comp_list[compcnt].event_list[eventcnt].event_end_dt_tm = ce.event_end_dt_tm, reply->
   comp_list[compcnt].event_list[eventcnt].event_cd = ce.event_cd, reply->comp_list[compcnt].
   event_list[eventcnt].event_class_cd = ce.event_class_cd,
   reply->comp_list[compcnt].event_list[eventcnt].clinical_event_id = ce.clinical_event_id, reply->
   comp_list[compcnt].event_list[eventcnt].event_id = ce.event_id, reply->comp_list[compcnt].
   event_list[eventcnt].met_ind = poa.met_ind,
   reply->comp_list[compcnt].event_list[eventcnt].notmet_ind = poa.notmet_ind, reply->comp_list[
   compcnt].event_list[eventcnt].valid_until_dt_tm = ce.valid_until_dt_tm, reply->comp_list[compcnt].
   event_list[eventcnt].event_tag = ce.event_tag,
   reply->comp_list[compcnt].event_list[eventcnt].result_units_cd = ce.result_units_cd
  FOOT  poa.act_pw_comp_id
   stat = alterlist(reply->comp_list[compcnt].event_list,eventcnt)
  FOOT REPORT
   stat = alterlist(reply->comp_list,compcnt)
   FOR (x = 1 TO compcnt)
     CALL echo(build("x = ",x)),
     CALL echo(build("act_pw_comp_id = ",reply->comp_list[x].act_pw_comp_id)), eventcnt = size(reply
      ->comp_list[compcnt].event_list,5),
     CALL echo(build("EventCnt = ",eventcnt))
     FOR (y = 1 TO eventcnt)
       CALL echo(build("y = ",y)),
       CALL echo(build("event_id =",reply->comp_list[x].event_list[y].event_id)),
       CALL echo(build("clinical_event_id =",reply->comp_list[x].event_list[y].clinical_event_id)),
       CALL echo(build("valid_until_dt_tm=",reply->comp_list[x].event_list[y].valid_until_dt_tm))
     ENDFOR
   ENDFOR
 ;end select
END GO
