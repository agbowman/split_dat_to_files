CREATE PROGRAM ct_stratum_d_l_func:dba
 SET false = 0
 SET true = 1
 DECLARE stratum_d_l_func_continue = i2 WITH public, noconstant(0)
 SET stratum_d_l_func_continue = false
 SET reply->a_c_results[stratum_d_l_func_ssindex].stratumstatus = "F"
 SELECT INTO "nl:"
  pr_str.stratum_id
  FROM prot_stratum pr_str
  WHERE (pr_str.prot_stratum_id=request->ss[stratum_d_l_func_ssindex].prot_stratum_id)
  DETAIL
   request->ss[stratum_d_l_func_ssindex].stratum_id = pr_str.stratum_id
  WITH nocounter
 ;end select
 SET tocheckstratumid = request->ss[stratum_d_l_func_ssindex].stratum_id
 SET tocheckcohortid = 0.0
 SET nbrofassigns = 0
 EXECUTE ct_nbr_of_assign
 SET reply->a_c_results[stratum_d_l_func_ssindex].prot_stratum_id = request->ss[
 stratum_d_l_func_ssindex].prot_stratum_id
 SET reply->a_c_results[stratum_d_l_func_ssindex].stratum_id = request->ss[stratum_d_l_func_ssindex].
 stratum_id
 IF (nbrofassigns=0)
  SET stratumlistsize = 0
  SELECT INTO "nl:"
   pr_str.*
   FROM prot_stratum pr_str,
    (dummyt d  WITH seq = value(amd_list_size))
   PLAN (d)
    JOIN (pr_str
    WHERE (pr_str.parent_stratum_id=request->ss[stratum_d_l_func_ssindex].parent_stratum_id)
     AND pr_str.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND (pr_str.prot_amendment_id=amendment->qual[d.seq].prot_amendment_id)
     AND (amendment->qual[d.seq].delete_ind=1))
   DETAIL
    stratumlistsize += 1
    IF (mod(stratumlistsize,10)=1)
     stat = alterlist(stratum->stratum_list,(stratumlistsize+ 9))
    ENDIF
    stratum->stratum_list[stratumlistsize].prot_stratum_id = pr_str.prot_stratum_id, stratum->
    stratum_list[stratumlistsize].stratum_id = pr_str.stratum_id
   WITH nocounter, forupdate(pr_str)
  ;end select
  SET stat = alterlist(stratum->stratum_list,stratumlistsize)
  IF (stratumlistsize > 0)
   IF (curqual=0)
    SET reply->a_c_results[stratum_d_l_func_ssindex].stratumstatus = "L"
    SET problemdescriptionsize = size(reply->probdesc,5)
    SET problemdescriptionsize += 1
    SET stat = alterlist(reply->probdesc,problemdescriptionsize)
    SET reply->probdesc[problemdescriptionsize].str = build(
     "The strata cannot be deleted because the rows cannot be locked.")
    SET stratum_d_l_func_continue = false
   ELSE
    SET stratum_d_l_func_continue = true
    SET reply->a_c_results[stratum_d_l_func_ssindex].stratumstatus = "S"
   ENDIF
  ELSE
   SET stratum_d_l_func_continue = false
  ENDIF
  IF (stratum_d_l_func_continue=true)
   UPDATE  FROM prot_stratum pr_str,
     (dummyt d  WITH seq = value(stratumlistsize))
    SET pr_str.end_effective_dt_tm = cnvtdatetime(sysdate), pr_str.updt_cnt = (pr_str.updt_cnt+ 1),
     pr_str.updt_applctx = reqinfo->updt_applctx,
     pr_str.updt_task = reqinfo->updt_task, pr_str.updt_id = reqinfo->updt_id, pr_str.updt_dt_tm =
     cnvtdatetime(sysdate)
    PLAN (d)
     JOIN (pr_str
     WHERE (pr_str.prot_stratum_id=stratum->stratum_list[d.seq].prot_stratum_id))
    WITH nocounter
   ;end update
   IF (curqual > 0)
    SELECT INTO "nl:"
     FROM prot_cohort pr_coh,
      (dummyt d  WITH seq = value(stratumlistsize))
     PLAN (d)
      JOIN (pr_coh
      WHERE (pr_coh.stratum_id=stratum->stratum_list[d.seq].stratum_id)
       AND pr_coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     WITH nocounter, forupdate(pr_coh)
    ;end select
    IF (curqual > 0)
     UPDATE  FROM prot_cohort pr_coh,
       (dummyt d  WITH seq = value(stratumlistsize))
      SET pr_coh.end_effective_dt_tm = cnvtdatetime(sysdate), pr_coh.updt_cnt = (pr_coh.updt_cnt+ 1),
       pr_coh.updt_applctx = reqinfo->updt_applctx,
       pr_coh.updt_task = reqinfo->updt_task, pr_coh.updt_id = reqinfo->updt_id, pr_coh.updt_dt_tm =
       cnvtdatetime(sysdate)
      PLAN (d)
       JOIN (pr_coh
       WHERE (pr_coh.stratum_id=stratum->stratum_list[d.seq].stratum_id)
        AND pr_coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
      WITH nocounter
     ;end update
     IF (curqual > 0)
      SET reply->a_c_results[stratum_d_l_func_ssindex].stratumstatus = "S"
     ELSE
      SET reply->a_c_results[stratum_d_l_func_ssindex].stratumstatus = "F"
     ENDIF
    ENDIF
   ELSE
    SET reply->a_c_results[stratum_d_l_func_ssindex].stratumstatus = "F"
   ENDIF
  ENDIF
 ELSE
  SET reply->a_c_results[stratum_d_l_func_ssindex].stratumstatus = "A"
  SET problemdescriptionsize = size(reply->probdesc,5)
  SET problemdescriptionsize += 1
  SET stat = alterlist(reply->probdesc,problemdescriptionsize)
  SET reply->probdesc[problemdescriptionsize].str = build("The [",request->ss[
   stratum_d_l_func_ssindex].stratum_label,"] stratum cannot be deleted because there are already (",
   nbrofassigns,") patients enrolled on this stratum")
 ENDIF
 SET last_mod = "002"
 SET mod_date = "SEP 07, 2016"
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
