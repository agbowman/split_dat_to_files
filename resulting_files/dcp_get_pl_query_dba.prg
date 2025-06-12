CREATE PROGRAM dcp_get_pl_query:dba
 SET modify = predeclare
 DECLARE cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dcp_pl_query_list dpql,
   dcp_pl_custom_entry ce,
   encounter e,
   person p,
   dcp_pl_prioritization pr
  PLAN (dpql
   WHERE (dpql.patient_list_id=request->patient_list_id))
   JOIN (ce
   WHERE (ce.patient_list_id=request->patient_list_id))
   JOIN (p
   WHERE p.person_id=ce.person_id
    AND p.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND ((e.active_ind=1) OR (e.encntr_id=0)) )
   JOIN (pr
   WHERE pr.patient_list_id=outerjoin(request->patient_list_id)
    AND pr.person_id=outerjoin(p.person_id))
  HEAD REPORT
   cnt = 0, reply->execution_dt_tm = dpql.execution_dt_tm, reply->execution_status_cd = dpql
   .execution_status_cd
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->patients,(cnt+ 9))
   ENDIF
   reply->patients[cnt].person_id = ce.person_id, reply->patients[cnt].person_name = p
   .name_full_formatted, reply->patients[cnt].encntr_id = ce.encntr_id,
   reply->patients[cnt].priority = 0, reply->patients[cnt].active_ind = 1, reply->patients[cnt].
   organization_id = e.organization_id,
   reply->patients[cnt].confid_level_cd = e.confid_level_cd, reply->patients[cnt].confid_level =
   uar_get_collation_seq(e.confid_level_cd)
   IF ((reply->patients[cnt].confid_level < 0))
    reply->patients[cnt].confid_level = 0
   ENDIF
   reply->patients[cnt].priority = pr.priority, reply->patients[cnt].filter_ind = 0
  FOOT REPORT
   stat = alterlist(reply->patients,cnt)
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
