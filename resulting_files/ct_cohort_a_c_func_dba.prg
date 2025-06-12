CREATE PROGRAM ct_cohort_a_c_func:dba
 RECORD cohort_a_c_func_old(
   1 status_chg_reason_cd = f8
   1 cohort_id = f8
   1 currentdatetime = dq8
   1 stratum_id = f8
   1 pt_accrual = i4
   1 cohort_status_cd = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 prot_cohort_description = vc
   1 cohort_label = c30
   1 valid_from_dt_tm = dq8
   1 valid_to_dt_tm = dq8
   1 updt_cnt = i4
   1 parent_cohort_id = f8
 )
 RECORD cohort_list(
   1 qual[*]
     2 status_chg_reason_cd = f8
     2 cohort_id = f8
     2 prot_cohort_id = f8
     2 currentdatetime = dq8
     2 stratum_id = f8
     2 pt_accrual = i4
     2 cohort_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 prot_cohort_description = vc
     2 cohort_label = c30
     2 valid_from_dt_tm = dq8
     2 valid_to_dt_tm = dq8
     2 updt_cnt = i4
     2 parent_cohort_id = f8
 )
 DECLARE cohort_list_size = i2 WITH public, noconstant(0)
 DECLARE cohort_a_c_func_cohortid = f8 WITH public, noconstant(0.0)
 DECLARE cohort_a_c_func_protcohortid = f8 WITH public, noconstant(0.0)
 DECLARE cohort_a_c_func_doupdate = i2 WITH public, noconstant(0)
 DECLARE cohort_a_c_func_continue = i2 WITH public, noconstant(0)
 DECLARE brand_new = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus = "F"
 SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohort_id = 0.0
 SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].prot_cohort_id =
 0.0
 SET false = 0
 SET true = 1
 SET cohort_a_c_func_doupdate = false
 SET cohort_a_c_func_continue = false
 IF ((cohort_a_c_func_amendmentnbr > - (1)))
  SET amendnbrstr = build("pa.amendment_nbr >=",cohort_a_c_func_amendmentnbr)
 ELSE
  SET amendnbrstr = "1 = 1"
 ENDIF
 IF ((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].valid_to_dt_tm=0))
  SET request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].valid_to_dt_tm = cnvtdatetime(
   "31-DEC-2100 00:00:00.00")
 ENDIF
 IF ((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].prot_cohort_id=0.0))
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)
   FROM dual
   DETAIL
    cohort_a_c_func_protcohortid = num
   WITH format, counter
  ;end select
  SET cohort_a_c_func_continue = true
  SET cohort_a_c_func_doupdate = true
  SET cohort_a_c_func_old->currentdatetime = cnvtdatetime(curdate,curtime3)
  SET cohort_a_c_func_cohortid = cohort_a_c_func_protcohortid
  IF ((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].parent_cohort_id=0.0))
   SET request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].parent_cohort_id =
   cohort_a_c_func_cohortid
   SET brand_new = 1
  ENDIF
 ELSE
  SELECT INTO "nl:"
   pr_coh.*
   FROM prot_cohort pr_coh
   PLAN (pr_coh
    WHERE (pr_coh.prot_cohort_id=request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].
    prot_cohort_id))
   DETAIL
    cohort_a_c_func_old->currentdatetime = cnvtdatetime(curdate,curtime3), cohort_a_c_func_old->
    status_chg_reason_cd = pr_coh.status_chg_reason_cd, cohort_a_c_func_old->stratum_id = pr_coh
    .stratum_id,
    cohort_a_c_func_cohortid = pr_coh.cohort_id, cohort_a_c_func_old->pt_accrual = pr_coh.pt_accrual,
    cohort_a_c_func_old->cohort_status_cd = pr_coh.cohort_status_cd,
    cohort_a_c_func_old->beg_effective_dt_tm = pr_coh.beg_effective_dt_tm, cohort_a_c_func_old->
    prot_cohort_description = pr_coh.prot_cohort_description, cohort_a_c_func_old->cohort_label =
    pr_coh.cohort_label,
    cohort_a_c_func_old->valid_from_dt_tm = pr_coh.valid_from_dt_tm, cohort_a_c_func_old->
    valid_to_dt_tm = pr_coh.valid_to_dt_tm, cohort_a_c_func_old->updt_cnt = pr_coh.updt_cnt,
    cohort_a_c_func_old->parent_cohort_id = pr_coh.parent_cohort_id
   WITH nocounter, forupdate(pr_coh)
  ;end select
  IF (curqual=1)
   IF ((cohort_a_c_func_old->updt_cnt != request->ss[cohort_a_c_func_ssindex].cs[
   cohort_a_c_func_csindex].updt_cnt))
    SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus =
    "C"
    SET problemdescriptionsize = size(reply->probdesc,5)
    SET problemdescriptionsize = (problemdescriptionsize+ 1)
    SET stat = alterlist(reply->probdesc,problemdescriptionsize)
    SET reply->probdesc[problemdescriptionsize].str = build("The changes to the [",request->ss[
     cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].cohort_label," cohort of the [",request->
     ss[cohort_a_c_func_ssindex].stratum_label,
     "] stratum cannot be saved because another user has modified this cohort")
   ELSE
    SET cohort_a_c_func_doupdate = false
    IF ((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].status_chg_reason_cd !=
    cohort_a_c_func_old->status_chg_reason_cd))
     SET cohort_a_c_func_doupdate = true
    ENDIF
    IF ((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].pt_accrual !=
    cohort_a_c_func_old->pt_accrual))
     SET cohort_a_c_func_doupdate = true
    ENDIF
    IF ((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].cohort_status_cd !=
    cohort_a_c_func_old->cohort_status_cd))
     SET cohort_a_c_func_doupdate = true
    ENDIF
    IF ((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].cohort_label !=
    cohort_a_c_func_old->cohort_label))
     SET cohort_a_c_func_doupdate = true
    ENDIF
    IF ((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].prot_cohort_description !=
    cohort_a_c_func_old->prot_cohort_description))
     SET cohort_a_c_func_doupdate = true
    ENDIF
    IF ((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].valid_from_dt_tm !=
    cohort_a_c_func_old->valid_from_dt_tm))
     SET cohort_a_c_func_doupdate = true
    ENDIF
    IF ((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].valid_to_dt_tm !=
    cohort_a_c_func_old->valid_to_dt_tm))
     SET cohort_a_c_func_doupdate = true
    ENDIF
    IF (cohort_a_c_func_doupdate=true)
     UPDATE  FROM prot_cohort pr_coh
      SET pr_coh.end_effective_dt_tm = cnvtdatetime(cohort_a_c_func_old->currentdatetime), pr_coh
       .updt_cnt = (pr_coh.updt_cnt+ 1), pr_coh.updt_applctx = reqinfo->updt_applctx,
       pr_coh.updt_task = reqinfo->updt_task, pr_coh.updt_id = reqinfo->updt_id, pr_coh.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WHERE (pr_coh.prot_cohort_id=request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].
      prot_cohort_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus
       = "F"
     ELSE
      SELECT INTO "nl:"
       num = seq(protocol_def_seq,nextval)
       FROM dual
       DETAIL
        cohort_a_c_func_protcohortid = num
       WITH format, counter
      ;end select
      SET cohort_a_c_func_continue = true
     ENDIF
    ELSE
     SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus =
     "S"
     SET cohort_a_c_func_continue = true
    ENDIF
   ENDIF
  ELSE
   SET cohort_a_c_func_reply->cohortstatus = "L"
  ENDIF
 ENDIF
 IF (cohort_a_c_func_doupdate=true)
  INSERT  FROM prot_cohort pr_coh
   SET pr_coh.status_chg_reason_cd = request->ss[cohort_a_c_func_ssindex].status_chg_reason_cd,
    pr_coh.stratum_id = request->ss[cohort_a_c_func_ssindex].stratum_id, pr_coh.cohort_id =
    cohort_a_c_func_cohortid,
    pr_coh.prot_cohort_id = cohort_a_c_func_protcohortid, pr_coh.parent_cohort_id = request->ss[
    cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].parent_cohort_id, pr_coh.pt_accrual =
    request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].pt_accrual,
    pr_coh.cohort_status_cd = request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].
    cohort_status_cd, pr_coh.beg_effective_dt_tm = cnvtdatetime(cohort_a_c_func_old->currentdatetime),
    pr_coh.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    pr_coh.cohort_label = request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].
    cohort_label, pr_coh.prot_cohort_description = request->ss[cohort_a_c_func_ssindex].cs[
    cohort_a_c_func_csindex].prot_cohort_description, pr_coh.valid_from_dt_tm = cnvtdatetime(request
     ->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].valid_from_dt_tm),
    pr_coh.valid_to_dt_tm = cnvtdatetime(request->ss[cohort_a_c_func_ssindex].cs[
     cohort_a_c_func_csindex].valid_to_dt_tm), pr_coh.updt_cnt = 0, pr_coh.updt_applctx = reqinfo->
    updt_applctx,
    pr_coh.updt_task = reqinfo->updt_task, pr_coh.updt_id = reqinfo->updt_id, pr_coh.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  IF (curqual=1)
   SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohort_id =
   cohort_a_c_func_cohortid
   SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].prot_cohort_id =
   cohort_a_c_func_protcohortid
   SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus =
   "S"
  ELSE
   SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus =
   "F"
  ENDIF
  IF ((((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].prot_cohort_id != 0.0)) OR
  ((request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].prot_cohort_id=0.0)
   AND revision_ind=1
   AND brand_new=0)) )
   IF (cohort_a_c_func_doupdate=true
    AND cohort_a_c_func_continue=true)
    SET cohort_list_size = 0
    SET stat = alterlist(cohort_list->qual,cohort_list_size)
    SELECT INTO "nl:"
     pc.prot_cohort_id, pc.*
     FROM prot_cohort pc,
      prot_stratum pr_str,
      prot_amendment pa,
      (dummyt d  WITH seq = value(amd_list_size))
     PLAN (d)
      JOIN (pc
      WHERE (pc.parent_cohort_id=request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].
      parent_cohort_id)
       AND pc.cohort_id != cohort_a_c_func_cohortid
       AND pc.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
      JOIN (pr_str
      WHERE pr_str.stratum_id=pc.stratum_id
       AND pr_str.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
      JOIN (pa
      WHERE pa.prot_amendment_id=pr_str.prot_amendment_id
       AND pa.amendment_status_cd != supercededcd
       AND (pa.prot_amendment_id=amendment->qual[d.seq].prot_amendment_id))
     DETAIL
      cohort_list_size = (cohort_list_size+ 1)
      IF (mod(cohort_list_size,10)=1)
       stat = alterlist(cohort_list->qual,(cohort_list_size+ 9))
      ENDIF
      cohort_list->qual[cohort_list_size].currentdatetime = cnvtdatetime(curdate,curtime3),
      cohort_list->qual[cohort_list_size].status_chg_reason_cd = pc.status_chg_reason_cd, cohort_list
      ->qual[cohort_list_size].stratum_id = pc.stratum_id,
      cohort_list->qual[cohort_list_size].prot_cohort_id = pc.prot_cohort_id, cohort_list->qual[
      cohort_list_size].cohort_id = pc.cohort_id, cohort_list->qual[cohort_list_size].
      parent_cohort_id = pc.parent_cohort_id,
      cohort_list->qual[cohort_list_size].pt_accrual = pc.pt_accrual, cohort_list->qual[
      cohort_list_size].cohort_status_cd = pc.cohort_status_cd, cohort_list->qual[cohort_list_size].
      beg_effective_dt_tm = pc.beg_effective_dt_tm,
      cohort_list->qual[cohort_list_size].prot_cohort_description = pc.prot_cohort_description,
      cohort_list->qual[cohort_list_size].cohort_label = pc.cohort_label, cohort_list->qual[
      cohort_list_size].valid_from_dt_tm = pc.valid_from_dt_tm,
      cohort_list->qual[cohort_list_size].valid_to_dt_tm = pc.valid_to_dt_tm, cohort_list->qual[
      cohort_list_size].updt_cnt = pc.updt_cnt
     WITH nocounter
    ;end select
    SET stat = alterlist(cohort_list->qual,cohort_list_size)
    IF (cohort_list_size > 0)
     IF (curqual=0)
      SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus
       = "F"
      SET cohort_a_c_func_doupdate = false
     ELSE
      SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus
       = "S"
      SET cohort_a_c_func_doupdate = true
     ENDIF
     IF (cohort_a_c_func_doupdate=true)
      UPDATE  FROM prot_cohort pr_coh,
        (dummyt d1  WITH seq = value(cohort_list_size))
       SET pr_coh.end_effective_dt_tm = cnvtdatetime(cohort_list->qual[d1.seq].currentdatetime),
        pr_coh.updt_cnt = (pr_coh.updt_cnt+ 1), pr_coh.updt_applctx = reqinfo->updt_applctx,
        pr_coh.updt_task = reqinfo->updt_task, pr_coh.updt_id = reqinfo->updt_id, pr_coh.updt_dt_tm
         = cnvtdatetime(curdate,curtime3)
       PLAN (d1)
        JOIN (pr_coh
        WHERE (pr_coh.prot_cohort_id=cohort_list->qual[d1.seq].prot_cohort_id))
       WITH counter
      ;end update
      IF (curqual=0)
       SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus
        = "F"
       SET cohort_a_c_func_continue = false
      ELSE
       SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus
        = "S"
       SET cohort_a_c_func_continue = true
      ENDIF
     ELSE
      SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus
       = "F"
      SET cohort_a_c_func_continue = false
     ENDIF
     IF (cohort_a_c_func_continue=true)
      INSERT  FROM prot_cohort pr_coh,
        (dummyt d  WITH seq = value(cohort_list_size))
       SET pr_coh.status_chg_reason_cd = request->ss[cohort_a_c_func_ssindex].cs[
        cohort_a_c_func_csindex].status_chg_reason_cd, pr_coh.stratum_id = cohort_list->qual[d.seq].
        stratum_id, pr_coh.cohort_id = cohort_list->qual[d.seq].cohort_id,
        pr_coh.prot_cohort_id = seq(protocol_def_seq,nextval), pr_coh.parent_cohort_id = cohort_list
        ->qual[d.seq].parent_cohort_id, pr_coh.pt_accrual = request->ss[cohort_a_c_func_ssindex].cs[
        cohort_a_c_func_csindex].pt_accrual,
        pr_coh.cohort_status_cd = request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].
        cohort_status_cd, pr_coh.beg_effective_dt_tm = cnvtdatetime(cohort_list->qual[d.seq].
         currentdatetime), pr_coh.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
        pr_coh.cohort_label = request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].
        cohort_label, pr_coh.prot_cohort_description = request->ss[cohort_a_c_func_ssindex].cs[
        cohort_a_c_func_csindex].prot_cohort_description, pr_coh.valid_from_dt_tm = cnvtdatetime(
         request->ss[cohort_a_c_func_ssindex].cs[cohort_a_c_func_csindex].valid_from_dt_tm),
        pr_coh.valid_to_dt_tm = cnvtdatetime(request->ss[cohort_a_c_func_ssindex].cs[
         cohort_a_c_func_csindex].valid_to_dt_tm), pr_coh.updt_cnt = 0, pr_coh.updt_applctx = reqinfo
        ->updt_applctx,
        pr_coh.updt_task = reqinfo->updt_task, pr_coh.updt_id = reqinfo->updt_id, pr_coh.updt_dt_tm
         = cnvtdatetime(curdate,curtime3)
       PLAN (d)
        JOIN (pr_coh)
       WITH nocounter
      ;end insert
      IF (curqual=0)
       CALL echo("failed to insert rows into cohort table")
       SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus
        = "F"
       SET cohort_a_c_func_continue = false
      ELSE
       CALL echo("successfully inserted rows into cohort table")
       SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus
        = "S"
       SET cohort_a_c_func_continue = true
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ELSE
   EXECUTE ct_cohort_add_child_func
   IF ((reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus !=
   "S"))
    SET cohort_a_c_func_continue = false
   ENDIF
  ENDIF
 ELSE
  SET reply->a_c_results[cohort_a_c_func_ssindex].cohorts[cohort_a_c_func_csindex].cohortstatus = "S"
 ENDIF
#noecho
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd = (debug_code_cntd+ 1)
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
 SET last_mod = "004"
 SET mod_date = "SEP 07, 2016"
END GO
