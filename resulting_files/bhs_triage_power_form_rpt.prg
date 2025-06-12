CREATE PROGRAM bhs_triage_power_form_rpt
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT DISTINCT INTO  $OUTDEV
  p.name_full_formatted, dfa.person_id, form_name = dfr.description,
  location_name = cv.display, status = cv2.display, dfa.form_dt_tm
  FROM dcp_forms_activity dfa,
   dcp_forms_ref dfr,
   clinical_event ce,
   encounter e,
   code_value cv,
   person p,
   code_value cv2
  PLAN (dfa
   WHERE dfa.dcp_forms_ref_id IN (173155721, 145121017, 145121667, 145121913)
    AND dfa.form_status_cd IN (25, 33, 35)
    AND dfa.form_dt_tm BETWEEN cnvtdatetime("09-JAN-2012 00:00:00") AND cnvtdatetime(
    "11-JAN-2012 23:59:59"))
   JOIN (dfr
   WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id)
   JOIN (ce
   WHERE dfa.encntr_id=ce.encntr_id
    AND ce.event_cd != 165604327
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (e
   WHERE dfa.encntr_id=e.encntr_id
    AND e.active_ind=1)
   JOIN (cv
   WHERE e.location_cd=cv.code_value
    AND cv.code_value=52914084)
   JOIN (p
   WHERE p.person_id=dfa.person_id)
   JOIN (cv2
   WHERE dfa.form_status_cd=cv2.code_value)
  ORDER BY p.name_full_formatted
  WITH nocounter, format
 ;end select
END GO
