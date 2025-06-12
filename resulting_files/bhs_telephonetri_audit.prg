CREATE PROGRAM bhs_telephonetri_audit
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Begin Date" = "",
  "Enter End Date" = ""
  WITH outdev, beg_date, end_date
 SELECT INTO  $OUTDEV
  dfr.description, nurse_unit = substring(11,20,ea.alias), dfa.flags
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   encounter e,
   encntr_alias ea
  PLAN (dfr
   WHERE dfr.description IN ("Patient Medical Care - Triage", "Prescription Refill - Triage",
   "Referral Request - Triage", "Telephone Triage Form")
    AND dfr.active_ind=1)
   JOIN (dfa
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND dfa.version_dt_tm BETWEEN cnvtdatetime( $BEG_DATE) AND cnvtdatetime( $END_DATE))
   JOIN (e
   WHERE dfa.encntr_id=e.encntr_id)
   JOIN (ea
   WHERE e.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=value(uar_get_code_by("MEANING",319,"FIN NBR"))
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY dfr.description, nurse_unit, dfa.flags
  HEAD REPORT
   inerror_cnt = 0, incomplete_cnt = 0, complete_cnt = 0,
   col 0,
   CALL print(build2("Telephone Triage Usage Audit for ", $BEG_DATE," thru ", $END_DATE)), row + 1,
   col 0, " ", row + 1,
   col 0, "DESCRIPTION", col 201,
   "NURSE_UNIT", col 252, "INERROR",
   col 265, "INCOMPLETE", col 278,
   "COMPLETE"
  HEAD nurse_unit
   inerror_cnt = 0, incomplete_cnt = 0, complete_cnt = 0
  DETAIL
   CASE (dfa.flags)
    OF 0:
     inerror_cnt = (inerror_cnt+ 1)
    OF 1:
     incomplete_cnt = (incomplete_cnt+ 1)
    OF 2:
     complete_cnt = (complete_cnt+ 1)
   ENDCASE
  FOOT  nurse_unit
   row + 1, col 0, dfr.description,
   col 201, nurse_unit, col 252,
   inerror_cnt, col 265, incomplete_cnt,
   col 278, complete_cnt
  WITH maxcol = 300, maxrow = 1, nocounter,
   formfeed = none, nullreport
 ;end select
END GO
