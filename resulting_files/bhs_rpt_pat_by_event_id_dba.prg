CREATE PROGRAM bhs_rpt_pat_by_event_id:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Event ID:" = 0
  WITH outdev, f_event_id
 DECLARE mf_event_id = f8 WITH protect, constant(cnvtreal( $F_EVENT_ID))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT DISTINCT INTO value( $OUTDEV)
  ce.event_id, p.name_full_formatted, e.encntr_id,
  fin = ea1.alias, mrn = ea2.alias
  FROM clinical_event ce,
   encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (ce
   WHERE ce.event_id=mf_event_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.active_ind=1
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.active_ind=1
    AND ea2.encntr_alias_type_cd=mf_mrn_cd)
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
END GO
