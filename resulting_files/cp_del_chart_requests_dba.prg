CREATE PROGRAM cp_del_chart_requests:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD log_rec
 RECORD log_rec(
   1 qual[*]
     2 statement = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET error_msg = fillstring(132," ")
 SET error_check = error(error_msg,1)
 SET failed = "F"
 SET beg_time = cnvtdatetime(curdate,curtime3)
 SET end_time = cnvtdatetime(curdate,curtime3)
 SET log_cnt = 0
 CALL update_log("*******************************************")
 CALL update_log(build("BEGIN -- CP_DEL_CHART_REQUESTS"," - ",format(beg_time,
    "mm/dd/yyyy hh:mm:ss;;d")))
 CALL update_log(build("MEMORY AVAILABLE (STARTING) >> ",curmem))
 SET code_value1 = 0.0
 SET cdf_meaning1 = fillstring(12," ")
 SET code_set1 = 0
 SET code_set1 = 18609
 SET cdf_meaning1 = "SUCCESSFUL"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET successful_cd = code_value1
 SET days_old = 0
 SET days_old = cnvtint(request->batch_selection)
 IF (days_old < 1)
  SET days_old = 30
 ENDIF
 CALL update_log(build("DAYS_OLD = ",days_old))
 FREE SET request
 RECORD request(
   1 qual[*]
     2 chart_request_id = f8
 )
 CALL echo("*****START**********")
 SELECT INTO "nl:"
  cr.chart_request_id
  FROM chart_request cr
  WHERE cr.chart_status_cd IN (successful_cd, 0)
   AND cr.request_type IN (1, 2)
   AND cr.chart_request_id > 0
   AND cr.mcis_ind IN (0, null)
   AND datetimediff(cnvtdatetime(curdate,curtime3),cr.request_dt_tm) >= days_old
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,1000)=1)
    stat = alterlist(request->qual,(count1+ 999)),
    CALL update_log(build("REQUEST REC =",count1," RECORDS - Memory = ",curmem))
   ENDIF
   request->qual[count1].chart_request_id = cr.chart_request_id
  FOOT REPORT
   stat = alterlist(request->qual,count1)
  WITH nocounter
 ;end select
 SET size_list = 0
 SET size_list = size(request->qual,5)
 CALL update_log(build("FINAL COUNT OF ID'S TO DELETE = ",size_list))
 CALL echo("*********SELECT ! ************")
 SET x = 0
 DECLARE mod_value_delete = i4
 SET mod_value_delete = 1000
 IF (size_list > 0)
  FOR (x = 1 TO size_list)
    CALL echo(x)
    CALL echo("**")
    DELETE  FROM chart_printed_sections cr
     SET cr.seq = 1
     WHERE (cr.chart_request_id=request->qual[x].chart_request_id)
    ;end delete
    DELETE  FROM chart_print_queue cr
     SET cr.seq = 1
     WHERE (cr.request_id=request->qual[x].chart_request_id)
    ;end delete
    DELETE  FROM chart_request_audit cr
     SET cr.seq = 1
     WHERE (cr.chart_request_id=request->qual[x].chart_request_id)
    ;end delete
    DELETE  FROM chart_request_encntr cr
     SET cr.seq = 1
     WHERE (cr.chart_request_id=request->qual[x].chart_request_id)
    ;end delete
    DELETE  FROM chart_request_event cr
     SET cr.seq = 1
     WHERE (cr.chart_request_id=request->qual[x].chart_request_id)
    ;end delete
    DELETE  FROM chart_request_section cr
     SET cr.seq = 1
     WHERE (cr.chart_request_id=request->qual[x].chart_request_id)
    ;end delete
    DELETE  FROM chart_req_inerr_event cr
     SET cr.seq = 1
     WHERE (cr.chart_request_id=request->qual[x].chart_request_id)
    ;end delete
    DELETE  FROM chart_serv_log cr
     SET cr.seq = 1
     WHERE (cr.chart_request_id=request->qual[x].chart_request_id)
    ;end delete
    DELETE  FROM chart_request cr
     SET cr.seq = 1
     WHERE (cr.chart_request_id=request->qual[x].chart_request_id)
    ;end delete
    IF (mod(x,mod_value_delete)=0)
     CALL update_log(build("DELETED COUNT = ",x))
     COMMIT
     CALL echo("***COMMIT DONE****")
     CALL echo("****SEE ABOVE***")
     CALL echo("***REDUNDANT****")
    ENDIF
  ENDFOR
 ELSE
  CALL update_log("NO ID'S TO DELETE, EXITING.")
 ENDIF
 CALL echorecord(request)
#exit_script
 CALL update_log(build("MEMORY AVAILABLE (END) >> ",curmem))
 SET error_chk = 1
 WHILE (error_chk > 0)
   SET error_chk = error(error_msg,0)
   SET msg_size = size(trim(error_msg),1)
   IF (error_chk != 0)
    SET failed = "T"
    CALL echo(error_msg)
   ENDIF
 ENDWHILE
 IF (size_list > 0
  AND failed="F")
  CALL update_log(build("SUCCESSFULLY DELETE CR/CRP ID'S = ",size_list))
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CHART_REQUEST"
  SET msg = fillstring(120," ")
  SET msg = concat("# OF SUCCESSFULLY DELETED CR/CRP ID'S = ",cnvtstring(size_list))
  SET reply->status_data.subeventstatus[1].targetobjectvalue = msg
  COMMIT
 ELSEIF (size_list=0
  AND failed="F")
  CALL update_log(build("NO ROWS SELECTED TO DELETE"))
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CHART_REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO ROWS TO DELETE"
 ELSEIF (failed="T")
  CALL update_log("ERRORS IN CP_DEL_CHART_REQUESTS")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CHART_REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  ROLLBACK
 ENDIF
 SET end_time = cnvtdatetime(curdate,curtime3)
 CALL update_log(build("END -- CP_DEL_CHART_REQUESTS"," - ",format(end_time,"mm/dd/yyyy hh:mm:ss;;d")
   ))
 SET exec_time = 0
 SET exec_time = datetimediff(cnvtdatetime(end_time),cnvtdatetime(beg_time))
 SET exec_time = ((exec_time * 24) * 60)
 CALL update_log(build("Total Execution Time = ",exec_time," MINUTES"))
 SET file_name = concat("cer_temp:cr_purge_",format(curdate,"MMDD;;d"),".log")
 SELECT INTO value(file_name)
  d.seq
  FROM dummyt d
  DETAIL
   FOR (x = 1 TO log_cnt)
     col 1, log_rec->qual[x].statement, row + 1
   ENDFOR
  WITH maxcol = 150, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
 SUBROUTINE update_log(statement)
   CALL echo(build("ECHO-> ",statement))
   SET cur_time = cnvtdatetime(curdate,curtime3)
   SET time_message = fillstring(100," ")
   SET time_message = build(format(cur_time,"mm/dd/yyyy hh:mm:ss;;d")," - ")
   SET log_cnt = (log_cnt+ 1)
   SET stat = alterlist(log_rec->qual,log_cnt)
   SET log_rec->qual[log_cnt].statement = build(time_message,statement)
 END ;Subroutine
END GO
