CREATE PROGRAM ct_stratum_g_func:dba
 SET stratum_g_func_status = "F"
 SET reply->assignstatus = "F"
 SET stratum_g_func_cnts = 0
 SET stratum_g_func_cntcoh = 0
 SET stratum_g_func_cntsusp = 0
 SET stratum_g_func_new = 0
 SET stratum_g_func_s = 0
 SET stratum_g_func_c = 0
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 IF ((request->stratum_open_only=false))
  SET whrstratum = " 1=1 "
 ELSE
  SET cset = 18775
  SET cmean = "OPEN"
  EXECUTE ct_get_cv
  SET stratum_g_func_stratum_open = cval
  SET whrstratum = "pr_str.stratum_status_cd = STRATUM_G_FUNC_Stratum_Open"
 ENDIF
 IF ((request->cohort_open_only=false))
  SET whrcohort = " 1=1 "
 ELSE
  SET cset = 18778
  SET cmean = "OPEN"
  EXECUTE ct_get_cv
  SET stratum_g_func_cohort_open = cval
  SET whrcohort = "pr_coh.cohort_status_cd = STRATUM_G_FUNC_Cohort_Open"
 ENDIF
 CALL echo(build("WhrStratum = ",whrstratum))
 CALL echo(build("WhrCohort = ",whrcohort))
 SELECT INTO "nl:"
  pr_str.*, pr_coh.*, suspindicator = decode(susp.seq,2,1),
  cohortindicator = decode(pr_coh.seq,2,1), nullind_pr_str_stratum_ctms_extn_txt = nullind(pr_str
   .stratum_ctms_extn_txt)
  FROM prot_stratum pr_str,
   prot_cohort pr_coh,
   prot_stratum_susp susp,
   dummyt d1,
   dummyt d2
  PLAN (pr_str
   WHERE (pr_str.prot_amendment_id=request->prot_amendment_id)
    AND pr_str.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND parser(whrstratum))
   JOIN (d1)
   JOIN (pr_coh
   WHERE pr_coh.stratum_id=pr_str.stratum_id
    AND pr_coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND parser(whrcohort))
   JOIN (d2)
   JOIN (susp
   WHERE susp.stratum_id=pr_str.stratum_id
    AND susp.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY pr_str.stratum_id, pr_coh.prot_cohort_id, susp.beg_effective_dt_tm
  HEAD pr_str.stratum_id
   stratum_g_func_cnts += 1
   IF (mod(stratum_g_func_cnts,10)=1)
    stratum_g_func_new = (stratum_g_func_cnts+ 10), stat = alterlist(reply->ss,stratum_g_func_new)
   ENDIF
   reply->ss[stratum_g_func_cnts].status_chg_reason_cd = pr_str.status_chg_reason_cd, reply->ss[
   stratum_g_func_cnts].organization_id = pr_str.organization_id, reply->ss[stratum_g_func_cnts].
   prot_amendment_id = pr_str.prot_amendment_id,
   reply->ss[stratum_g_func_cnts].stratum_label = pr_str.stratum_label, reply->ss[stratum_g_func_cnts
   ].stratum_cd = pr_str.stratum_cd, reply->ss[stratum_g_func_cnts].stratum_description = pr_str
   .stratum_description
   IF (nullind_pr_str_stratum_ctms_extn_txt=1)
    reply->ss[stratum_g_func_cnts].stratum_ctms_extn_txt = ""
   ELSE
    reply->ss[stratum_g_func_cnts].stratum_ctms_extn_txt = pr_str.stratum_ctms_extn_txt
   ENDIF
   reply->ss[stratum_g_func_cnts].stratum_status_cd = pr_str.stratum_status_cd, reply->ss[
   stratum_g_func_cnts].stratum_cohort_type_cd = pr_str.stratum_cohort_type_cd, reply->ss[
   stratum_g_func_cnts].length_evaluation = pr_str.length_evaluation,
   reply->ss[stratum_g_func_cnts].length_evaluation_uom_cd = pr_str.length_evaluation_uom_cd, reply->
   ss[stratum_g_func_cnts].prot_stratum_id = pr_str.prot_stratum_id, reply->ss[stratum_g_func_cnts].
   stratum_id = pr_str.stratum_id,
   reply->ss[stratum_g_func_cnts].parent_stratum_id = pr_str.parent_stratum_id, reply->ss[
   stratum_g_func_cnts].updt_cnt = pr_str.updt_cnt, stratum_g_func_cntcoh = 0
  HEAD pr_coh.prot_cohort_id
   IF (cohortindicator=2)
    stratum_g_func_cntcoh += 1
    IF (mod(stratum_g_func_cntcoh,10)=1)
     stratum_g_func_new = (stratum_g_func_cntcoh+ 10), stat = alterlist(reply->ss[stratum_g_func_cnts
      ].cs,stratum_g_func_new)
    ENDIF
    reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].status_chg_reason_cd = pr_coh
    .status_chg_reason_cd, reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].prot_cohort_id =
    pr_coh.prot_cohort_id, reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].cohort_id =
    pr_coh.cohort_id,
    reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].parent_cohort_id = pr_coh
    .parent_cohort_id, reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].stratum_id = pr_coh
    .stratum_id, reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].pt_accrual = pr_coh
    .pt_accrual,
    reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].cohort_status_cd = pr_coh
    .cohort_status_cd, reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].
    prot_cohort_description = pr_coh.prot_cohort_description
    IF (uar_get_code_meaning(pr_str.stratum_cohort_type_cd)="DEFAULT")
     reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].cohort_label = ""
    ELSE
     reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].cohort_label = pr_coh.cohort_label
    ENDIF
    reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].valid_from_dt_tm = pr_coh
    .valid_from_dt_tm, reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].valid_to_dt_tm =
    pr_coh.valid_to_dt_tm, reply->ss[stratum_g_func_cnts].cs[stratum_g_func_cntcoh].updt_cnt = pr_coh
    .updt_cnt
   ENDIF
   stratum_g_func_cntsusp = 0
  DETAIL
   IF (suspindicator=2)
    stratum_g_func_cntsusp += 1
    IF (mod(stratum_g_func_cntsusp,10)=1)
     stratum_g_func_new = (stratum_g_func_cntsusp+ 10), stat = alterlist(reply->ss[
      stratum_g_func_cnts].susps,stratum_g_func_new)
    ENDIF
    reply->ss[stratum_g_func_cnts].susps[stratum_g_func_cntsusp].prot_stratum_susp_id = susp
    .prot_stratum_susp_id, reply->ss[stratum_g_func_cnts].susps[stratum_g_func_cntsusp].susp_id =
    susp.susp_id, reply->ss[stratum_g_func_cnts].susps[stratum_g_func_cntsusp].reason_cd = susp
    .reason_cd,
    reply->ss[stratum_g_func_cnts].susps[stratum_g_func_cntsusp].susp_effective_dt_tm = susp
    .susp_effective_dt_tm, reply->ss[stratum_g_func_cnts].susps[stratum_g_func_cntsusp].
    susp_end_dt_tm = susp.susp_end_dt_tm, reply->ss[stratum_g_func_cnts].susps[stratum_g_func_cntsusp
    ].updt_cnt = susp.updt_cnt
   ENDIF
  FOOT  pr_coh.prot_cohort_id
   stat = alterlist(reply->ss[stratum_g_func_cnts].susps,stratum_g_func_cntsusp)
  FOOT  pr_str.stratum_id
   stat = alterlist(reply->ss[stratum_g_func_cnts].cs,stratum_g_func_cntcoh)
  WITH nocounter, dontcare = pr_coh, outerjoin = d2,
   memsort
 ;end select
 IF ((request->reg_id > 0.0))
  SELECT INTO "nl:"
   arr.cohort_id
   FROM assign_reg_reltn arr,
    prot_cohort pc
   PLAN (arr
    WHERE (arr.reg_id=request->reg_id)
     AND arr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (pc
    WHERE pc.cohort_id=arr.cohort_id
     AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   DETAIL
    reply->cohort_id = arr.cohort_id, reply->parent_cohort_id = pc.parent_cohort_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->reg_id=0.0))
  IF ((request->pt_elig_tracking_id > 0.0))
   SELECT INTO "nl:"
    aer.*
    FROM assign_elig_reltn aer,
     prot_cohort pc
    PLAN (aer
     WHERE (aer.pt_elig_tracking_id=request->pt_elig_tracking_id)
      AND aer.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (pc
     WHERE pc.cohort_id=aer.cohort_id
      AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    DETAIL
     reply->cohort_id = aer.cohort_id, reply->parent_cohort_id = pc.parent_cohort_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->reg_id > 0.0))
  SET reply->assignstatus = "S"
 ELSE
  SET reply->assignstatus = "Z"
 ENDIF
 SET stat = alterlist(reply->ss,stratum_g_func_cnts)
 SET stratum_g_func_status = "S"
 SET last_mod = "004"
 SET mod_date = "Nov 13, 2019"
#noecho
END GO
