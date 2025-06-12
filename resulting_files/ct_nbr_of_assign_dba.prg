CREATE PROGRAM ct_nbr_of_assign:dba
 SET trace = error
 SET ct_nbr_of_assign_nbrreg = 0
 SET ct_nbr_of_assign_nbrelig = 0
 SET ct_nbr_of_assign_nbrboth = 0
 IF (tocheckcohortid > 0)
  SET ct_nbr_of_assign_whrstr = build("coh.cohort_id = ",tocheckcohortid)
 ELSE
  SET ct_nbr_of_assign_whrstr = "1 = 1"
 ENDIF
 DECLARE parentcohortid = f8
 SET parentcohortid = 0.0
 SELECT INTO "NL:"
  coh.parent_cohort_id
  FROM prot_cohort coh
  PLAN (coh
   WHERE coh.stratum_id=tocheckstratumid
    AND parser(ct_nbr_of_assign_whrstr)
    AND coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   parentcohortid = coh.parent_cohort_id
  WITH counter
 ;end select
 CALL echo(build("parent cohort: ",parentcohortid))
 SELECT INTO "NL:"
  FROM prot_cohort coh,
   assign_reg_reltn a_reg
  PLAN (coh
   WHERE coh.parent_cohort_id=parentcohortid
    AND coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (a_reg
   WHERE a_reg.cohort_id=coh.cohort_id
    AND a_reg.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  WITH counter
 ;end select
 SET ct_nbr_of_assign_nbrreg = curqual
 SELECT INTO "NL:"
  FROM prot_cohort coh,
   assign_elig_reltn a_elig,
   pt_elig_consent_reltn pec,
   pt_consent pc
  PLAN (coh
   WHERE coh.parent_cohort_id=parentcohortid
    AND coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (a_elig
   WHERE a_elig.cohort_id=coh.cohort_id
    AND a_elig.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (pec
   WHERE pec.pt_elig_tracking_id=a_elig.pt_elig_tracking_id)
   JOIN (pc
   WHERE pc.consent_id=pec.consent_id
    AND pc.not_returned_reason_cd=0
    AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  WITH counter
 ;end select
 SET ct_nbr_of_assign_nbrelig = curqual
 SELECT INTO "NL:"
  FROM prot_cohort coh,
   assign_elig_reltn a_elig,
   assign_reg_reltn a_reg,
   pt_prot_reg reg,
   pt_elig_tracking elig,
   pt_reg_elig_reltn reltn
  PLAN (coh
   WHERE coh.parent_cohort_id=parentcohortid
    AND coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (a_reg
   WHERE a_reg.cohort_id=coh.cohort_id
    AND a_reg.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (reg
   WHERE reg.reg_id=a_reg.reg_id
    AND reg.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (reltn
   WHERE reltn.reg_id=reg.reg_id)
   JOIN (elig
   WHERE elig.pt_elig_tracking_id=reltn.pt_elig_tracking_id)
   JOIN (a_elig
   WHERE a_elig.pt_elig_tracking_id=elig.pt_elig_tracking_id
    AND a_elig.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  WITH counter
 ;end select
 SET ct_nbr_of_assign_nbrboth = curqual
 CALL echo(build("CT_NBR_OF_ASSIGN_NbrReg = ",ct_nbr_of_assign_nbrreg))
 CALL echo(build("CT_NBR_OF_ASSIGN_NbrElig = ",ct_nbr_of_assign_nbrelig))
 CALL echo(build("CT_NBR_OF_ASSIGN_NbrBoth = ",ct_nbr_of_assign_nbrboth))
 SET nbrofassigns = ((ct_nbr_of_assign_nbrreg+ ct_nbr_of_assign_nbrelig) - ct_nbr_of_assign_nbrboth)
 CALL echo(build("NbrOfAssigns = ",nbrofassigns))
#noecho
END GO
