CREATE PROGRAM bhs_encounter_combine
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start_dt_tm" = "SYSDATE",
  "end_dt_tm" = "SYSDATE"
  WITH outdev, start_dt_tm, end_dt_tm
 SELECT DISTINCT INTO  $OUTDEV
  pr.username, pr.name_full_formatted, p.name_last_key,
  ea.alias
  FROM encntr_combine ec,
   prsnl pr,
   encntr_alias ea,
   encounter e,
   person_alias pa,
   person p
  PLAN (ec
   WHERE ec.updt_dt_tm BETWEEN cnvtdatetime( $START_DT_TM) AND cnvtdatetime( $END_DT_TM)
    AND ec.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=ec.updt_id)
   JOIN (ea
   WHERE ea.encntr_id=ec.to_encntr_id)
   JOIN (e
   WHERE e.encntr_id=ec.from_encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=10.00)
 ;end select
END GO
