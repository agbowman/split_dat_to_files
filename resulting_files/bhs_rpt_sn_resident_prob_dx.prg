CREATE PROGRAM bhs_rpt_sn_resident_prob_dx
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE bhsresident_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSRESIDENT")), protect
 DECLARE triage_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"TRIAGE")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs71_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")),
 protect
 DECLARE mf_cs319_mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_cs319_fin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_cs71_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE mf_cs71_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_cs71_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY")), protect
 SELECT INTO  $OUTDEV
  fin = substring(1,50,fin.alias), encntr_type_disp = uar_get_code_display(e.encntr_type_cd), problem
   = substring(1,50,n.source_string),
  problem_free_text = substring(1,50,p.problem_ftdesc), registration_date = e.reg_dt_tm
  "mm/dd/yyyy;;d", problem_update_date = p.updt_dt_tm"mm/dd/yyyy;;d",
  problem_updated_by_resident = substring(1,100,pr.name_full_formatted), problem_updated_by_position
   = substring(1,100,uar_get_code_display(pr.position_cd)), p.annotated_display,
  p.beg_effective_dt_tm, p.end_effective_dt_tm, p_confirmation_status_disp = uar_get_code_display(p
   .confirmation_status_cd),
  p_data_status_disp = uar_get_code_display(p.data_status_cd), p.data_status_dt_tm
  FROM problem p,
   encounter e,
   encntr_alias fin,
   prsnl pr,
   nomenclature n
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime("01-APR-2024 00:00:00") AND cnvtdatetime(
    "16-MAY-2024 23:59:59")
    AND e.encntr_type_cd IN (mf_cs71_daystay, mf_cs71_inpatient, mf_cs71_emergency,
   mf_cs71_observation)
    AND e.active_status_cd=188)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(p.updt_id))
    AND (pr.position_cd= Outerjoin(value(uar_get_code_by("DISPLAYKEY",88,"BHSRESIDENT")))) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(p.nomenclature_id)) )
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_status_cd=value(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
    AND fin.encntr_alias_type_cd=value(uar_get_code_by("MEANING",319,"FIN NBR"))
    AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND fin.active_ind=1)
  WITH maxrec = 10000, nocounter, time = 60,
   format, separator = " "
 ;end select
END GO
