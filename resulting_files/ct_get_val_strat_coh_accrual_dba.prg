CREATE PROGRAM ct_get_val_strat_coh_accrual:dba
 RECORD reply(
   1 amountaccrued = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 cohort_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE enrolled_accrual = i4 WITH public, noconstant(0)
 DECLARE assigned_checklist_accrual = i4 WITH public, noconstant(0)
 DECLARE ncohortcount = i2 WITH public, noconstant(0)
 DECLARE enrolling_cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(17900,"ENROLLING",1,enrolling_cd)
 IF ((request->prot_stratum_id > 0))
  SELECT INTO "nl:"
   pc1.cohort_id
   FROM prot_cohort pc,
    prot_cohort pc1
   PLAN (pc
    WHERE (pc.stratum_id=request->prot_stratum_id)
     AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (pc1
    WHERE pc1.parent_cohort_id=pc.parent_cohort_id)
   DETAIL
    ncohortcount = (ncohortcount+ 1)
    IF (mod(ncohortcount,10)=1)
     stat = alterlist(temp->qual,(ncohortcount+ 9))
    ENDIF
    temp->qual[ncohortcount].cohort_id = pc1.cohort_id
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   pc1.cohort_id
   FROM prot_cohort pc,
    prot_cohort pc1
   PLAN (pc
    WHERE (pc.cohort_id=request->prot_cohort_id)
     AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (pc1
    WHERE pc1.parent_cohort_id=pc.parent_cohort_id)
   DETAIL
    ncohortcount = (ncohortcount+ 1)
    IF (mod(ncohortcount,10)=1)
     stat = alterlist(temp->qual,(ncohortcount+ 9))
    ENDIF
    temp->qual[ncohortcount].cohort_id = pc1.cohort_id
   WITH nocounter
  ;end select
 ENDIF
 IF (ncohortcount > 0)
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET stat = alterlist(temp->qual,ncohortcount)
 FOR (x = 1 TO ncohortcount)
   CALL echo(temp->qual[x].cohort_id)
 ENDFOR
 IF (ncohortcount > 0)
  SELECT INTO "nl:"
   pp.reg_id
   FROM pt_prot_reg pp,
    assign_reg_reltn ar,
    (dummyt d  WITH seq = value(ncohortcount))
   PLAN (d)
    JOIN (ar
    WHERE (ar.cohort_id=temp->qual[d.seq].cohort_id))
    JOIN (pp
    WHERE pp.reg_id=ar.reg_id
     AND pp.reg_id > 0
     AND pp.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   DETAIL
    enrolled_accrual = (enrolled_accrual+ 1)
   WITH nocounter
  ;end select
  CALL echo(build("Enrolled is: ",enrolled_accrual))
  IF (enrolled_accrual > 0)
   IF (curqual=0)
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   p.pt_elig_tracking_id
   FROM assign_elig_reltn a,
    prot_cohort pc,
    pt_consent pco,
    pt_elig_consent_reltn pec,
    pt_elig_tracking p,
    prot_questionnaire pq,
    (dummyt d  WITH seq = value(ncohortcount))
   PLAN (d)
    JOIN (pc
    WHERE (pc.cohort_id=temp->qual[d.seq].cohort_id)
     AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (a
    WHERE a.cohort_id=pc.cohort_id
     AND a.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (p
    WHERE p.pt_elig_tracking_id=a.pt_elig_tracking_id)
    JOIN (pq
    WHERE pq.prot_questionnaire_id=p.prot_questionnaire_id
     AND pq.questionnaire_type_cd=enrolling_cd)
    JOIN (pec
    WHERE pec.pt_elig_tracking_id=p.pt_elig_tracking_id)
    JOIN (pco
    WHERE pco.consent_id=pec.consent_id
     AND pco.not_returned_reason_cd=0
     AND pco.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND pco.consent_signed_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   DETAIL
    assigned_checklist_accrual = (assigned_checklist_accrual+ 1)
   WITH nocounter
  ;end select
  CALL echo(build("Assigned_Checklist_Accrual is: ",assigned_checklist_accrual))
  IF (assigned_checklist_accrual > 0)
   IF (curqual=0)
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
 SET reply->amountaccrued = (assigned_checklist_accrual+ enrolled_accrual)
 CALL echo(build("Total_Accrued is: ",reply->amountaccrued))
END GO
