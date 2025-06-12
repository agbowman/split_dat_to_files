CREATE PROGRAM bob_mu_smoker:dba
 DECLARE f_smoking_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,"SMOKINGCESSATION"
   ))
 SELECT
  e.person_id, count(ce.clinical_event_id)
  FROM encounter e,
   code_value cv,
   clinical_event ce
  WHERE e.active_ind=1
   AND e.beg_effective_dt_tm < sysdate
   AND e.end_effective_dt_tm > sysdate
   AND e.disch_dt_tm BETWEEN cnvtdatetime(curdate,(curtime - 500000)) AND sysdate
   AND e.loc_facility_cd=cv.code_value
   AND cv.code_set=220
   AND cv.cdf_meaning="FACILITY"
   AND cv.display_key IN ("BMC", "BFMC", "BMLH")
   AND ce.encntr_id=outerjoin(e.encntr_id)
   AND ce.valid_until_dt_tm >= outerjoin(sysdate)
   AND ce.event_cd=outerjoin(f_smoking_cd)
  GROUP BY e.person_id
 ;end select
#exit_script
END GO
