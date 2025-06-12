CREATE PROGRAM dm_cp_get_cr_rows:dba
 SELECT INTO "nl:"
  cr.rowid
  FROM chart_request cr,
   chart_print_queue cpq
  PLAN (cr
   WHERE cr.dist_run_dt_tm <= cnvtdatetime(work_array->work_element[we_ndx].wk_dist_run_dt_tm)
    AND (cr.encntr_id=work_array->work_element[we_ndx].wk_encntr_id)
    AND parser(trim(v_interval_clause))
    AND parser(trim(v_chart_req_qual))
    AND ((cnvtdatetime((curdate - v_days_old_cutoff),curtime3) >= cr.request_dt_tm) OR (cnvtdatetime(
    (curdate - v_days_old_cutoff),curtime3) >= cr.updt_dt_tm))
    AND cr.chart_status_cd IN (v_successful_cd, v_queued_cd)
    AND (cr.chart_request_id < work_array->work_element[we_ndx].wk_chart_request_id)
    AND cr.chart_request_id != 0)
   JOIN (cpq
   WHERE cpq.request_id=outerjoin(cr.chart_request_id)
    AND cpq.queue_status_cd=outerjoin(v_spooled_cd))
  ORDER BY cr.chart_request_id, cpq.batch_id DESC
  HEAD REPORT
   req_cnt = 0
  HEAD cr.chart_request_id
   IF (((cr.chart_status_cd=v_successful_cd
    AND cpq.chart_queue_id=0) OR (((cr.chart_status_cd=v_queued_cd
    AND cpq.queue_status_cd=v_spooled_cd) OR (cr.chart_status_cd=v_successful_cd
    AND cpq.chart_queue_id > 0
    AND cpq.queue_status_cd=v_spooled_cd)) )) )
    req_cnt = (req_cnt+ 1)
    IF (mod(req_cnt,100)=1)
     stat = alterlist(tmp_reply->rows,(req_cnt+ 99))
    ENDIF
    tmp_reply->rows[req_cnt].row_id = cr.rowid
   ENDIF
  FOOT  cr.chart_request_id
   do_nothing = 0
  FOOT REPORT
   stat = alterlist(tmp_reply->rows,req_cnt)
  WITH nocounter
 ;end select
END GO
