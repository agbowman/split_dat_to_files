CREATE PROGRAM cco_get_died_hosp_from_ra:dba
 DECLARE meaning_code(p1,p1) = f8
 DECLARE diedinhosp_ind = i4
 DECLARE disposition_cd = f8
 DECLARE diedinicu_ind = i4
 DECLARE riskadj = f8
 SET diedinicu_ind = - (1)
 SET diedinhosp_ind = - (1)
 SET deceased_cd = 0.0
 SET expired_cd = 0.0
 EXECUTE FROM 1000_get_hosp_disch_status TO 1000_get_hosp_disch_status_exit
 GO TO 9999_exit_program
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_get_hosp_disch_status
 SET deceased_cd = meaning_code(19,"DECEASED")
 SET expired_cd = meaning_code(19,"EXPIRED")
 SET hdeath_reply->hosp_death_ind = - (1)
 IF ((hdeath_parameters->risk_adjustment_id != null)
  AND (hdeath_parameters->risk_adjustment_id > 0))
  SELECT INTO "nl:"
   FROM risk_adjustment ra,
    encounter e,
    person p
   PLAN (ra
    WHERE (ra.risk_adjustment_id=hdeath_parameters->risk_adjustment_id)
     AND ra.icu_disch_dt_tm < cnvtdatetime("31-DEC-2100")
     AND ra.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=ra.encntr_id
     AND e.active_ind=1)
    JOIN (p
    WHERE p.person_id=ra.person_id
     AND p.active_ind=1)
   DETAIL
    discharge_dt = e.disch_dt_tm, reg_dt = ra.icu_admit_dt_tm, deceased_dt = p.deceased_dt_tm,
    disposition_cd = e.disch_disposition_cd, diedinicu_ind = ra.diedinicu_ind, riskadj = ra
    .risk_adjustment_id
    IF (ra.diedinicu_ind=0)
     hdeath_reply->hosp_death_ind = 0
    ENDIF
   FOOT REPORT
    IF (disposition_cd IN (deceased_cd, expired_cd))
     hdeath_reply->hosp_death_ind = 1
    ELSEIF (deceased_dt > reg_dt
     AND deceased_dt <= discharge_dt)
     hdeath_reply->hosp_death_ind = 1
    ELSEIF (diedinicu_ind=1)
     hdeath_reply->hosp_death_ind = 1
    ELSEIF (riskadj=null)
     hdeath_reply->hosp_death_ind = - (1)
    ELSEIF (e.disch_dt_tm=null)
     hdeath_reply->hosp_death_ind = - (1)
    ELSE
     hdeath_reply->hosp_death_ind = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#1000_get_hosp_disch_status_exit
#9999_exit_program
END GO
