CREATE PROGRAM aps_get_clean_rpt_queues:dba
 RECORD reply(
   1 code_value_counter = i4
   1 code_value_qual[10]
     2 code_value = f8
     2 display = c40
     2 description = vc
     2 cdf_meaning = c12
     2 active_ind = i2
     2 primary_ind = i2
     2 updt_cnt = i4
     2 collation_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD del_no_cv(
   1 qual[*]
     2 report_queue_cd = f8
     2 report_id = f8
 )
 RECORD del(
   1 queue_qual[*]
     2 report_queue_cd = f8
     2 rpt_qual[*]
       3 report_id = f8
 )
#script
 SET reply->status_data.status = "F"
 SET err_cnt = 0
 SET x = 0
 SET verified_cd = 0.0
 SET canceled_cd = 0.0
 SET corrected_cd = 0.0
 SET signinproc_cd = 0.0
 SET csigninproc_cd = 0.0
 SET queue_cnt = 0
 SET total_cnt = 0
 SET delete_cnt = 0
 SELECT INTO "nl:"
  cv.code_value, rqr.report_queue_cd, rqr.report_id
  FROM report_queue_r rqr,
   code_value cv,
   dummyt d
  PLAN (rqr)
   JOIN (d)
   JOIN (cv
   WHERE cv.code_set=1319
    AND rqr.report_queue_cd=cv.code_value)
  DETAIL
   delete_cnt = (delete_cnt+ 1), stat = alterlist(del_no_cv->qual,delete_cnt), del_no_cv->qual[
   delete_cnt].report_queue_cd = rqr.report_queue_cd,
   del_no_cv->qual[delete_cnt].report_id = rqr.report_id
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 IF (delete_cnt > 0)
  DELETE  FROM report_queue_r rqr,
    (dummyt d  WITH seq = value(delete_cnt))
   SET rqr.seq = 1
   PLAN (d)
    JOIN (rqr
    WHERE (del_no_cv->qual[d.seq].report_queue_cd=rqr.report_queue_cd)
     AND (del_no_cv->qual[d.seq].report_id=rqr.report_id))
  ;end delete
  IF (curqual=0)
   SET err_cnt = (err_cnt+ 1)
   CALL handle_errors("DELETE","F","TABLE","NO MATCHING CODE VALUE")
   GO TO exit_script
  ENDIF
 ENDIF
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
  SET err_cnt = (err_cnt+ 1)
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE 1305")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE code_set=1319
  DETAIL
   queue_cnt = (queue_cnt+ 1), stat = alterlist(del->queue_qual,queue_cnt), del->queue_qual[queue_cnt
   ].report_queue_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alter(reply->code_value_qual,1)
  SET reply->code_value_counter = 0
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO queue_cnt)
   SET total_cnt = 0
   SET delete_cnt = 0
   SELECT INTO "nl:"
    rqr.report_queue_cd, cr.report_id
    FROM report_queue_r rqr,
     case_report cr
    PLAN (rqr
     WHERE (del->queue_qual[x].report_queue_cd=rqr.report_queue_cd))
     JOIN (cr
     WHERE rqr.report_id=cr.report_id)
    DETAIL
     total_cnt = (total_cnt+ 1)
     IF (cr.status_cd IN (verified_cd, canceled_cd, corrected_cd, signinproc_cd, csigninproc_cd))
      delete_cnt = (delete_cnt+ 1), stat = alterlist(del->queue_qual[x].rpt_qual,delete_cnt), del->
      queue_qual[x].rpt_qual[delete_cnt].report_id = cr.report_id
     ENDIF
    WITH nocounter
   ;end select
   IF (delete_cnt > 0)
    DELETE  FROM report_queue_r rqr,
      (dummyt d  WITH seq = value(delete_cnt))
     SET rqr.seq = 1
     PLAN (d)
      JOIN (rqr
      WHERE (del->queue_qual[x].report_queue_cd=rqr.report_queue_cd)
       AND (del->queue_qual[x].rpt_qual[d.seq].report_id=rqr.report_id))
    ;end delete
    IF (curqual=0)
     SET err_cnt = (err_cnt+ 1)
     CALL handle_errors("DELETE","F","TABLE","REPORT_QUEUE_R")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (delete_cnt=total_cnt)
    DELETE  FROM code_value c
     WHERE (c.code_value=del->queue_qual[x].report_queue_cd)
      AND c.code_set=1319
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET err_cnt = (err_cnt+ 1)
     CALL handle_errors("DELETE","F","TABLE","CODE_VALUE")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  c.code_value, c.display, c.description,
  c.updt_cnt
  FROM code_value c
  WHERE (request->code_set=c.code_set)
  HEAD REPORT
   reply->code_value_counter = 0, x = 0
  DETAIL
   x = (x+ 1)
   IF (mod(x,10)=1
    AND x != 1)
    stat = alter(reply->code_value_qual,(x+ 9))
   ENDIF
   reply->code_value_qual[x].code_value = c.code_value, reply->code_value_qual[x].display = c.display,
   reply->code_value_qual[x].description = c.description,
   reply->code_value_qual[x].cdf_meaning = c.cdf_meaning, reply->code_value_qual[x].active_ind = c
   .active_ind, reply->code_value_qual[x].updt_cnt = c.updt_cnt,
   reply->code_value_qual[x].collation_seq = c.collation_seq, reply->code_value_counter = x
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alter(reply->code_value_qual,1)
  SET reply->code_value_counter = 0
  GO TO exit_script
 ELSE
  SET stat = alter(reply->code_value_qual,x)
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET err_cnt = (err_cnt+ 1)
   IF (err_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,err_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[err_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (err_cnt > 0)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
