CREATE PROGRAM bed_aud_clinrpt_cp_prcs_dist
 DECLARE param_cr_req = i4 WITH constant(1370045)
 DECLARE param_ch_req = i4 WITH constant(1300018)
 DECLARE param_cp_dist = i4 WITH constant(1300008)
 DECLARE time_string = vc WITH noconstant
 DECLARE date_string = vc WITH noconstant
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
  )
 ENDIF
 FREE RECORD ops_jobs
 RECORD ops_jobs(
   1 ops[*]
     2 ops_task_id = f8
     2 frequency_flag = i4
     2 day_interval = i4
     2 time_ind = i2
     2 time_interval = i4
     2 time_interval_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 ops_job_name = vc
     2 days_of_week[*]
       3 day_of_week = i4
     2 days_of_month[*]
       3 day_of_month = i4
     2 months_of_year[*]
       3 month_of_year = i4
     2 weeks_of_month[*]
       3 week_of_month = i4
     2 journal_step_ind = i2
     2 operations[*]
       3 operation_name = vc
       3 status = vc
 )
 SET ops_job_cnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM ops_task ot,
   ops_job oj,
   ops_job_step ojs
  PLAN (ot
   WHERE ot.active_ind=1)
   JOIN (oj
   WHERE oj.ops_job_id=ot.ops_job_id)
   JOIN (ojs
   WHERE ojs.request_number=param_cp_dist
    AND ojs.ops_job_id=oj.ops_job_id
    AND ojs.active_ind=1)
  ORDER BY oj.ops_job_id, oj.name, ot.ops_task_id
  DETAIL
   ops_job_cnt = (ops_job_cnt+ 1), stat = alterlist(ops_jobs->ops,ops_job_cnt), ops_jobs->ops[
   ops_job_cnt].ops_task_id = ot.ops_task_id,
   ops_jobs->ops[ops_job_cnt].frequency_flag = ot.frequency_type, ops_jobs->ops[ops_job_cnt].
   day_interval = ot.day_interval, ops_jobs->ops[ops_job_cnt].time_ind = ot.time_ind,
   ops_jobs->ops[ops_job_cnt].time_interval = ot.time_interval, ops_jobs->ops[ops_job_cnt].
   time_interval_ind = ot.time_interval_ind, ops_jobs->ops[ops_job_cnt].beg_effective_dt_tm = ot
   .beg_effective_dt_tm,
   ops_jobs->ops[ops_job_cnt].end_effective_dt_tm = ot.end_effective_dt_tm
   IF (trim(ot.job_grp_name)="")
    ops_jobs->ops[ops_job_cnt].ops_job_name = oj.name
   ELSE
    ops_jobs->ops[ops_job_cnt].ops_job_name = concat(trim(ot.job_grp_name),"(",trim(oj.name),")")
   ENDIF
  WITH nocounter
 ;end select
 IF (ops_job_cnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ops_job_cnt),
    ops_day_of_week dow
   PLAN (d
    WHERE (ops_jobs->ops[d.seq].frequency_flag IN (3, 5)))
    JOIN (dow
    WHERE (dow.ops_task_id=ops_jobs->ops[d.seq].ops_task_id)
     AND dow.active_ind=1)
   HEAD d.seq
    dow_cnt = 0
   DETAIL
    dow_cnt = (dow_cnt+ 1), stat = alterlist(ops_jobs->ops[d.seq].days_of_week,dow_cnt), ops_jobs->
    ops[d.seq].days_of_week[dow_cnt].day_of_week = dow.day_of_week
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ops_job_cnt),
    ops_day_of_month dom
   PLAN (d
    WHERE (ops_jobs->ops[d.seq].frequency_flag=4))
    JOIN (dom
    WHERE (dom.ops_task_id=ops_jobs->ops[d.seq].ops_task_id)
     AND dom.active_ind=1)
   HEAD d.seq
    dom_cnt = 0
   DETAIL
    dom_cnt = (dom_cnt+ 1), stat = alterlist(ops_jobs->ops[d.seq].days_of_month,dom_cnt), ops_jobs->
    ops[d.seq].days_of_month[dom_cnt].day_of_month = dom.day_of_month
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ops_job_cnt),
    ops_month_of_year moy
   PLAN (d
    WHERE (ops_jobs->ops[d.seq].frequency_flag IN (4, 5)))
    JOIN (moy
    WHERE (moy.ops_task_id=ops_jobs->ops[d.seq].ops_task_id)
     AND moy.active_ind=1)
   HEAD d.seq
    moy_cnt = 0
   DETAIL
    moy_cnt = (moy_cnt+ 1), stat = alterlist(ops_jobs->ops[d.seq].months_of_year,moy_cnt), ops_jobs->
    ops[d.seq].months_of_year[moy_cnt].month_of_year = moy.month_of_year
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ops_job_cnt),
    ops_week_of_month wom
   PLAN (d
    WHERE (ops_jobs->ops[d.seq].frequency_flag=5))
    JOIN (wom
    WHERE (wom.ops_task_id=ops_jobs->ops[d.seq].ops_task_id)
     AND wom.active_ind=1)
   HEAD d.seq
    wom_cnt = 0
   DETAIL
    wom_cnt = (wom_cnt+ 1), stat = alterlist(ops_jobs->ops[d.seq].weeks_of_month,wom_cnt), ops_jobs->
    ops[d.seq].weeks_of_month[wom_cnt].week_of_month = wom.week_of_month
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ops_job_cnt),
    ops_job_step ojs,
    ops_task ot,
    ops_job oj
   PLAN (d)
    JOIN (ot
    WHERE (ot.ops_task_id=ops_jobs->ops[d.seq].ops_task_id)
     AND ot.active_ind=1)
    JOIN (oj
    WHERE oj.ops_job_id=ot.ops_job_id)
    JOIN (ojs
    WHERE ojs.ops_job_id=oj.ops_job_id
     AND ojs.request_number IN (param_ch_req, param_cr_req)
     AND ojs.active_ind=1)
   DETAIL
    ops_jobs->ops[d.seq].journal_step_ind = 1
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "NL:"
   FROM (dummyt d  WITH seq = ops_job_cnt),
    ops_schedule_param osp,
    charting_operations co
   PLAN (d)
    JOIN (osp
    WHERE (osp.ops_task_id=ops_jobs->ops[d.seq].ops_task_id)
     AND osp.active_ind=1
     AND trim(osp.batch_selection) != "")
    JOIN (co
    WHERE osp.batch_selection=co.batch_name)
   ORDER BY osp.ops_task_id, osp.batch_selection
   HEAD d.seq
    op_cnt = 0
   DETAIL
    op_cnt = (op_cnt+ 1), stat = alterlist(ops_jobs->ops[d.seq].operations,op_cnt), ops_jobs->ops[d
    .seq].operations[op_cnt].operation_name = co.batch_name
    IF (co.active_ind=1)
     ops_jobs->ops[d.seq].operations[op_cnt].status = "(Active)"
    ELSE
     ops_jobs->ops[d.seq].operations[op_cnt].status = "(Inactive)"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Ops Job Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Ops Job Occurrence"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Ops Job Scheduled"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Ops Job Time"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Print a Journal"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Operation Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 IF (ops_job_cnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 SELECT INTO "NL:"
  d_ops_job_name = ops_jobs->ops[d.seq].ops_job_name, d_operations = ops_jobs->ops[d.seq].operations,
  d_frequency_flag = ops_jobs->ops[d.seq].frequency_flag,
  d_day_interval = ops_jobs->ops[d.seq].day_interval, d_time_ind = ops_jobs->ops[d.seq].time_ind,
  d_time_interval = ops_jobs->ops[d.seq].time_interval,
  d_time_interval_ind = ops_jobs->ops[d.seq].time_interval_ind, d_beg_effective_dt_tm = ops_jobs->
  ops[d.seq].beg_effective_dt_tm, d_end_effective_dt_tm = ops_jobs->ops[d.seq].end_effective_dt_tm,
  d_days_of_week = ops_jobs->ops[d.seq].days_of_week, d_days_of_month = ops_jobs->ops[d.seq].
  days_of_month, d_months_of_year = ops_jobs->ops[d.seq].months_of_year,
  d_weeks_of_month = ops_jobs->ops[d.seq].weeks_of_month, d_journal_step_ind = ops_jobs->ops[d.seq].
  journal_step_ind
  FROM (dummyt d  WITH seq = value(size(ops_jobs->ops,5)))
  PLAN (d)
  ORDER BY d_ops_job_name
  DETAIL
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,6),
   reply->rowlist[row_nbr].celllist[1].string_value = ops_jobs->ops[d.seq].ops_job_name
   IF ((ops_jobs->ops[d.seq].frequency_flag=1))
    reply->rowlist[row_nbr].celllist[2].string_value = "One Time"
   ELSEIF ((ops_jobs->ops[d.seq].frequency_flag=2))
    reply->rowlist[row_nbr].celllist[2].string_value = "Daily"
   ELSEIF ((ops_jobs->ops[d.seq].frequency_flag=3))
    reply->rowlist[row_nbr].celllist[2].string_value = "Weekly"
   ELSEIF ((ops_jobs->ops[d.seq].frequency_flag=4))
    reply->rowlist[row_nbr].celllist[2].string_value = "Day of Month"
   ELSEIF ((ops_jobs->ops[d.seq].frequency_flag=5))
    reply->rowlist[row_nbr].celllist[2].string_value = "Week of Month"
   ENDIF
   IF ((ops_jobs->ops[d.seq].frequency_flag=1))
    reply->rowlist[row_nbr].celllist[3].string_value = format(ops_jobs->ops[d.seq].
     beg_effective_dt_tm,"MM/DD/YYYY HH:MM;;D")
   ELSEIF ((ops_jobs->ops[d.seq].frequency_flag=2))
    reply->rowlist[row_nbr].celllist[3].string_value = build2("Every ",trim(cnvtstring(ops_jobs->ops[
       d.seq].day_interval))," day(s)")
   ELSEIF ((ops_jobs->ops[d.seq].frequency_flag=3))
    reply->rowlist[row_nbr].celllist[3].string_value = build2("Every ",trim(cnvtstring(ops_jobs->ops[
       d.seq].day_interval))," week(s) on ")
    FOR (x = 1 TO size(ops_jobs->ops[d.seq].days_of_week,5))
     IF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=1))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sun ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=2))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Mon ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=3))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Tue ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=4))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Wed ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Thu ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=6))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Fri ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=7))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sat ")
     ENDIF
     ,
     IF (x < size(ops_jobs->ops[d.seq].days_of_week,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
   ELSEIF ((ops_jobs->ops[d.seq].frequency_flag=4))
    reply->rowlist[row_nbr].celllist[3].string_value = "Day(s) "
    FOR (x = 1 TO size(ops_jobs->ops[d.seq].days_of_month,5))
     IF ((ops_jobs->ops[d.seq].days_of_month[x].day_of_month=32))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Last ")
     ELSE
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," ",trim(cnvtstring(ops_jobs->ops[d.seq].days_of_month[x].day_of_month)))
     ENDIF
     ,
     IF (x < size(ops_jobs->ops[d.seq].days_of_month,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
    reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
     string_value," of ")
    FOR (x = 1 TO size(ops_jobs->ops[d.seq].months_of_year,5))
     IF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=0))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," All Months ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=1))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jan ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=2))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Feb ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=3))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Mar ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=4))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Apr ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," May ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=6))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jun ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=7))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jul ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=8))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Aug ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=9))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sep ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=10))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Oct ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=11))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Nov ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=12))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Dec ")
     ENDIF
     ,
     IF (x < size(ops_jobs->ops[d.seq].months_of_year,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
   ELSEIF ((ops_jobs->ops[d.seq].frequency_flag=5))
    reply->rowlist[row_nbr].celllist[3].string_value = "The "
    FOR (x = 1 TO size(ops_jobs->ops[d.seq].weeks_of_month,5))
     IF ((ops_jobs->ops[d.seq].weeks_of_month[x].week_of_month=1))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," 1st ")
     ELSEIF ((ops_jobs->ops[d.seq].weeks_of_month[x].week_of_month=2))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," 2nd ")
     ELSEIF ((ops_jobs->ops[d.seq].weeks_of_month[x].week_of_month=3))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," 3rd ")
     ELSEIF ((ops_jobs->ops[d.seq].weeks_of_month[x].week_of_month=4))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," 4th ")
     ELSEIF ((ops_jobs->ops[d.seq].weeks_of_month[x].week_of_month=5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Last ")
     ENDIF
     ,
     IF (x < size(ops_jobs->ops[d.seq].weeks_of_month,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
    FOR (x = 1 TO size(ops_jobs->ops[d.seq].days_of_week,5))
     IF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=1))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sun ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=2))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Mon ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=3))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Tue ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=4))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Wed ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Thu ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=6))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Fri ")
     ELSEIF ((ops_jobs->ops[d.seq].days_of_week[x].day_of_week=7))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sat ")
     ENDIF
     ,
     IF (x < size(ops_jobs->ops[d.seq].days_of_week,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
    reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
     string_value," of ")
    FOR (x = 1 TO size(ops_jobs->ops[d.seq].months_of_year,5))
     IF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=0))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," All Months ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=1))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jan ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=2))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Feb ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=3))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Mar ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=4))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Apr ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," May ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=6))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jun ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=7))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jul ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=8))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Aug ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=9))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sep ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=10))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Oct ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=11))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Nov ")
     ELSEIF ((ops_jobs->ops[d.seq].months_of_year[x].month_of_year=12))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Dec ")
     ENDIF
     ,
     IF (x < size(ops_jobs->ops[d.seq].months_of_year,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
   ENDIF
   IF ((ops_jobs->ops[d.seq].frequency_flag=1))
    reply->rowlist[row_nbr].celllist[4].string_value = " "
   ELSE
    IF ((ops_jobs->ops[d.seq].time_ind=1))
     reply->rowlist[row_nbr].celllist[4].string_value = build2("Every ",trim(cnvtstring(ops_jobs->
        ops[d.seq].time_interval)))
     IF ((ops_jobs->ops[d.seq].time_interval_ind=1))
      reply->rowlist[row_nbr].celllist[4].string_value = build2(reply->rowlist[row_nbr].celllist[4].
       string_value," hour(s) from ")
     ELSE
      reply->rowlist[row_nbr].celllist[4].string_value = build2(reply->rowlist[row_nbr].celllist[4].
       string_value," minute(s) from ")
     ENDIF
     IF ((ops_jobs->ops[d.seq].end_effective_dt_tm < cnvtdatetime("31-DEC-2500")))
      reply->rowlist[row_nbr].celllist[4].string_value = build2(reply->rowlist[row_nbr].celllist[4].
       string_value," ",format(cnvtdatetime(ops_jobs->ops[d.seq].beg_effective_dt_tm),"HH:MM;;D"),
       " to ",format(cnvtdatetime(ops_jobs->ops[d.seq].end_effective_dt_tm),"HH:MM;;D"))
     ELSE
      time_string = format(cnvtdatetime(ops_jobs->ops[d.seq].end_effective_dt_tm),"HH:MM:SS;;D"),
      date_string = build2("31-DEC-2050 ",time_string," UTC"), reply->rowlist[row_nbr].celllist[4].
      string_value = build2(reply->rowlist[row_nbr].celllist[4].string_value," ",format(cnvtdatetime(
         ops_jobs->ops[d.seq].beg_effective_dt_tm),"HH:MM;;D")," to ",format(cnvtdatetimeutc(
         date_string),"HH:MM;;D"))
     ENDIF
    ELSE
     reply->rowlist[row_nbr].celllist[4].string_value = format(ops_jobs->ops[d.seq].
      beg_effective_dt_tm,"HH:MM;;D")
    ENDIF
   ENDIF
   IF ((ops_jobs->ops[d.seq].journal_step_ind=1))
    reply->rowlist[row_nbr].celllist[5].string_value = "Yes"
   ELSE
    reply->rowlist[row_nbr].celllist[5].string_value = "No"
   ENDIF
   FOR (x = 1 TO size(ops_jobs->ops[d.seq].operations,5))
     IF (x=1)
      reply->rowlist[row_nbr].celllist[6].string_value = build2(ops_jobs->ops[d.seq].operations[x].
       operation_name," ",trim(ops_jobs->ops[d.seq].operations[x].status))
     ELSE
      reply->rowlist[row_nbr].celllist[6].string_value = build2(reply->rowlist[row_nbr].celllist[6].
       string_value,", ",ops_jobs->ops[d.seq].operations[x].operation_name," ",trim(ops_jobs->ops[d
        .seq].operations[x].status))
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
#exit_script
END GO
