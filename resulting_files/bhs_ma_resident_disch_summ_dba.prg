CREATE PROGRAM bhs_ma_resident_disch_summ:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Begin Date" = curdate,
  "Enter End Date" = curdate
  WITH outdev, date1, date2
 SET v_acct_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET v_mrn_cd = uar_get_code_by("MEANING",319,"MRN")
 SELECT INTO  $OUTDEV
  s.author_id, s.encounter_id, s.person_id,
  s_story_completion_status_disp = uar_get_code_display(s.story_completion_status_cd), s.title, s
  .updt_dt_tm,
  e.disch_dt_tm, e.encntr_id, provider = substring(1,30,p.name_full_formatted),
  p.person_id, patient = substring(1,30,pe.name_full_formatted), pe.person_id,
  mrn = substring(1,15,trim(ea.alias)), ea_encntr_alias_type_disp = uar_get_code_display(ea
   .encntr_alias_type_cd), discharge = e.disch_dt_tm,
  disch_summ_time = s.updt_dt_tm
  FROM scd_story s,
   encounter e,
   prsnl p,
   person pe,
   encntr_alias ea
  PLAN (s
   WHERE s.story_completion_status_cd=10396
    AND s.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate( $DATE1),0) AND cnvtdatetime(cnvtdate( $DATE2),
    235959)
    AND s.title="Physician Discharge Summary--BHS")
   JOIN (e
   WHERE e.encntr_id=s.encounter_id
    AND e.disch_dt_tm IS NOT null)
   JOIN (p
   WHERE p.person_id=s.author_id
    AND p.position_cd=925850)
   JOIN (pe
   WHERE pe.person_id=s.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id)
  ORDER BY p.name_full_formatted, patient
  HEAD PAGE
   col 5, "DISCHARGE SUMMARIES COMPLETED BY RESIDENTS", row + 1,
   col 5, curdate, curtime2,
   row + 1, col 5, "PAGE:",
   curpage"##;L", row + 1, col 5,
   "PHYSICIAN NAME", col 40, "PATIENT NAME",
   col 75, "DISCH DATE", col 90,
   "MRN", col 100, "ACCOUNT",
   row + 1, "DISCH_SUMM_TIME", row + 1
  HEAD patient
   mr = fillstring(15,""), acc = fillstring(15,""), col 5,
   provider, col 40, patient,
   col 75, discharge, row + 0
  DETAIL
   IF (ea.encntr_alias_type_cd=v_mrn_cd)
    mr = trim(ea.alias)
   ELSEIF (ea.encntr_alias_type_cd=v_acct_cd)
    acc = trim(ea.alias)
   ENDIF
  FOOT  patient
   col 90, mr, col 100,
   acc, row + 1
  WITH nocounter, maxcol = 130
 ;end select
END GO
