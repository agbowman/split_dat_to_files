CREATE PROGRAM bhs_rpt_find_dtas_from_form:dba
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
   x = (x+ 1), stat = alterlist(forms->qual,x), forms->qual[x].event_id = ce.event_id
  WITH time = 600
 ;end select
 CALL echorecord(forms)
 SELECT INTO  $OUTDEV
  p.name_full_formatted, ea.alias, event_cd2 = uar_get_code_display(ce2.event_cd),
  ce2.event_tag, ce2.result_val, ce2.event_end_dt_tm,
  *
  FROM clinical_event ce,
   clinical_event ce2,
   person p,
   encntr_alias ea,
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
  WITH nocounter, format, format(date,";;q"),
   separator = " "
 ;end select
END GO
