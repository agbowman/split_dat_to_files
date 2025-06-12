CREATE PROGRAM cpmnotify_dcp_sched_events:dba
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
     2 datalist[*]
       3 sch_appt_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->overlay_ind = 1
 SET start_dt_tm = cnvtdatetime(curdate,0)
 DECLARE req_cnt = i4 WITH public, constant(size(request->entity_list,5))
 DECLARE rep_cnt = i4 WITH public, noconstant(0)
 SET code_value = 0.0
 SET code_set = 0
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 SELECT INTO "nl:"
  sa.sch_appt_id
  FROM (dummyt d  WITH seq = value(req_cnt)),
   sch_appt sa
  PLAN (d)
   JOIN (sa
   WHERE (sa.person_id=request->entity_list[d.seq].entity_id)
    AND sa.end_dt_tm >= cnvtdatetime(start_dt_tm)
    AND sa.active_ind=1
    AND sa.role_meaning="PATIENT"
    AND sa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND sa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq
  HEAD d.seq
   rep_cnt = (rep_cnt+ 1), stat = alterlist(reply->entity_list,rep_cnt), reply->entity_list[rep_cnt].
   entity_id = request->entity_list[rep_cnt].entity_id,
   stat = alterlist(reply->entity_list[rep_cnt].datalist,1), reply->entity_list[rep_cnt].datalist[1].
   sch_appt_ind = 0
  DETAIL
   IF (sa.sch_appt_id > 0)
    reply->entity_list[rep_cnt].datalist[1].sch_appt_ind = 1
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (rep_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
