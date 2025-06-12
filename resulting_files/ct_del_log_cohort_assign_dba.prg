CREATE PROGRAM ct_del_log_cohort_assign:dba
 RECORD reply(
   1 reg_status = c1
   1 elig_status = c1
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
 SET reply->status_data.status = "F"
 SET reply->reg_status = "Z"
 SET reply->elig_status = "Z"
 SET cohortid = 0.0
 SET toupdatecohortid = 0.0
 SET s_c_s_func__status = "F"
 IF ((request->reg_id > 0))
  SELECT INTO "nl:"
   a_r.*
   FROM assign_reg_reltn a_r
   WHERE (a_r.reg_id=request->reg_id)
    AND a_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   DETAIL
    cohortid = a_r.cohort_id
   WITH nocounter, forupdate(a_r)
  ;end select
  IF (curqual=1)
   CALL echo("found row via reg_id")
   UPDATE  FROM assign_reg_reltn a_r
    SET a_r.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), a_r.updt_cnt = (a_r.updt_cnt+ 1),
     a_r.updt_applctx = reqinfo->updt_applctx,
     a_r.updt_task = reqinfo->updt_task, a_r.updt_id = reqinfo->updt_id, a_r.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (a_r.reg_id=request->reg_id)
     AND a_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->reg_status = "F"
    CALL echo("failed to deleted row found via reg_id")
   ELSE
    SET reply->reg_status = "S"
    CALL echo("successfully deleted row found via reg_id")
   ENDIF
  ENDIF
 ENDIF
 IF ((request->pt_elig_tracking_id > 0))
  SELECT INTO "nl:"
   a_e.*
   FROM assign_elig_reltn a_e
   WHERE (a_e.pt_elig_tracking_id=request->pt_elig_tracking_id)
    AND a_e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   DETAIL
    cohortid = a_e.cohort_id
   WITH nocounter, forupdate(a_e)
  ;end select
  IF (curqual=1)
   CALL echo("found row via pt_elig_tracking_id")
   UPDATE  FROM assign_elig_reltn a_e
    SET a_e.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), a_e.updt_cnt = (a_e.updt_cnt+ 1),
     a_e.updt_applctx = reqinfo->updt_applctx,
     a_e.updt_task = reqinfo->updt_task, a_e.updt_id = reqinfo->updt_id, a_e.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (a_e.pt_elig_tracking_id=request->pt_elig_tracking_id)
     AND a_e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL echo("Failed to delete row found via pt_elig_tracking_id")
    SET reply->elig_status = "F"
   ELSE
    CALL echo("successfully deleted row found via pt_elig_tracking_id")
    SET reply->reg_status = "S"
   ENDIF
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = false
 IF ((reply->reg_status != "F"))
  IF ((reply->elig_status != "F"))
   IF (cohortid > 0.0)
    SET toupdatecohortid = cohortid
    IF (s_c_s_func__status="S")
     CALL echo("OKAY AT END")
     SET reply->status_data.status = "S"
     SET reqinfo->commit_ind = true
    ELSE
     CALL echo("FAILED AT END")
    ENDIF
   ENDIF
  ENDIF
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
END GO
