CREATE PROGRAM dm_cp_chart_req_olddist_rows:dba
 FREE SET tmp_reply
 RECORD tmp_reply(
   1 rows[*]
     2 row_id = vc
 )
 SET reply->status_data.status = "F"
 FREE SET work_array
 RECORD work_array(
   1 work_element[*]
     2 wk_encntr_id = f8
     2 wk_distribution_id = f8
     2 wk_dist_run_type_cd = f8
     2 wk_dist_run_dt_tm = dq8
     2 wk_reader_group = c15
     2 wk_chart_request_id = f8
 )
 FREE RECORD log_rec
 RECORD log_rec(
   1 qual[*]
     2 statement = vc
 )
 DECLARE v_days_old_cutoff = f8 WITH noconstant(- (1.0))
 DECLARE v_days_to_keep = f8 WITH noconstant(0.0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 DECLARE v_failed = c1 WITH noconstant("F")
 DECLARE v_interim_any_cd = f8 WITH noconstant(0.0)
 DECLARE v_interim_cum_cd = f8 WITH noconstant(0.0)
 DECLARE v_periodic_cd = f8 WITH noconstant(0.0)
 DECLARE v_cumulative_cd = f8 WITH noconstant(0.0)
 DECLARE v_addendum_cd = f8 WITH noconstant(0.0)
 DECLARE v_cumaddm_cd = f8 WITH noconstant(0.0)
 DECLARE v_splitcum_cd = f8 WITH noconstant(0.0)
 DECLARE v_cutoff_cd = f8 WITH noconstant(0.0)
 DECLARE v_replacement_cd = f8 WITH noconstant(0.0)
 DECLARE v_interval_clause = vc
 DECLARE v_chart_req_qual = vc
 DECLARE v_num_rep = i4 WITH noconstant(0)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog," ",curcclrev)
 DECLARE log_cnt = i4 WITH noconstant(0)
 SET cnt = 0
 SET beg_time = cnvtdatetime("01-jan-1800")
 SET beg_time = cnvtdatetime(curdate,curtime3)
 SET end_time = cnvtdatetime("01-jan-1800")
 SET end_time = cnvtdatetime(curdate,curtime3)
 DECLARE mod_value = i4
 SET mod_value = 10000
 CALL update_log("*******************************************")
 CALL update_log(build("BEGIN -- CP_DELETE_OLD_DISTR_ROWS"," - ",format(beg_time,
    "mm/dd/yyyy hh:mm:ss;;d")))
 CALL update_log(build("MEMORY AVAILABLE (STARTING) >> ",curmem))
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="LOOKBACKDAYS"))
    SET v_days_old_cutoff = cnvtint(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 CALL update_log(build("DAYS_OLD_CUTOFF = ",v_days_old_cutoff))
 IF (v_days_old_cutoff < 1)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"LBDAYS","%1 %2 %3","sss",
   "You must look back at least one day.  You entered ",
   nullterm(trim(cnvtstring(v_days_old_cutoff),3))," days or did not enter any value.")
 ELSE
  SET reply->table_name = "CHART_REQUEST"
  SET reply->rows_between_commit = 100
  SET v_addendum_cd = uar_get_code_by("MEANING",22550,"ADDENDUM")
  SET v_interim_any_cd = uar_get_code_by("MEANING",22550,"INTERIM-ANY")
  SET v_interim_cum_cd = uar_get_code_by("MEANING",22550,"INTERIM-CUM")
  SET v_cumulative_cd = uar_get_code_by("MEANING",22550,"CUMULATIVE")
  SET v_periodic_cd = uar_get_code_by("MEANING",22550,"PERIODIC")
  SET v_cumaddm_cd = uar_get_code_by("MEANING",22550,"CUM ADDENDUM")
  SET v_splitcum_cd = uar_get_code_by("MEANING",22550,"SPLIT CUM")
  SET v_cutoff_cd = uar_get_code_by("MEANING",22550,"CUTOFF")
  SET v_replacement_cd = uar_get_code_by("MEANING",22550,"REPLACEMENT")
  SET v_successful_cd = uar_get_code_by("MEANING",18609,"SUCCESSFUL")
  SET v_queued_cd = uar_get_code_by("MEANING",18609,"QUEUED")
  SET v_spooled_cd = uar_get_code_by("MEANING",28800,"SPOOLED")
  SELECT INTO "nl:"
   cr.encntr_id, cr.distribution_id, cr.dist_run_type_cd,
   cr.dist_run_dt_tm, cr.chart_request_id
   FROM chart_request cr
   WHERE ((cr.request_type=4) OR (cr.request_type=2
    AND cr.mcis_ind=1))
   ORDER BY cr.encntr_id, cr.distribution_id, cr.dist_run_type_cd,
    cr.dist_run_dt_tm DESC, cr.chart_request_id DESC
   HEAD REPORT
    cnt = 0
   HEAD cr.encntr_id
    row + 0
   HEAD cr.distribution_id
    latest_int_dttm = cnvtdatetime("01-jan-1800"), latest_per_dttm = cnvtdatetime("01-jan-1800"),
    latest_scm_dttm = cnvtdatetime("01-jan-1800"),
    latest_cum_dttm = cnvtdatetime("01-jan-1800"), latest_cut_dttm = cnvtdatetime("01-jan-1800"),
    latest_rep_dttm = cnvtdatetime("01-jan-1800"),
    latest_add_dttm = cnvtdatetime("01-jan-1800"), int_request_id = 0.0, per_request_id = 0.0,
    cum_request_id = 0.0, add_request_id = 0.0, scm_request_id = 0.0,
    cut_request_id = 0.0, rep_request_id = 0.0
   HEAD cr.dist_run_type_cd
    IF (cr.dist_run_type_cd IN (v_interim_any_cd, v_interim_cum_cd))
     IF (cnvtdatetime(cr.dist_run_dt_tm) > cnvtdatetime(latest_int_dttm))
      latest_int_dttm = cr.dist_run_dt_tm, interim_cd = cr.dist_run_type_cd
     ENDIF
    ELSEIF (cr.dist_run_type_cd=v_periodic_cd)
     latest_per_dttm = cr.dist_run_dt_tm
    ELSEIF (cr.dist_run_type_cd=v_splitcum_cd)
     latest_scm_dttm = cr.dist_run_dt_tm
    ELSEIF (cr.dist_run_type_cd=v_cumulative_cd)
     latest_cum_dttm = cr.dist_run_dt_tm
    ELSEIF (cr.dist_run_type_cd=v_cutoff_cd)
     latest_cut_dttm = cr.dist_run_dt_tm
    ELSEIF (cr.dist_run_type_cd=v_replacement_cd)
     latest_rep_dttm = cr.dist_run_dt_tm
    ELSEIF (cr.dist_run_type_cd IN (v_addendum_cd, v_cumaddm_cd))
     IF (cnvtdatetime(cr.dist_run_dt_tm) > cnvtdatetime(latest_add_dttm))
      latest_add_dttm = cr.dist_run_dt_tm, addend_cd = cr.dist_run_type_cd
     ENDIF
    ENDIF
   HEAD cr.chart_request_id
    IF (cr.dist_run_type_cd IN (v_interim_any_cd, v_interim_cum_cd))
     IF (cr.chart_request_id > int_request_id)
      int_request_id = cr.chart_request_id
     ENDIF
    ENDIF
    IF (cr.dist_run_type_cd=v_periodic_cd)
     IF (cr.chart_request_id > per_request_id)
      per_request_id = cr.chart_request_id
     ENDIF
    ENDIF
    IF (cr.dist_run_type_cd=v_splitcum_cd)
     IF (cr.chart_request_id > scm_request_id)
      scm_request_id = cr.chart_request_id
     ENDIF
    ENDIF
    IF (cr.dist_run_type_cd=v_cumulative_cd)
     IF (cr.chart_request_id > cum_request_id)
      cum_request_id = cr.chart_request_id
     ENDIF
    ENDIF
    IF (cr.dist_run_type_cd=v_cutoff_cd)
     IF (cr.chart_request_id > cut_request_id)
      cut_request_id = cr.chart_request_id
     ENDIF
    ENDIF
    IF (cr.dist_run_type_cd=v_replacement_cd)
     IF (cr.chart_request_id > rep_request_id)
      rep_request_id = cr.chart_request_id
     ENDIF
    ENDIF
    IF (cr.dist_run_type_cd IN (v_addendum_cd, v_cumaddm_cd))
     IF (cr.chart_request_id > add_request_id)
      add_request_id = cr.chart_request_id
     ENDIF
    ENDIF
   FOOT  cr.distribution_id
    IF (cnvtdatetime(latest_int_dttm) > cnvtdatetime(latest_per_dttm)
     AND cnvtdatetime(latest_int_dttm) > cnvtdatetime(latest_scm_dttm)
     AND cnvtdatetime(latest_int_dttm) > cnvtdatetime(latest_cum_dttm)
     AND cnvtdatetime(latest_int_dttm) > cnvtdatetime(latest_cut_dttm)
     AND cnvtdatetime(latest_int_dttm) > cnvtdatetime(latest_rep_dttm))
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(work_array->work_element,(cnt+ 99))
     ENDIF
     IF (mod(cnt,mod_value)=0)
      CALL update_log(build("WORK_ARRAY =",cnt," RECORDS - Memory = ",curmem))
     ENDIF
     work_array->work_element[cnt].wk_encntr_id = cr.encntr_id, work_array->work_element[cnt].
     wk_distribution_id = cr.distribution_id, work_array->work_element[cnt].wk_dist_run_type_cd =
     interim_cd,
     work_array->work_element[cnt].wk_dist_run_dt_tm = latest_int_dttm, work_array->work_element[cnt]
     .wk_chart_request_id = int_request_id, work_array->work_element[cnt].wk_reader_group = trim(cr
      .reader_group)
    ENDIF
    IF (cnvtdatetime(latest_per_dttm) > cnvtdatetime("01-jan-1800"))
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(work_array->work_element,(cnt+ 99))
     ENDIF
     IF (mod(cnt,mod_value)=0)
      CALL update_log(build("WORK_ARRAY =",cnt," RECORDS - Memory = ",curmem))
     ENDIF
     work_array->work_element[cnt].wk_encntr_id = cr.encntr_id, work_array->work_element[cnt].
     wk_distribution_id = cr.distribution_id, work_array->work_element[cnt].wk_dist_run_type_cd =
     v_periodic_cd,
     work_array->work_element[cnt].wk_dist_run_dt_tm = latest_per_dttm, work_array->work_element[cnt]
     .wk_chart_request_id = per_request_id, work_array->work_element[cnt].wk_reader_group = trim(cr
      .reader_group)
    ENDIF
    IF (cnvtdatetime(latest_scm_dttm) > cnvtdatetime(latest_cum_dttm)
     AND cnvtdatetime(latest_scm_dttm) > cnvtdatetime(latest_cut_dttm)
     AND cnvtdatetime(latest_scm_dttm) > cnvtdatetime(latest_rep_dttm))
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(work_array->work_element,(cnt+ 99))
     ENDIF
     IF (mod(cnt,mod_value)=0)
      CALL update_log(build("WORK_ARRAY =",cnt," RECORDS - Memory = ",curmem))
     ENDIF
     work_array->work_element[cnt].wk_encntr_id = cr.encntr_id, work_array->work_element[cnt].
     wk_distribution_id = cr.distribution_id, work_array->work_element[cnt].wk_dist_run_type_cd =
     v_splitcum_cd,
     work_array->work_element[cnt].wk_dist_run_dt_tm = latest_scm_dttm, work_array->work_element[cnt]
     .wk_chart_request_id = scm_request_id, work_array->work_element[cnt].wk_reader_group = trim(cr
      .reader_group)
    ENDIF
    IF (cnvtdatetime(latest_cum_dttm) > cnvtdatetime("01-jan-1800"))
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(work_array->work_element,(cnt+ 99))
     ENDIF
     IF (mod(cnt,mod_value)=0)
      CALL update_log(build("WORK_ARRAY =",cnt," RECORDS - Memory = ",curmem))
     ENDIF
     work_array->work_element[cnt].wk_encntr_id = cr.encntr_id, work_array->work_element[cnt].
     wk_distribution_id = cr.distribution_id, work_array->work_element[cnt].wk_dist_run_type_cd =
     v_cumulative_cd,
     work_array->work_element[cnt].wk_dist_run_dt_tm = latest_cum_dttm, work_array->work_element[cnt]
     .wk_chart_request_id = cum_request_id, work_array->work_element[cnt].wk_reader_group = trim(cr
      .reader_group)
    ENDIF
    IF (cnvtdatetime(latest_cut_dttm) > cnvtdatetime("01-jan-1800"))
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(work_array->work_element,(cnt+ 99))
     ENDIF
     IF (mod(cnt,mod_value)=0)
      CALL update_log(build("WORK_ARRAY =",cnt," RECORDS - Memory = ",curmem))
     ENDIF
     work_array->work_element[cnt].wk_encntr_id = cr.encntr_id, work_array->work_element[cnt].
     wk_distribution_id = cr.distribution_id, work_array->work_element[cnt].wk_dist_run_type_cd =
     v_cutoff_cd,
     work_array->work_element[cnt].wk_dist_run_dt_tm = latest_cut_dttm, work_array->work_element[cnt]
     .wk_chart_request_id = cut_request_id, work_array->work_element[cnt].wk_reader_group = trim(cr
      .reader_group)
    ENDIF
    IF (cnvtdatetime(latest_rep_dttm) > cnvtdatetime("01-jan-1800"))
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(work_array->work_element,(cnt+ 99))
     ENDIF
     IF (mod(cnt,mod_value)=0)
      CALL update_log(build("WORK_ARRAY =",cnt," RECORDS - Memory = ",curmem))
     ENDIF
     work_array->work_element[cnt].wk_encntr_id = cr.encntr_id, work_array->work_element[cnt].
     wk_distribution_id = cr.distribution_id, work_array->work_element[cnt].wk_dist_run_type_cd =
     v_replacement_cd,
     work_array->work_element[cnt].wk_dist_run_dt_tm = latest_rep_dttm, work_array->work_element[cnt]
     .wk_chart_request_id = rep_request_id, work_array->work_element[cnt].wk_reader_group = trim(cr
      .reader_group)
    ENDIF
    IF (cnvtdatetime(latest_add_dttm) > cnvtdatetime("01-jan-1800"))
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(work_array->work_element,(cnt+ 99))
     ENDIF
     IF (mod(cnt,mod_value)=0)
      CALL update_log(build("WORK_ARRAY =",cnt," RECORDS - Memory = ",curmem))
     ENDIF
     work_array->work_element[cnt].wk_encntr_id = cr.encntr_id, work_array->work_element[cnt].
     wk_distribution_id = cr.distribution_id, work_array->work_element[cnt].wk_dist_run_type_cd =
     addend_cd,
     work_array->work_element[cnt].wk_dist_run_dt_tm = latest_add_dttm, work_array->work_element[cnt]
     .wk_chart_request_id = add_request_id, work_array->work_element[cnt].wk_reader_group = trim(cr
      .reader_group)
    ENDIF
   FOOT REPORT
    stat = alterlist(work_array->work_element,cnt)
   WITH nocounter
  ;end select
  CALL update_log(build("ENDING WORK_ARRAY = ",cnt," RECORDS - Memory = ",curmem))
  FOR (we_ndx = 1 TO size(work_array->work_element,5))
    SET v_interval_clause = " cr.dist_run_type_cd IN "
    IF ((work_array->work_element[we_ndx].wk_dist_run_type_cd IN (v_interim_any_cd, v_interim_cum_cd)
    ))
     SET v_interval_clause = concat(trim(v_interval_clause,3),"(v_interim_any_cd,v_interim_cum_cd)")
    ELSEIF ((work_array->work_element[we_ndx].wk_dist_run_type_cd=v_periodic_cd))
     SET v_interval_clause = concat(trim(v_interval_clause,3),
      " (v_periodic_cd,v_interim_any_cd,v_interim_cum_cd)")
    ELSEIF ((work_array->work_element[we_ndx].wk_dist_run_type_cd=v_splitcum_cd))
     SET v_interval_clause = concat(trim(v_interval_clause,3),
      " (v_splitcum_cd,v_interim_any_cd,v_interim_cum_cd)")
    ELSEIF ((work_array->work_element[we_ndx].wk_dist_run_type_cd=v_cumulative_cd))
     SET v_interval_clause = concat(trim(v_interval_clause,3),
      " (v_cumulative_cd,v_splitcum_cd,v_interim_any_cd,v_interim_cum_cd)")
    ELSEIF ((work_array->work_element[we_ndx].wk_dist_run_type_cd=v_cutoff_cd))
     SET v_interval_clause = concat(trim(v_interval_clause,3),
      " (v_cutoff_cd,v_splitcum_cd,v_interim_any_cd,v_interim_cum_cd)")
    ELSEIF ((work_array->work_element[we_ndx].wk_dist_run_type_cd=v_replacement_cd))
     SET v_interval_clause = concat(trim(v_interval_clause,3),
      " (v_replacement_cd,v_splitcum_cd,v_interim_any_cd,v_interim_cum_cd)")
    ELSEIF ((work_array->work_element[we_ndx].wk_dist_run_type_cd IN (v_cumaddm_cd, v_addendum_cd)))
     SET v_interval_clause = concat(trim(v_interval_clause,3)," (v_cumaddm_cd,v_addendum_cd)")
    ENDIF
    IF ((work_array->work_element[we_ndx].wk_reader_group=" "))
     SET v_chart_req_qual =
     " cr.distribution_id = work_array->work_element[we_ndx].wk_distribution_id"
    ELSE
     SET v_chart_req_qual =
     " trim(cr.reader_group) = work_array->work_element[we_ndx].wk_reader_group"
    ENDIF
    SET stat = alterlist(tmp_reply->rows,0)
    EXECUTE dm_cp_get_cr_rows
    IF (size(tmp_reply->rows,5) > 0)
     SET stat = alterlist(reply->rows,(v_num_rep+ size(tmp_reply->rows,5)))
     FOR (tr_ndx = 1 TO size(tmp_reply->rows,5))
       SET reply->rows[(v_num_rep+ tr_ndx)].row_id = tmp_reply->rows[tr_ndx].row_id
     ENDFOR
     SET v_num_rep = (v_num_rep+ size(tmp_reply->rows,5))
    ENDIF
  ENDFOR
 ENDIF
 SET v_errmsg2 = fillstring(132," ")
 SET v_err_code2 = 0
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->err_code = v_err_code2
  SET reply->err_msg = v_errmsg2
 ENDIF
 CALL update_log(build("Number of Rows to be deleted = ",size(reply->rows,5)))
 FREE RECORD work_array
 FREE RECORD tmp_reply
 CALL echorecord(reply)
 SET end_time = cnvtdatetime(curdate,curtime3)
 CALL update_log(build("END -- CP_DELETE_OLD_DISTR_ROWS"," - ",format(end_time,
    "mm/dd/yyyy hh:mm:ss;;d")))
 SET exec_time = 0.0
 SET exec_time = cnvtreal(datetimediff(cnvtdatetime(end_time),cnvtdatetime(beg_time)))
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
