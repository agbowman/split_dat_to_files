CREATE PROGRAM ct_del_log_prot_stratum:dba
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
 SET ss_size = size(request->ss,5)
 SET reply->status_data.status = "F"
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 SET stat = alterlist(reply->deleteresults,ss_size)
 CALL echo(build("Ss_Size= ",ss_size))
 FOR (i = 1 TO ss_size)
   SET reply->deleteresults[i].status = "F"
   CALL echo(build("locking the prot_stratum row for logical delete"))
   SELECT INTO "nl:"
    pr_str.*
    FROM prot_stratum pr_str
    WHERE (pr_str.stratum_id=request->ss[i].stratum_id)
     AND pr_str.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    WITH nocounter, forupdate(pr_str)
   ;end select
   IF (curqual=1)
    CALL echo(build("YES-locked stratum row to logically delete;curqual=",curqual))
    SET continue = true
   ELSE
    CALL echo(build("NO-locked stratum row to logically delete;curqual=",curqual))
    SET continue = false
    SET reply->deleteresults[i].status = "L"
   ENDIF
   IF (continue=true)
    SET continue = false
    CALL echo("StratumDoUpdate = TRUE")
    UPDATE  FROM prot_stratum pr_str
     SET pr_str.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pr_str.updt_cnt = (pr_str
      .updt_cnt+ 1), pr_str.updt_applctx = reqinfo->updt_applctx,
      pr_str.updt_task = reqinfo->updt_task, pr_str.updt_id = reqinfo->updt_id, pr_str.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     WHERE (pr_str.stratum_id=request->ss[i].stratum_id)
      AND pr_str.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     WITH nocounter
    ;end update
    IF (curqual=1)
     SET continue = true
     CALL echo(build("successfully logically deleted stratum row ; curqual = ",curqual))
     CALL echo(build("locking the prot_cohort rows for logical delete"))
     SELECT INTO "nl:"
      pr_coh.*
      FROM prot_cohort pr_coh
      WHERE (pr_coh.stratum_id=request->ss[i].stratum_id)
       AND pr_coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      WITH nocounter, forupdate(pr_coh)
     ;end select
     IF (curqual > 0)
      CALL echo(build("successfully locked row(s) to update ; curqual = ",curqual))
      SET continue = false
      UPDATE  FROM prot_cohort pr_coh
       SET pr_coh.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pr_coh.updt_cnt = (pr_coh
        .updt_cnt+ 1), pr_coh.updt_applctx = reqinfo->updt_applctx,
        pr_coh.updt_task = reqinfo->updt_task, pr_coh.updt_id = reqinfo->updt_id, pr_coh.updt_dt_tm
         = cnvtdatetime(curdate,curtime3)
       WHERE (pr_coh.stratum_id=request->ss[i].stratum_id)
        AND pr_coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
       WITH nocounter
      ;end update
      IF (curqual=1)
       CALL echo(build("successfully logically deleted cohort row(s) ; curqual = ",curqual))
       SET continue = true
      ELSE
       CALL echo(build("failed to logically delete cohort row(s) ; curqual = ",curqual))
       SET continue = false
       SET reply->deleteresults[i].status = "F"
      ENDIF
     ENDIF
    ELSE
     CALL echo(build("failed to logically deleted stratum row ; curqual = ",curqual))
     SET reply->deleteresults[i].status = "F"
    ENDIF
   ENDIF
   IF (continue=true)
    COMMIT
    CALL echo("COMMIT")
    SET reply->deleteresults[i].status = "S"
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
