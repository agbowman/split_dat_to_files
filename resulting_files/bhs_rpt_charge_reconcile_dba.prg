CREATE PROGRAM bhs_rpt_charge_reconcile:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Form Name(s):" = "",
  "DTA Event Code(s):" = 0,
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, formname, dtacd,
  begindate, enddate
 FREE RECORD forms
 RECORD forms(
   1 qual[*]
     2 event_id = f8
     2 encounter_id = f8
     2 plan_name = vc
     2 org_name = vc
 )
 SET x = 0
 SELECT INTO "NL:"
  ce.event_id, *
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   dcp_forms_activity_comp dcpc,
   clinical_event ce
  PLAN (dfr
   WHERE dfr.description IN ( $FORMNAME)
    AND dfr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (dfa
   WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.active_ind=1
    AND ((dfa.updt_dt_tm+ 0) >= cnvtdatetime( $BEGINDATE)))
   JOIN (dcpc
   WHERE dcpc.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND dcpc.parent_entity_name="CLINICAL_EVENT")
   JOIN (ce
   WHERE ce.event_id=dcpc.parent_entity_id
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime( $BEGINDATE) AND cnvtdatetime( $ENDDATE)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ((ce.result_status_cd+ 0) IN (25.00, 614349.00, 27.00, 35.00, 38.00,
   703418.00)))
  ORDER BY ce.event_id
  HEAD ce.event_id
   x = (x+ 1), stat = alterlist(forms->qual,x), forms->qual[x].event_id = ce.event_id,
   forms->qual[x].encounter_id = ce.encntr_id
  WITH time = 600
 ;end select
 CALL echorecord(forms)
 CALL echo("get insurance info")
 SELECT INTO "nl:"
  FROM encntr_plan_reltn e,
   person pe,
   person_alias pa,
   health_plan h,
   organization org,
   (dummyt d  WITH seq = value(size(forms->qual,5)))
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=forms->qual[d.seq].encounter_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (pe
   WHERE pe.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=outerjoin(e.person_id)
    AND pa.person_alias_type_cd=outerjoin(18)
    AND pa.active_ind=outerjoin(1))
   JOIN (h
   WHERE h.health_plan_id=e.health_plan_id
    AND h.active_ind=1)
   JOIN (org
   WHERE org.organization_id=outerjoin(e.organization_id))
  ORDER BY e.encntr_plan_reltn_id
  DETAIL
   forms->qual[d.seq].plan_name = h.plan_name, forms->qual[d.seq].org_name = org.org_name
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  p.name_full_formatted, ea.alias, event_cd2 = uar_get_code_display(ce2.event_cd),
  ce2.result_val, plan_name = forms->qual[d.seq].plan_name, org_name = forms->qual[d.seq].org_name,
  encounter_id = forms->qual[d.seq].encounter_id, ce2.event_end_dt_tm, h.plan_name,
  h.plan_desc, org.org_name, *
  FROM clinical_event ce,
   clinical_event ce2,
   person p,
   encntr_alias ea,
   encntr_plan_reltn e,
   health_plan h,
   organization org,
   (dummyt d  WITH seq = x)
  PLAN (d)
   JOIN (ce
   WHERE (ce.parent_event_id=forms->qual[d.seq].event_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ((ce.result_status_cd+ 0) IN (25.00, 614349.00, 27.00, 35.00, 38.00,
   703418.00)))
   JOIN (ce2
   WHERE ce2.parent_event_id=ce.event_id
    AND ce2.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ((ce2.result_status_cd+ 0) IN (25.00, 614349.00, 27.00, 35.00, 38.00,
   703418.00))
    AND ((ce2.event_cd+ 0) IN ( $DTACD)))
   JOIN (p
   WHERE p.person_id=ce.person_id)
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.encntr_alias_type_cd=1077.00)
   JOIN (e
   WHERE e.encntr_id=62379365.00
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND e.priority_seq=1)
   JOIN (h
   WHERE h.health_plan_id=e.health_plan_id
    AND h.active_ind=1)
   JOIN (org
   WHERE org.organization_id=outerjoin(e.organization_id))
  WITH nocounter, format, format(date,";;q"),
   separator = " "
 ;end select
END GO
