CREATE PROGRAM ct_get_cohort_assign:dba
 RECORD reply(
   1 cohort_id = f8
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
 SET reply->assignstatus = "F"
 IF ((request->reg_id > 0))
  CALL echo("try getting cohort_id via reg table")
  SET continue = false
  SELECT INTO "nl:"
   a_r.*
   FROM assign_reg_reltn a_r
   WHERE (a_r.reg_id=request->reg_id)
    AND a_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   DETAIL
    reply->cohort_id = a_r.cohort_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->cohort_id=0.0))
  IF ((request->pt_elig_tracking_id > 0))
   CALL echo("try getting cohort_id via elig table")
   SELECT INTO "nl:"
    a_e.*
    FROM assign_elig_reltn a_e
    WHERE (a_e.pt_elig_tracking_id=request->pt_elig_tracking_id)
     AND a_e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    DETAIL
     reply->cohort_id = a_r.cohort_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((reply->cohort_id=0.0))
  SET reply->assignstatus = "Z"
 ELSE
  SET reply->assignstatus = "S"
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
