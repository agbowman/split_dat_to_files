CREATE PROGRAM edw_evnt_mod:dba
 DECLARE ieventmodifiercount = i4 WITH protect, noconstant(0)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 SELECT INTO value(evnt_mod_extractfile)
  n_group_seq = nullind(pm.group_seq), n_sequence = nullind(pm.sequence), n_active_ind = nullind(pm
   .active_ind)
  FROM proc_modifier pm
  WHERE pm.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   col 0, health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(pm.proc_modifier_id,16))), v_bar,
   CALL print(trim(evaluate(n_group_seq,0,build(pm.group_seq),blank_field))),
   v_bar,
   CALL print(trim(cnvtstring(pm.nomenclature_id,16))), v_bar,
   CALL print(trim(cnvtstring(pm.parent_entity_id,16))), v_bar
   CASE (pm.parent_entity_name)
    OF "PROCEDURE":
     "WH_CLN_PROCEDURE"
    OF "DIAGNOSIS":
     "WH_CLN_DIAGNOSIS"
    OF "PROBLEM":
     "WH_CLN_PROBLEM_INST_REF"
   ENDCASE
   v_bar,
   CALL print(trim(evaluate(n_sequence,0,build(pm.sequence),blank_field))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,pm.beg_effective_dt_tm,0,cnvtdatetimeutc(pm
       .beg_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(historic_ind,"Y","1","0")),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, v_bar,
   v_bar,
   CALL print(evaluate(n_active_ind,0,build(pm.active_ind)," ")), v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1
 ;end select
 SET ieventmodifiercount = curqual
 SELECT INTO value(evnt_mod_extractfile)
  n_active_ind = nullind(scpm.active_ind)
  FROM surg_case_proc_modifier scpm,
   code_value cv
  PLAN (scpm
   WHERE scpm.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
   JOIN (cv
   WHERE cv.code_value=scpm.modifier_cd
    AND cv.code_value > 0)
  DETAIL
   col 0, health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(scpm.surg_case_proc_mod_id,16))), v_bar, v_bar,
   v_bar,
   CALL print(trim(cnvtstring(scpm.surg_case_proc_id,16))), v_bar,
   "WH_CLN_SURG_CASE_PROC", v_bar,
   CALL print(trim(cnvtstring(scpm.modifier_seq))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,scpm.beg_effective_dt_tm,0,cnvtdatetimeutc(
       scpm.beg_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(historic_ind,"Y","1","0")), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(cv.code_set))), v_bar,
   CALL print(trim(cnvtstring(scpm.modifier_cd,16))),
   v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(scpm.active_ind)," "))), v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET ieventmodifiercount = (ieventmodifiercount+ curqual)
 CALL echo(build("EVNT_MOD Count = ",ieventmodifiercount))
 CALL edwupdatescriptstatus("EVNT_MOD",ieventmodifiercount,"5","5")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "005 05/29/07 JW014069"
END GO
