CREATE PROGRAM cp_select_delete_rows:dba
 SELECT INTO "nl:"
  cr.chart_request_id
  FROM chart_request cr
  WHERE ((cr.dist_run_dt_tm < cnvtdatetime(work_array->work_element[loop_count].wk_dist_run_dt_tm))
   OR (cr.dist_run_dt_tm=cnvtdatetime(work_array->work_element[loop_count].wk_dist_run_dt_tm)))
   AND (cr.encntr_id=work_array->work_element[loop_count].wk_encntr_id)
   AND parser(trim(interval_clause))
   AND parser(trim(chart_req_qual))
   AND ((datetimediff(cnvtdatetime(curdate,curtime3),cr.request_dt_tm) >= days_old_cutoff) OR (
  datetimediff(cnvtdatetime(curdate,curtime3),cr.updt_dt_tm) >= days_old_cutoff))
   AND cr.chart_status_cd=successful_cd
   AND (cr.chart_request_id < work_array->work_element[loop_count].wk_chart_request_id)
  DETAIL
   request_cnt = (request_cnt+ 1)
   IF (mod(request_cnt,1000)=1)
    stat = alterlist(request->qual,(request_cnt+ 999)),
    CALL update_log(build("WORK_ARRAY =",count1," RECORDS - Memory = ",curmem))
   ENDIF
   request->qual[request_cnt].chart_request_id = cr.chart_request_id
  WITH nocounter
 ;end select
END GO
