CREATE PROGRAM cv_utl_cases_wo_surgdt:dba
 PROMPT
  "Output Device(Mine)" = "mine"
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET failure = "F"
 DECLARE cv_null_date = vc
 SET cv_null_date = "31-DEC-2100 00:00:00"
 DECLARE cv_get_case_result_dt_tm_q8() = c22
 DECLARE cv_get_case_result_dt_tm_str() = c25
 SELECT INTO  $1
  cv_get_case_result_dt_tm_str(cc.cv_case_id,"ST01SURGDT"), *
  FROM cv_case cc
  WHERE cnvtdatetime(cv_get_case_result_dt_tm_q8(cc.cv_case_id,"ST01SURGDT"))=cnvtdatetime(
   cv_null_date)
 ;end select
#exit_script
 IF (failure="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 DECLARE cv_log_destroyhandle(dummy=i2) = null
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE cv_log_destroyhandle(dummy)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt = (cv_log_handle_cnt - 1)
   ENDIF
 END ;Subroutine
END GO
