CREATE PROGRAM aps_clean_rpt_que:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD del(
   1 rpt_qual[*]
     2 report_id = f8
 )
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET failed = 0
 SET verified_cd = 0.0
 SET canceled_cd = 0.0
 SET corrected_cd = 0.0
 SET signinproc_cd = 0.0
 SET csigninproc_cd = 0.0
 SET total_cnt = 0
 SET delete_cnt = 0
 SET stat = alterlist(del->rpt_qual,1)
 SELECT INTO "nl:"
  cv.cdf_meaning
  FROM code_value cv
  WHERE 1305=cv.code_set
   AND cv.cdf_meaning IN ("VERIFIED", "CANCEL", "CORRECTED", "SIGNINPROC", "CSIGNINPROC")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "VERIFIED":
     verified_cd = cv.code_value
    OF "CANCEL":
     canceled_cd = cv.code_value
    OF "CORRECTED":
     corrected_cd = cv.code_value
    OF "SIGNINPROC":
     signinproc_cd = cv.code_value
    OF "CSIGNINPROC":
     csigninproc_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = (failed+ 1)
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE 1305")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  rqr.report_queue_cd, cr.report_id, cr.status_cd
  FROM report_queue_r rqr,
   case_report cr
  PLAN (rqr
   WHERE (request->report_queue_cd=rqr.report_queue_cd))
   JOIN (cr
   WHERE rqr.report_id=cr.report_id)
  HEAD REPORT
   total_cnt = 0, delete_cnt = 0
  DETAIL
   total_cnt = (total_cnt+ 1)
   IF (cr.status_cd IN (verified_cd, canceled_cd, corrected_cd, signinproc_cd, csigninproc_cd))
    delete_cnt = (delete_cnt+ 1), stat = alterlist(del->rpt_qual,delete_cnt), del->rpt_qual[
    delete_cnt].report_id = cr.report_id
   ENDIF
  WITH nocounter
 ;end select
 IF (delete_cnt > 0)
  DELETE  FROM report_queue_r rqr,
    (dummyt d  WITH seq = value(delete_cnt))
   SET rqr.seq = 1
   PLAN (d)
    JOIN (rqr
    WHERE (request->report_queue_cd=rqr.report_queue_cd)
     AND (del->rpt_qual[d.seq].report_id=rqr.report_id))
  ;end delete
  IF (curqual=0)
   SET failed = (failed+ 1)
   CALL handle_errors("DELETE","F","TABLE","REPORT_QUEUE_R")
   GO TO exit_script
  ENDIF
  IF (delete_cnt=total_cnt)
   DELETE  FROM code_value c
    WHERE (c.code_value=request->report_queue_cd)
     AND c.code_set=1319
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET failed = (failed+ 1)
    CALL handle_errors("DELETE","F","TABLE","CODE_VALUE")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (failed > 0)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
