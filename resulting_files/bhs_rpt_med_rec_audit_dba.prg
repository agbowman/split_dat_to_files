CREATE PROGRAM bhs_rpt_med_rec_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT DISTINCT INTO  $1
  reg_date = e.beg_effective_dt_tm, e.loc_facility_cd, facility = uar_get_code_display(e
   .loc_facility_cd),
  nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd), room = uar_get_code_display(e.loc_room_cd),
  bed = uar_get_code_display(e.loc_bed_cd),
  acct_nbr = ea.alias, e.encntr_id, compliance_done =
  IF (ordcomp.encntr_id > 0) "1"
  ELSE "0"
  ENDIF
  ,
  recon_done =
  IF (ordrecon.encntr_id > 0) "1"
  ELSE "0"
  ENDIF
  FROM encntr_domain e,
   order_recon ordrecon,
   order_compliance ordcomp,
   encntr_alias ea
  PLAN (e
   WHERE e.beg_effective_dt_tm <= sysdate
    AND e.end_effective_dt_tm > sysdate
    AND e.loc_facility_cd != 2583987.00
    AND e.loc_nurse_unit_cd > 0
    AND e.loc_bed_cd > 0
    AND  EXISTS (
   (SELECT
    en.encntr_id
    FROM encounter en
    WHERE en.encntr_id=e.encntr_id
     AND en.disch_dt_tm = null)))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=1077)
   JOIN (ordrecon
   WHERE ordrecon.encntr_id=outerjoin(e.encntr_id))
   JOIN (ordcomp
   WHERE ordcomp.encntr_id=outerjoin(e.encntr_id))
  ORDER BY e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_id,
   0
  WITH format, separator = " "
 ;end select
END GO
