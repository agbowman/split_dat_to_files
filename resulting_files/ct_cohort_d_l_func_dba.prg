CREATE PROGRAM ct_cohort_d_l_func:dba
 SET false = 0
 SET true = 1
 SET reply->a_c_results[cohort_d_l_func_ssindex].cohorts[cohort_d_l_func_csindex].cohortstatus = "F"
 SET tocheckstratumid = request->ss[cohort_d_l_func_ssindex].stratum_id
 SET tocheckcohortid = request->ss[cohort_d_l_func_ssindex].cs[cohort_d_l_func_csindex].cohort_id
 SET nbrofassigns = 0
 EXECUTE ct_nbr_of_assign
 CALL echo(build("NbrOfAssigns = ",nbrofassigns))
 CALL echo(build("NbrOfAssigns = ",nbrofassigns))
 IF (nbrofassigns=0)
  CALL echo(build("locking the prot_cohort row for logical delete"))
  IF (stratumlistsize > 0)
   SELECT INTO "nl:"
    FROM prot_cohort pr_coh,
     (dummyt d  WITH seq = value(stratumlistsize))
    PLAN (d)
     JOIN (pr_coh
     WHERE (pr_coh.stratum_id=stratum->stratum_list[d.seq].stratum_id)
      AND (pr_coh.parent_cohort_id=request->ss[cohort_d_l_func_ssindex].cs[cohort_d_l_func_csindex].
     parent_cohort_id)
      AND pr_coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    WITH nocounter, forupdate(pr_coh)
   ;end select
   IF (curqual=0)
    SET reply->a_c_results[cohort_d_l_func_ssindex].cohorts[cohort_d_l_func_csindex].cohortstatus =
    "L"
    SET problemdescriptionsize = size(reply->probdesc,5)
    SET problemdescriptionsize = (problemdescriptionsize+ 1)
    SET stat = alterlist(reply->probdesc,problemdescriptionsize)
    SET reply->probdesc[problemdescriptionsize].str =
    "The cohort rows to update could not be locked."
   ELSE
    CALL echo(build("successfully locked row(s) to update ; curqual = ",curqual))
    UPDATE  FROM prot_cohort pr_coh,
      (dummyt d  WITH seq = value(stratumlistsize))
     SET pr_coh.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pr_coh.updt_cnt = (pr_coh
      .updt_cnt+ 1), pr_coh.updt_applctx = reqinfo->updt_applctx,
      pr_coh.updt_task = reqinfo->updt_task, pr_coh.updt_id = reqinfo->updt_id, pr_coh.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (pr_coh
      WHERE (pr_coh.stratum_id=stratum->stratum_list[d.seq].stratum_id)
       AND (pr_coh.parent_cohort_id=request->ss[cohort_d_l_func_ssindex].cs[cohort_d_l_func_csindex].
      parent_cohort_id)
       AND pr_coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 0:00.00"))
     WITH nocounter
    ;end update
    IF (curqual > 0)
     CALL echo(build("successfully logically deleted cohort row ; curqual = ",curqual))
     SET reply->a_c_results[cohort_d_l_func_ssindex].cohorts[cohort_d_l_func_csindex].cohortstatus =
     "S"
    ELSE
     CALL echo(build("failed to logically delete cohort row ; curqual = ",curqual))
     SET reply->a_c_results[cohort_d_l_func_ssindex].cohorts[cohort_d_l_func_csindex].cohortstatus =
     "F"
    ENDIF
   ENDIF
  ENDIF
 ELSE
  SET reply->a_c_results[cohort_d_l_func_ssindex].cohorts[cohort_d_l_func_csindex].cohortstatus = "A"
  SET problemdescriptionsize = size(reply->probdesc,5)
  SET problemdescriptionsize = (problemdescriptionsize+ 1)
  SET stat = alterlist(reply->probdesc,problemdescriptionsize)
  SET reply->probdesc[problemdescriptionsize].str = build("The [",request->ss[cohort_d_l_func_ssindex
   ].cs[cohort_d_l_func_csindex].cohort_label,"] cohort of the [",request->ss[cohort_d_l_func_ssindex
   ].stratum_label,"] stratum cannot be deleted because there are already (",
   nbrofassigns,") patients enrolled on this cohort")
 ENDIF
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
 SET debug_code_cntd = size(reply->debug,5)
 SET debug_echo_i = 0
 FOR (debug_echo_i = 1 TO debug_code_cntd)
   CALL echo(build("Error#",debug_echo_i,"[",reply->debug[debug_echo_i].str,"]"))
 ENDFOR
END GO
