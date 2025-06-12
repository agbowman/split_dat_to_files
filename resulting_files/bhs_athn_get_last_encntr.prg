CREATE PROGRAM bhs_athn_get_last_encntr
 RECORD out_rec(
   1 encntr_reg_date = dq8
   1 encntr_disch_date = dq8
   1 encntr_type = vc
   1 encntr_location = vc
   1 fin = vc
 )
 DECLARE fin_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea
  PLAN (e
   WHERE (e.person_id= $2)
    AND e.disch_dt_tm IS NOT null
    AND e.reg_dt_tm IS NOT null
    AND e.encntr_type_cd > 0)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.end_effective_dt_tm > sysdate
    AND ea.active_ind=1)
  ORDER BY e.disch_dt_tm DESC
  HEAD REPORT
   out_rec->encntr_reg_date = e.reg_dt_tm, out_rec->encntr_disch_date = e.disch_dt_tm, out_rec->
   encntr_location = uar_get_code_display(e.loc_facility_cd),
   out_rec->encntr_type = uar_get_code_display(e.encntr_type_cd), out_rec->fin = ea.alias
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
