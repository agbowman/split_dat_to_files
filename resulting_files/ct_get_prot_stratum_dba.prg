CREATE PROGRAM ct_get_prot_stratum:dba
 RECORD reply(
   1 cohort_id = f8
   1 parent_cohort_id = f8
   1 assignstatus = c1
   1 enroll_strat_type_cd = f8
   1 enroll_strat_type_disp = vc
   1 enroll_strat_type_desc = vc
   1 enroll_strat_type_mean = c12
   1 scohorttypedefault = f8
   1 scohorttypemulti = f8
   1 scohorttypetypical = f8
   1 scohortstatusclosed = f8
   1 scohortstatusopen = f8
   1 scohortstatussuspended = f8
   1 ss[*]
     2 status_chg_reason_cd = f8
     2 prot_stratum_id = f8
     2 stratum_id = f8
     2 parent_stratum_id = f8
     2 stratum_ctms_extn_txt = vc
     2 organization_id = f8
     2 prot_amendment_id = f8
     2 stratum_label = c100
     2 stratum_cd = f8
     2 stratum_disp = vc
     2 stratum_desc = vc
     2 stratum_mean = c12
     2 stratum_description = vc
     2 stratum_status_cd = f8
     2 stratum_status_disp = vc
     2 stratum_status_desc = vc
     2 stratum_status_mean = c12
     2 stratum_cohort_type_cd = f8
     2 stratum_cohort_type_disp = vc
     2 stratum_cohort_type_desc = vc
     2 stratum_cohort_type_mean = c12
     2 length_evaluation = i4
     2 length_evaluation_uom_cd = f8
     2 length_evaluation_uom_disp = vc
     2 length_evaluation_uom_desc = vc
     2 length_evaluation_uom_mean = c12
     2 updt_cnt = i4
     2 cs[*]
       3 status_chg_reason_cd = f8
       3 prot_cohort_id = f8
       3 cohort_id = f8
       3 parent_cohort_id = f8
       3 stratum_id = f8
       3 pt_accrual = i4
       3 cohort_status_cd = f8
       3 cohort_status_disp = vc
       3 cohort_status_desc = vc
       3 cohort_status_mean = c12
       3 prot_cohort_description = vc
       3 cohort_label = c30
       3 valid_from_dt_tm = dq8
       3 valid_to_dt_tm = dq8
       3 updt_cnt = i4
     2 susps[*]
       3 prot_stratum_susp_id = f8
       3 susp_id = f8
       3 reason_cd = f8
       3 reason_disp = vc
       3 reason_desc = vc
       3 reason_mean = c12
       3 comment_txt = vc
       3 susp_effective_dt_tm = dq8
       3 susp_end_dt_tm = dq8
       3 updt_cnt = i4
   1 statusfunc = c1
   1 a_c_results[*]
     2 a_key = vc
     2 stratumstatus = c1
     2 prot_stratum_id = f8
     2 stratum_id = f8
     2 suspsummary = c1
     2 cohortsummary = c1
     2 susps[*]
       3 a_key = vc
       3 suspstatus = c1
       3 prot_stratum_susp_id = f8
       3 susp_id = f8
     2 cohorts[*]
       3 a_key = vc
       3 cohortstatus = c1
       3 prot_cohort_id = f8
       3 cohort_id = f8
   1 probdesc[*]
     2 str = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 SET cset = 18776
 SET cmean = "DEFAULT"
 EXECUTE ct_get_cv
 SET reply->scohorttypedefault = cval
 SET cset = 18776
 SET cmean = "MULTI"
 EXECUTE ct_get_cv
 SET reply->scohorttypemulti = cval
 SET cset = 18776
 SET cmean = "TYPICAL"
 EXECUTE ct_get_cv
 SET reply->scohorttypetypical = cval
 SET cset = 18778
 SET cmean = "CLOSED"
 EXECUTE ct_get_cv
 SET reply->scohortstatusclosed = cval
 SET cset = 18778
 SET cmean = "OPEN"
 EXECUTE ct_get_cv
 SET reply->scohortstatusopen = cval
 SET cset = 18778
 SET cmean = "SUSPENDED"
 EXECUTE ct_get_cv
 SET reply->scohortstatussuspended = cval
 CALL echo("getting enrol_strat_type")
 SELECT INTO "nl:"
  a.*
  FROM prot_amendment a
  WHERE (a.prot_amendment_id=request->prot_amendment_id)
  DETAIL
   reply->enroll_strat_type_cd = a.enroll_stratification_type_cd
  WITH nocounter
 ;end select
 SET stratum_g_func_status = "F"
 EXECUTE ct_stratum_g_func
 SET reply->status_data.status = stratum_g_func_status
 SET last_mod = "003"
 SET mod_date = "Nov 13, 2019"
#noecho
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd += 1
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
