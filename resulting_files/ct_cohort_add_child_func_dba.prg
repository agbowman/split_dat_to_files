CREATE PROGRAM ct_cohort_add_child_func:dba
 DECLARE i = i2 WITH private, noconstant(0)
 DECLARE cohort_add_child_continue = i2 WITH private, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus = "F"
 SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohort_id = 0.0
 SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].prot_cohort_id =
 0.0
 SET false = 0
 SET true = 1
 SET cohort_add_child_continue = false
 IF (amdlistsize=0)
  SET stat = alterlist(amdlist->amdlist,amdlistsize)
  SELECT INTO "nl:"
   FROM prot_amendment pa,
    prot_master pm,
    (dummyt d  WITH seq = value(amd_list_size))
   PLAN (d)
    JOIN (pm
    WHERE pm.parent_prot_master_id=parent_prot_master_id)
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND (pa.prot_amendment_id != request->prot_amendment_id)
     AND pa.amendment_status_cd != supercededcd
     AND (pa.prot_amendment_id=amendment->qual[d.seq].prot_amendment_id))
   HEAD REPORT
    amdlistsize = 0
   DETAIL
    skip = 0
    IF (collab_ind=1)
     IF (pm.collab_site_org_id=0)
      skip = 1
     ELSEIF (pm.collab_site_org_id > 0
      AND (pa.prot_amendment_id != request->prot_amendment_id))
      skip = 1
     ENDIF
    ENDIF
    IF (skip=0)
     amdlistsize = (amdlistsize+ 1)
     IF (mod(amdlistsize,10)=1)
      stat = alterlist(amdlist->amdlist,(amdlistsize+ 9))
     ENDIF
     amdlist->amdlist[amdlistsize].prot_amendment_id = pa.prot_amendment_id
    ENDIF
   FOOT REPORT
    stat = alterlist(amdlist->amdlist,amdlistsize)
   WITH nocounter
  ;end select
 ENDIF
 IF (amdlistsize > 0)
  SELECT INTO "nl:"
   FROM prot_stratum ps,
    (dummyt d  WITH seq = value(amdlistsize))
   PLAN (d)
    JOIN (ps
    WHERE (ps.parent_stratum_id=request->ss[cohort_a_c_func_ssindex].parent_stratum_id)
     AND (ps.prot_amendment_id=amdlist->amdlist[d.seq].prot_amendment_id)
     AND ps.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   HEAD REPORT
    stratumlistsize = 0
   DETAIL
    stratumlistsize = (stratumlistsize+ 1)
    IF (mod(stratumlistsize,10)=1)
     stat = alterlist(stratum->stratum_list,(stratumlistsize+ 9))
    ENDIF
    stratum->stratum_list[stratumlistsize].stratum_id = ps.stratum_id
   FOOT REPORT
    stat = alterlist(stratum->stratum_list,stratumlistsize)
   WITH nocounter
  ;end select
 ENDIF
 IF (stratumlistsize > 0)
  IF (curqual=0)
   SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus =
   "F"
   SET cohort_add_child_continue = false
  ELSE
   SET cohort_add_child_continue = true
  ENDIF
  IF (cohort_add_child_continue=true)
   INSERT  FROM prot_cohort pr_coh,
     (dummyt d  WITH seq = value(stratumlistsize))
    SET pr_coh.stratum_id = stratum->stratum_list[d.seq].stratum_id, pr_coh.cohort_id = seq(
      protocol_def_seq,nextval), pr_coh.prot_cohort_id = seq(protocol_def_seq,nextval),
     pr_coh.parent_cohort_id = request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].
     parent_cohort_id, pr_coh.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pr_coh
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     pr_coh.status_chg_reason_cd = request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].
     status_chg_reason_cd, pr_coh.pt_accrual = request->ss[cohort_a_c_func_ssindex].cs[
     cohort_a_c_func_csindex].pt_accrual, pr_coh.cohort_status_cd = request->ss[
     cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].cohort_status_cd,
     pr_coh.cohort_label = request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].
     cohort_label, pr_coh.prot_cohort_description = request->ss[cohort_a_c_func_ssindex].cs[
     cohort_a_c_func_csindex].prot_cohort_description, pr_coh.valid_from_dt_tm = cnvtdatetime(request
      ->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].valid_from_dt_tm),
     pr_coh.valid_to_dt_tm = cnvtdatetime(request->ss[cohort_a_c_func_ssindex].cs[
      cohort_a_c_func_csindex].valid_to_dt_tm), pr_coh.updt_cnt = 0, pr_coh.updt_applctx = reqinfo->
     updt_applctx,
     pr_coh.updt_task = reqinfo->updt_task, pr_coh.updt_id = reqinfo->updt_id, pr_coh.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    PLAN (d)
     JOIN (pr_coh)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus =
    "F"
    SET cohort_a_c_func_continue = false
   ELSE
    SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus =
    "S"
    SET cohort_a_c_func_continue = true
   ENDIF
  ENDIF
 ELSE
  SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus = "Z"
  SET cohort_a_c_func_continue = true
 ENDIF
 SET last_mod = "002"
 SET mod_date = "SEP 19, 2016"
END GO
