CREATE PROGRAM bhs_rpt_dup_encntr_alias:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Lookback Days:" = 10
  WITH outdev, ml_lookback
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 SELECT DISTINCT INTO  $OUTDEV
  fin = ea1.alias, e.encntr_id, create_dt = format(e.create_dt_tm,";;q"),
  encntr_contrib_sys = uar_get_code_display(e.contributor_system_cd)
  FROM encntr_alias ea1,
   encounter e,
   encntr_alias ea2,
   encntr_alias ea3
  PLAN (ea1
   WHERE ea1.encntr_alias_type_cd=mf_fin_cd
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate)
   JOIN (e
   WHERE e.encntr_id=ea1.encntr_id
    AND e.active_ind=1)
   JOIN (ea2
   WHERE ea2.alias=ea1.alias
    AND ea2.active_ind=1
    AND ea2.encntr_alias_type_cd=mf_fin_cd
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_id != ea1.encntr_id)
   JOIN (ea3
   WHERE ea3.alias=ea1.alias
    AND ea3.beg_effective_dt_tm > cnvtdatetime((curdate -  $ML_LOOKBACK),0)
    AND ea3.active_ind=1
    AND ea3.end_effective_dt_tm > sysdate
    AND ea3.encntr_alias_type_cd=mf_fin_cd)
  ORDER BY ea1.alias, e.encntr_id
  WITH nocounter, separator = " ", skipreport = 1,
   format
 ;end select
#exit_script
END GO
