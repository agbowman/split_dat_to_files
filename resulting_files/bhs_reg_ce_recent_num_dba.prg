CREATE PROGRAM bhs_reg_ce_recent_num:dba
 DECLARE sys_bp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE dia_bp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE hemo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEMOGLOBINA1CMONITORING"))
 DECLARE microalb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MICROALBUMIN"))
 DECLARE creat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CREATININEBLOOD"))
 DECLARE bmi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX"))
 DECLARE bun_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BUN"))
 DECLARE tsh_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"TSH"))
 DECLARE alt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ALTSGPT"))
 DECLARE ast_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ASTSGOT"))
 DECLARE glucose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"GLUCOSELEVEL"))
 DECLARE chol_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CHOLESTEROL"))
 DECLARE trigl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"TRIGLYCERIDES"))
 DECLARE hdl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HDLCHOLESTEROL"))
 DECLARE ldl1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LDLCHOLESTEROL"))
 DECLARE ldl2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LDLCARDIAC"))
 DECLARE ldl3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIRECTLOWDENSITYLIPOPROTEIN"))
 DECLARE notdone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"NOT DONE"))
 DECLARE inerror_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"INERROR"))
 SELECT
  t.person_id, ce.clinsig_updt_dt_tm, ce.result_val
  FROM bhs_problem_registry t,
   clinical_event ce
  WHERE ((t.person_id+ 0)=ce.person_id)
   AND  NOT (ce.result_val IN ("", " ", null))
   AND cnvtreal(ce.result_val) > 0
   AND ce.event_cd IN (sys_bp_cd, dia_bp_cd, hemo_cd, microalb_cd, creat_cd,
  bmi_cd, bun_cd, tsh_cd, alt_cd, ast_cd,
  glucose_cd, chol_cd, trigl_cd, hdl_cd, ldl1_cd,
  ldl2_cd, ldl3_cd)
   AND  NOT (ce.result_status_cd IN (notdone_cd, inerror_cd))
  ORDER BY t.person_id, ce.event_cd, ce.clinsig_updt_dt_tm DESC
 ;end select
#exit_script
 FREE RECORD m_info
END GO
