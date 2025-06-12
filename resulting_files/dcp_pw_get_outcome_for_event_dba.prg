CREATE PROGRAM dcp_pw_get_outcome_for_event:dba
 RECORD reply(
   1 event_list[*]
     2 event_cd = f8
     2 pathway_list[*]
       3 pathway_id = f8
       3 outcome_list[*]
         4 act_pw_comp_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET nbr_to_check = size(request->event_list,5)
 SET eventcnt = 0
 SET pathwaycnt = 0
 SELECT
  IF (nbr_to_check=0)INTO "nl:"
   apc.event_cd, apc.start_dt_tm, apc.end_dt_tm,
   apc.activated_ind, apc.active_ind
   FROM act_pw_comp apc
   WHERE (apc.person_id=request->person_id)
    AND apc.activated_ind=1
    AND apc.active_ind=1
   ORDER BY apc.event_cd
  ELSE INTO "nl:"
   apc.event_cd, apc.start_dt_tm, apc.end_dt_tm,
   apc.activated_ind, apc.active_ind
   FROM (dummyt d1  WITH seq = value(nbr_to_check)),
    act_pw_comp apc
   PLAN (d1)
    JOIN (apc
    WHERE (apc.person_id=request->person_id)
     AND (apc.event_cd=request->event_list[d1.seq].event_cd)
     AND apc.start_dt_tm <= cnvtdatetime(request->event_list[d1.seq].event_end_dt_tm)
     AND apc.end_dt_tm >= cnvtdatetime(request->event_list[d1.seq].event_end_dt_tm)
     AND apc.activated_ind=1
     AND apc.active_ind=1)
   ORDER BY apc.event_cd, apc.pathway_id
  ENDIF
  HEAD apc.event_cd
   eventcnt = (eventcnt+ 1)
   IF (eventcnt > size(reply->event_list,5))
    stat = alterlist(reply->event_list,(eventcnt+ 5))
   ENDIF
   reply->event_list[eventcnt].event_cd = apc.event_cd, pathwaycnt = 0
  HEAD apc.pathway_id
   pathwaycnt = (pathwaycnt+ 1)
   IF (pathwaycnt > size(reply->event_list[eventcnt].pathway_list,5))
    stat = alterlist(reply->event_list[eventcnt].pathway_list,(pathwaycnt+ 5))
   ENDIF
   reply->event_list[eventcnt].pathway_list[pathwaycnt].pathway_id = apc.pathway_id, outcomecnt = 0
  DETAIL
   outcomecnt = (outcomecnt+ 1)
   IF (outcomecnt > size(reply->event_list[eventcnt].pathway_list[pathwaycnt].outcome_list,5))
    stat = alterlist(reply->event_list[eventcnt].pathway_list[pathwaycnt].outcome_list,(outcomecnt+ 5
     ))
   ENDIF
   reply->event_list[eventcnt].pathway_list[pathwaycnt].outcome_list[outcomecnt].act_pw_comp_id = apc
   .act_pw_comp_id,
   CALL echo(build("EventCnt =",eventcnt,"OutcomeCnt =",outcomecnt))
  FOOT  apc.pathway_id
   CALL echo(build("FOOT: EventCnt =",eventcnt,"PathwayCnt",pathwaycnt,"OutcomeCnt =",
    outcomecnt)), stat = alterlist(reply->event_list[eventcnt].pathway_list[pathwaycnt].outcome_list,
    outcomecnt)
  FOOT  apc.event_cd
   stat = alterlist(reply->event_list[eventcnt].pathway_list,pathwaycnt)
  FOOT REPORT
   stat = alterlist(reply->event_list,eventcnt)
  WITH nocounter, orahint("index(acp xie13act_pw_comp)")
 ;end select
END GO
