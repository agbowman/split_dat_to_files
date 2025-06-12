CREATE PROGRAM ct_del_log_prot_cohort:dba
 RECORD reply(
   1 deleteresults[*]
     2 status = c1
   1 debug = vc
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
 SET false = 0
 SET true = 1
 SET cs_size = size(request->cs,5)
 SET reply->status_data.status = "F"
 SET stratumid = 0.0
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 SET stat = alterlist(reply->deleteresults,cs_size)
 CALL echo(build("Cs_Size= ",cs_size))
 FOR (i = 1 TO cs_size)
   SET reply->deleteresults[i].status = "F"
   SET continue = false
   CALL echo(build("locking the prot_cohort row for logical delete"))
   SELECT INTO "nl:"
    pr_coh.*
    FROM prot_cohort pr_coh
    WHERE (pr_coh.cohort_id=request->cs[i].cohort_id)
     AND pr_coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    WITH nocounter, forupdate(pr_coh)
   ;end select
   IF (curqual=1)
    CALL echo(build("successfully locked row to logically delete ; curqual = ",curqual))
    SET continue = true
   ELSE
    SET reply->deleteresults[i].status = "L"
   ENDIF
   IF (continue=true)
    SET continue = false
    UPDATE  FROM prot_cohort pr_coh
     SET pr_coh.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pr_coh.updt_cnt = (pr_coh
      .updt_cnt+ 1), pr_coh.updt_applctx = reqinfo->updt_applctx,
      pr_coh.updt_task = reqinfo->updt_task, pr_coh.updt_id = reqinfo->updt_id, pr_coh.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     WHERE (pr_coh.cohort_id=request->cs[i].cohort_id)
      AND pr_coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     WITH nocounter
    ;end update
    IF (curqual=1)
     CALL echo(build("successfully logically deleted cohort row ; curqual = ",curqual))
     SET continue = true
    ELSE
     CALL echo(build("failed to logically delete cohort row ; curqual = ",curqual))
     SET reply->deleteresults[i].status = "F"
    ENDIF
   ENDIF
   IF (continue=true)
    SET reply->deleteresults[i].status = "S"
    COMMIT
    CALL echo("COMMIT")
   ELSE
    ROLLBACK
    CALL echo("ROLLBACK")
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
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
END GO
