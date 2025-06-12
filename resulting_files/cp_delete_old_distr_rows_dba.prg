CREATE PROGRAM cp_delete_old_distr_rows:dba
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
 SET days_old_cutoff = 30
 SET beg_time = cnvtdatetime("01-jan-1800")
 SET beg_time = cnvtdatetime(curdate,curtime3)
 SET end_time = cnvtdatetime("01-jan-1800")
 SET end_time = cnvtdatetime(curdate,curtime3)
 SET message_log = fillstring(200," ")
 SET log_cnt = 0
 CALL update_log("*******************************************")
 CALL update_log(build("BEGIN -- CP_DELETE_OLD_DISTR_ROWS"," - ",format(beg_time,
    "mm/dd/yyyy hh:mm:ss;;d")))
 CALL update_log(build("MEMORY AVAILABLE (STARTING) >> ",curmem))
 DECLARE mod_value = i4
 SET mod_value = 10000
 DECLARE mod_value_delete = i4
 SET mod_value_delete = 1000
 SET error_msg = fillstring(132," ")
 SET error_check = error(error_msg,1)
 SET failed = "F"
 SET count1 = 0
 SET count2 = 0
 SET check_if = 0
 SET loop_count = 0
 SET interim_any_cd = 0.0
 SET interim_cum_cd = 0.0
 SET interim_cd = 0.0
 SET int_request_id = 0.0
 SET periodic_cd = 0.0
 SET per_request_id = 0.0
 SET cumulative_cd = 0.0
 SET cum_request_id = 0.0
 SET addendum_cd = 0.0
 SET add_request_id = 0.0
 SET cumaddm_cd = 0.0
 SET addend_cd = 0.0
 SET splitcum_cd = 0.0
 SET scm_request_id = 0.0
 SET cutoff_cd = 0.0
 SET cut_request_id = 0.0
 SET replacement_cd = 0.0
 SET rep_request_id = 0.0
 SET interval_clause = fillstring(132," ")
 SET chart_req_qual = fillstring(132," ")
 SET request_cnt = 0
 SET unprocessed_cd = 0.0
 SET latest_int_dttm = cnvtdatetime("01-jan-1800")
 SET latest_per_dttm = cnvtdatetime("01-jan-1800")
 SET latest_scm_dttm = cnvtdatetime("01-jan-1800")
 SET latest_cum_dttm = cnvtdatetime("01-jan-1800")
 SET latest_cut_dttm = cnvtdatetime("01-jan-1800")
 SET latest_rep_dttm = cnvtdatetime("01-jan-1800")
 SET latest_add_dttm = cnvtdatetime("01-jan-1800")
 SET code_value1 = 0.0
 SET code_set1 = 0
 SET cdf_meaning1 = fillstring(12," ")
 SET input_option = 0
 SET input_size = 0
 SET input_size = size(request->qual,5)
 SET input_option = cnvtint(request->batch_selection)
 SET req_application = 0
 IF (input_option < 1)
  SET days_old_cutoff = 30
 ELSEIF (input_option >= 1)
  SET days_old_cutoff = input_option
 ENDIF
 CALL update_log(build("DAYS_OLD_CUTOFF = ",days_old_cutoff))
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET code_value1 = 0.0
 SET code_set1 = 22550
 SET cdf_meaning1 = "ADDENDUM"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET addendum_cd = code_value1
 SET code_value1 = 0.0
 SET code_set1 = 22550
 SET cdf_meaning1 = "INTERIM-ANY"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET interim_any_cd = code_value1
 SET code_value1 = 0.0
 SET code_set1 = 22550
 SET cdf_meaning1 = "INTERIM-CUM"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET interim_cum_cd = code_value1
 SET code_value1 = 0.0
 SET code_set1 = 22550
 SET cdf_meaning1 = "CUMULATIVE"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET cumulative_cd = code_value1
 SET code_value1 = 0.0
 SET code_set1 = 22550
 SET cdf_meaning1 = "PERIODIC"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET periodic_cd = code_value1
 SET code_value1 = 0.0
 SET code_set1 = 22550
 SET cdf_meaning1 = "CUM ADDENDUM"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET cumaddm_cd = code_value1
 SET code_value1 = 0.0
 SET code_set1 = 22550
 SET cdf_meaning1 = "SPLIT CUM"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET splitcum_cd = code_value1
 SET code_value1 = 0.0
 SET code_set1 = 22550
 SET cdf_meaning1 = "CUTOFF"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET cutoff_cd = code_value1
 SET code_value1 = 0.0
 SET code_set1 = 22550
 SET cdf_meaning1 = "REPLACEMENT"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET replacement_cd = code_value1
 SET code_value1 = 0.0
 SET code_set1 = 18609
 SET cdf_meaning1 = "SUCCESSFUL"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET successful_cd = code_value1
 SELECT INTO "nl:"
  cr.encntr_id, cr.distribution_id, cr.dist_run_type_cd,
  cr.dist_run_dt_tm, cr.chart_request_id
  FROM chart_request cr
  WHERE ((cr.request_type=4) OR (cr.request_type=2
   AND cr.mcis_ind=1))
  ORDER BY cr.encntr_id, cr.distribution_id, cr.dist_run_type_cd,
   cr.dist_run_dt_tm DESC, cr.chart_request_id DESC
  HEAD REPORT
   count1 = 0, stat = alterlist(work_array->work_element,1)
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
   IF (cr.dist_run_type_cd IN (interim_any_cd, interim_cum_cd))
    IF (cnvtdatetime(cr.dist_run_dt_tm) > cnvtdatetime(latest_int_dttm))
     latest_int_dttm = cr.dist_run_dt_tm, interim_cd = cr.dist_run_type_cd
    ENDIF
   ELSEIF (cr.dist_run_type_cd=periodic_cd)
    latest_per_dttm = cr.dist_run_dt_tm
   ELSEIF (cr.dist_run_type_cd=splitcum_cd)
    latest_scm_dttm = cr.dist_run_dt_tm
   ELSEIF (cr.dist_run_type_cd=cumulative_cd)
    latest_cum_dttm = cr.dist_run_dt_tm
   ELSEIF (cr.dist_run_type_cd=cutoff_cd)
    latest_cut_dttm = cr.dist_run_dt_tm
   ELSEIF (cr.dist_run_type_cd=replacement_cd)
    latest_rep_dttm = cr.dist_run_dt_tm
   ELSEIF (cr.dist_run_type_cd IN (addendum_cd, cumaddm_cd))
    IF (cnvtdatetime(cr.dist_run_dt_tm) > cnvtdatetime(latest_add_dttm))
     latest_add_dttm = cr.dist_run_dt_tm, addend_cd = cr.dist_run_type_cd
    ENDIF
   ENDIF
  HEAD cr.chart_request_id
   IF (cr.dist_run_type_cd IN (interim_any_cd, interim_cum_cd))
    IF (cr.chart_request_id > int_request_id)
     int_request_id = cr.chart_request_id
    ENDIF
   ENDIF
   IF (cr.dist_run_type_cd=periodic_cd)
    IF (cr.chart_request_id > per_request_id)
     per_request_id = cr.chart_request_id
    ENDIF
   ENDIF
   IF (cr.dist_run_type_cd=splitcum_cd)
    IF (cr.chart_request_id > scm_request_id)
     scm_request_id = cr.chart_request_id
    ENDIF
   ENDIF
   IF (cr.dist_run_type_cd=cumulative_cd)
    IF (cr.chart_request_id > cum_request_id)
     cum_request_id = cr.chart_request_id
    ENDIF
   ENDIF
   IF (cr.dist_run_type_cd=cutoff_cd)
    IF (cr.chart_request_id > cut_request_id)
     cut_request_id = cr.chart_request_id
    ENDIF
   ENDIF
   IF (cr.dist_run_type_cd=replacement_cd)
    IF (cr.chart_request_id > rep_request_id)
     rep_request_id = cr.chart_request_id
    ENDIF
   ENDIF
   IF (cr.dist_run_type_cd IN (addendum_cd, cumaddm_cd))
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
    count1 = (count1+ 1)
    IF (mod(count1,100)=1)
     stat = alterlist(work_array->work_element,(count1+ 99))
    ENDIF
    IF (mod(count1,mod_value)=0)
     CALL update_log(build("WORK_ARRAY =",count1," RECORDS - Memory = ",curmem))
    ENDIF
    work_array->work_element[count1].wk_encntr_id = cr.encntr_id, work_array->work_element[count1].
    wk_distribution_id = cr.distribution_id, work_array->work_element[count1].wk_dist_run_type_cd =
    interim_cd,
    work_array->work_element[count1].wk_dist_run_dt_tm = latest_int_dttm, work_array->work_element[
    count1].wk_chart_request_id = int_request_id, work_array->work_element[count1].wk_reader_group =
    trim(cr.reader_group)
   ENDIF
   IF (cnvtdatetime(latest_per_dttm) > cnvtdatetime("01-jan-1800"))
    count1 = (count1+ 1)
    IF (mod(count1,100)=1)
     stat = alterlist(work_array->work_element,(count1+ 99))
    ENDIF
    IF (mod(count1,mod_value)=0)
     CALL update_log(build("WORK_ARRAY =",count1," RECORDS - Memory = ",curmem))
    ENDIF
    work_array->work_element[count1].wk_encntr_id = cr.encntr_id, work_array->work_element[count1].
    wk_distribution_id = cr.distribution_id, work_array->work_element[count1].wk_dist_run_type_cd =
    periodic_cd,
    work_array->work_element[count1].wk_dist_run_dt_tm = latest_per_dttm, work_array->work_element[
    count1].wk_chart_request_id = per_request_id, work_array->work_element[count1].wk_reader_group =
    trim(cr.reader_group)
   ENDIF
   IF (cnvtdatetime(latest_scm_dttm) > cnvtdatetime(latest_cum_dttm)
    AND cnvtdatetime(latest_scm_dttm) > cnvtdatetime(latest_cut_dttm)
    AND cnvtdatetime(latest_scm_dttm) > cnvtdatetime(latest_rep_dttm))
    count1 = (count1+ 1)
    IF (mod(count1,100)=1)
     stat = alterlist(work_array->work_element,(count1+ 99))
    ENDIF
    IF (mod(count1,mod_value)=0)
     CALL update_log(build("WORK_ARRAY =",count1," RECORDS - Memory = ",curmem))
    ENDIF
    work_array->work_element[count1].wk_encntr_id = cr.encntr_id, work_array->work_element[count1].
    wk_distribution_id = cr.distribution_id, work_array->work_element[count1].wk_dist_run_type_cd =
    splitcum_cd,
    work_array->work_element[count1].wk_dist_run_dt_tm = latest_scm_dttm, work_array->work_element[
    count1].wk_chart_request_id = scm_request_id, work_array->work_element[count1].wk_reader_group =
    trim(cr.reader_group)
   ENDIF
   IF (cnvtdatetime(latest_cum_dttm) > cnvtdatetime("01-jan-1800"))
    count1 = (count1+ 1)
    IF (mod(count1,100)=1)
     stat = alterlist(work_array->work_element,(count1+ 99))
    ENDIF
    IF (mod(count1,mod_value)=0)
     CALL update_log(build("WORK_ARRAY =",count1," RECORDS - Memory = ",curmem))
    ENDIF
    work_array->work_element[count1].wk_encntr_id = cr.encntr_id, work_array->work_element[count1].
    wk_distribution_id = cr.distribution_id, work_array->work_element[count1].wk_dist_run_type_cd =
    cumulative_cd,
    work_array->work_element[count1].wk_dist_run_dt_tm = latest_cum_dttm, work_array->work_element[
    count1].wk_chart_request_id = cum_request_id, work_array->work_element[count1].wk_reader_group =
    trim(cr.reader_group)
   ENDIF
   IF (cnvtdatetime(latest_cut_dttm) > cnvtdatetime("01-jan-1800"))
    count1 = (count1+ 1)
    IF (mod(count1,100)=1)
     stat = alterlist(work_array->work_element,(count1+ 99))
    ENDIF
    IF (mod(count1,mod_value)=0)
     CALL update_log(build("WORK_ARRAY =",count1," RECORDS - Memory = ",curmem))
    ENDIF
    work_array->work_element[count1].wk_encntr_id = cr.encntr_id, work_array->work_element[count1].
    wk_distribution_id = cr.distribution_id, work_array->work_element[count1].wk_dist_run_type_cd =
    cutoff_cd,
    work_array->work_element[count1].wk_dist_run_dt_tm = latest_cut_dttm, work_array->work_element[
    count1].wk_chart_request_id = cut_request_id, work_array->work_element[count1].wk_reader_group =
    trim(cr.reader_group)
   ENDIF
   IF (cnvtdatetime(latest_rep_dttm) > cnvtdatetime("01-jan-1800"))
    count1 = (count1+ 1)
    IF (mod(count1,100)=1)
     stat = alterlist(work_array->work_element,(count1+ 99))
    ENDIF
    IF (mod(count1,mod_value)=0)
     CALL update_log(build("WORK_ARRAY =",count1," RECORDS - Memory = ",curmem))
    ENDIF
    work_array->work_element[count1].wk_encntr_id = cr.encntr_id, work_array->work_element[count1].
    wk_distribution_id = cr.distribution_id, work_array->work_element[count1].wk_dist_run_type_cd =
    replacement_cd,
    work_array->work_element[count1].wk_dist_run_dt_tm = latest_rep_dttm, work_array->work_element[
    count1].wk_chart_request_id = rep_request_id, work_array->work_element[count1].wk_reader_group =
    trim(cr.reader_group)
   ENDIF
   IF (cnvtdatetime(latest_add_dttm) > cnvtdatetime("01-jan-1800"))
    count1 = (count1+ 1)
    IF (mod(count1,100)=1)
     stat = alterlist(work_array->work_element,(count1+ 99))
    ENDIF
    IF (mod(count1,mod_value)=0)
     CALL update_log(build("WORK_ARRAY =",count1," RECORDS - Memory = ",curmem))
    ENDIF
    work_array->work_element[count1].wk_encntr_id = cr.encntr_id, work_array->work_element[count1].
    wk_distribution_id = cr.distribution_id, work_array->work_element[count1].wk_dist_run_type_cd =
    addend_cd,
    work_array->work_element[count1].wk_dist_run_dt_tm = latest_add_dttm, work_array->work_element[
    count1].wk_chart_request_id = add_request_id, work_array->work_element[count1].wk_reader_group =
    trim(cr.reader_group)
   ENDIF
  FOOT REPORT
   stat = alterlist(work_array->work_element,count1)
  WITH nocounter
 ;end select
 CALL update_log(build("ENDING WORK_ARRAY = ",count1," RECORDS - Memory = ",curmem))
#continue_delete
 FREE RECORD request
 RECORD request(
   1 qual[*]
     2 chart_request_id = f8
 )
 SET x = 0
 IF (count1 > 0)
  FOR (loop_count = 1 TO count1)
    IF (((req_application=1
     AND check_if=0) OR (req_application=0)) )
     SET check_if = 1
     IF ((work_array->work_element[loop_count].wk_dist_run_type_cd IN (interim_any_cd, interim_cum_cd
     )))
      SET interval_clause = " cr.dist_run_type_cd IN (interim_any_cd,interim_cum_cd)"
     ELSEIF ((work_array->work_element[loop_count].wk_dist_run_type_cd=periodic_cd))
      SET interval_clause = " cr.dist_run_type_cd IN (periodic_cd,interim_any_cd,interim_cum_cd)"
     ELSEIF ((work_array->work_element[loop_count].wk_dist_run_type_cd=splitcum_cd))
      SET interval_clause = " cr.dist_run_type_cd IN (splitcum_cd,interim_any_cd,interim_cum_cd)"
     ELSEIF ((work_array->work_element[loop_count].wk_dist_run_type_cd=cumulative_cd))
      SET interval_clause =
      " cr.dist_run_type_cd IN (cumulative_cd,splitcum_cd,interim_any_cd,interim_cum_cd)"
     ELSEIF ((work_array->work_element[loop_count].wk_dist_run_type_cd=cutoff_cd))
      SET interval_clause =
      " cr.dist_run_type_cd IN (cutoff_cd,splitcum_cd,interim_any_cd,interim_cum_cd)"
     ELSEIF ((work_array->work_element[loop_count].wk_dist_run_type_cd=replacement_cd))
      SET interval_clause =
      " cr.dist_run_type_cd IN (replacement_cd,splitcum_cd,interim_any_cd,interim_cum_cd)"
     ELSEIF ((work_array->work_element[loop_count].wk_dist_run_type_cd IN (cumaddm_cd, addendum_cd)))
      SET interval_clause = " cr.dist_run_type_cd IN (cumaddm_cd,addendum_cd)"
     ENDIF
    ENDIF
    IF ((work_array->work_element[loop_count].wk_reader_group=" "))
     SET chart_req_qual =
     " cr.distribution_id = work_array->work_element[loop_count]->wk_distribution_id"
    ELSE
     SET chart_req_qual =
     " trim(cr.reader_group) = work_array->work_element[loop_count]->wk_reader_group"
    ENDIF
    EXECUTE cp_select_delete_rows
    IF (mod(loop_count,100)=1)
     CALL echo(build("curmem = ",curmem," / loop_count = ",loop_count))
    ENDIF
  ENDFOR
  SET stat = alterlist(request->qual,request_cnt)
  CALL update_log(build("REQUEST SIZE BEFORE DELETE = ",request_cnt," RECORDS - Memory = ",curmem))
  SET x = 0
  IF (request_cnt > 0)
   FOR (x = 1 TO request_cnt)
     DELETE  FROM chart_req_provider crp
      SET crp.seq = 1
      WHERE (crp.chart_request_id=request->qual[x].chart_request_id)
     ;end delete
     DELETE  FROM chart_request cr
      SET cr.seq = 1
      WHERE (cr.chart_request_id=request->qual[x].chart_request_id)
     ;end delete
     IF (mod(x,mod_value_delete)=0)
      COMMIT
      CALL update_log(build("DELETED COUNT = ",x," RECORDS - Memory = ",curmem))
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  CALL update_log("NO RECORDS TO PROCESS, EXITING.")
 ENDIF
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
 IF (request_cnt > 0
  AND failed="F")
  CALL update_log(build("SUCCESSFULLY DELETED CR/CRP ID'S = ",request_cnt))
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CHART_REQUEST"
  SET msg = fillstring(120," ")
  SET msg = concat("# OF SUCCESSFULLY DELETED CR/CRP ID'S = ",cnvtstring(request_cnt))
  SET reply->status_data.subeventstatus[1].targetobjectvalue = msg
  COMMIT
 ELSEIF (request_cnt=0
  AND failed="F")
  CALL update_log("NO ROWS SELECTED TO DELETE")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CHART_REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO ROWS TO DELETE"
  ROLLBACK
 ELSEIF (failed="T")
  CALL update_log("ERRORS IN CP_DELETE_OLD_DISTR_ROWS")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CHART_REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  ROLLBACK
 ENDIF
 SET end_time = cnvtdatetime(curdate,curtime3)
 CALL update_log(build("END -- CP_DELETE_OLD_DISTR_ROWS"," - ",format(end_time,
    "mm/dd/yyyy hh:mm:ss;;d")))
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
