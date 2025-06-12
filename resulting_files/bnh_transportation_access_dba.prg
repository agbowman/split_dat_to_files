CREATE PROGRAM bnh_transportation_access:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Hilltown zip codes (comma-separated)" = "",
  "Enter Greater Westfield zip codes (comma-separated)" = ""
  WITH outdev, hilltown_zips, westfield_zips
 SELECT DISTINCT INTO value( $OUTDEV)
  ce.reference_nbr, dfa.dcp_forms_activity_id, dfr.description,
  cv.display_key, cv.description, dfr.description
  FROM clinical_event ce,
   code_value cv,
   encounter e,
   encntr_alias ea,
   dcp_forms_activity dfa,
   dcp_forms_ref dfr
  PLAN (e
   WHERE e.loc_facility_cd=780848199.00
    AND  NOT (e.disch_disposition_cd IN (0.0, null))
    AND e.reg_dt_tm >= cnvtdatetime((curdate - 10),curtime3))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=value(uar_get_code_by("DISPLAYKEY",319,"FINNBR")))
   JOIN (dfa
   WHERE dfa.encntr_id=e.encntr_id
    AND dfa.active_ind=1)
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND dfr.beg_effective_dt_tm <= dfa.version_dt_tm
    AND dfr.end_effective_dt_tm > dfa.version_dt_tm)
   JOIN (ce
   WHERE ce.encntr_id=dfa.encntr_id
    AND cnvtreal(substring(1,(findstring(".00",ce.reference_nbr) - 1),ce.reference_nbr))=dfa
   .dcp_forms_activity_id
    AND ((ce.event_end_dt_tm >= cnvtdatetime((curdate - 17),curtime3)) OR (ce.event_end_dt_tm=null))
    AND ce.result_val != "")
   JOIN (cv
   WHERE cv.code_set=72
    AND cv.code_value=ce.event_cd
    AND cnvtupper(cv.display)="*TRANSPORTATION*"
    AND cv.code_value=ce.event_cd)
  WITH time = 60, uar_code(m,d)
 ;end select
END GO
