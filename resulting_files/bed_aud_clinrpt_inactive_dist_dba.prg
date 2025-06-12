CREATE PROGRAM bed_aud_clinrpt_inactive_dist:dba
 DECLARE checkandsetdistdetails(operationname=vc,index=i4,stdistind=i2,chkdistind=i2) = i4
 DECLARE checkandsetlawdetails(operationname=vc,index=i4,stlawind=i2,chklawind=i2) = i4
 DECLARE isinactivedist = i2 WITH noconstant(0)
 DECLARE isinactivelaw = i2 WITH noconstant(0)
 DECLARE is_logical_domain_enabled_ind = i2 WITH noconstant(0)
 DECLARE personnel_logical_domain_id = f8 WITH noconstant(0.0)
 DECLARE where_clause_d = vc
 DECLARE where_clause_o = vc
 DECLARE where_clause_l = vc
 DECLARE time_string = vc
 DECLARE date_string = vc
 DECLARE param_distid = i4 WITH constant(2)
 DECLARE param_law = i4 WITH constant(18)
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
     2 operation_name = vc
     2 active_ind = i2
 )
 FREE RECORD inactive_ops_jobs
 RECORD inactive_ops_jobs(
   1 inactive_ops[*]
     2 ops_task_id = f8
     2 operation_name = vc
     2 op_active_ind = i2
     2 distribution_name = vc
     2 dist_active_ind = i2
     2 law_name = vc
     2 law_active_ind = i2
     2 ops_job_name = vc
     2 frequency_flag = i4
     2 day_interval = i4
     2 time_ind = i2
     2 time_interval = i4
     2 time_interval_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 days_of_week[*]
       3 day_of_week = i4
     2 days_of_month[*]
       3 day_of_month = i4
     2 months_of_year[*]
       3 month_of_year = i4
     2 weeks_of_month[*]
       3 week_of_month = i4
 )
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="CLINICAL REPORTING XR"
   AND d.info_name="Enable Logical Domain XR Dist"
  DETAIL
   is_logical_domain_enabled_ind = d.info_number
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM prsnl p
  WHERE p.username=curuser
  DETAIL
   personnel_logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 IF (is_logical_domain_enabled_ind=1)
  SET where_clause_d = build2(
   "cd.distribution_id > 0 and cd.logical_domain_id = personnel_logical_domain_id")
 ELSE
  SET where_clause_d = build2("cd.distribution_id > 0")
 ENDIF
 IF (is_logical_domain_enabled_ind=1)
  SET where_clause_o = build2(
   "co.charting_operations_id > 0 and co.logical_domain_id = personnel_logical_domain_id")
 ELSE
  SET where_clause_o = build2("co.charting_operations_id > 0")
 ENDIF
 IF (is_logical_domain_enabled_ind=1)
  SET where_clause_l = build2("cl.law_id > 0 and cl.logical_domain_id = personnel_logical_domain_id")
 ELSE
  SET where_clause_l = build2("cl.law_id > 0")
 ENDIF
 SET ocnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM ops_schedule_param osp,
   charting_operations co
  PLAN (osp
   WHERE osp.active_ind=1
    AND trim(osp.batch_selection) != "")
   JOIN (co
   WHERE co.batch_name=osp.batch_selection
    AND parser(where_clause_o))
  ORDER BY osp.ops_task_id, osp.batch_selection
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(ops_jobs->ops,ocnt), ops_jobs->ops[ocnt].operation_name = co
   .batch_name,
   ops_jobs->ops[ocnt].active_ind = co.active_ind, ops_jobs->ops[ocnt].ops_task_id = osp.ops_task_id
  WITH nocounter
 ;end select
 SET icnt = 0
 FOR (o = 1 TO ocnt)
   SET setind = 0
   SET checkind = 0
   SET isinactivedist = 0
   SET isinactivelaw = 0
   IF ((ops_jobs->ops[o].active_ind != 1))
    SET icnt = (icnt+ 1)
    SET setind = 1
    SET stat = alterlist(inactive_ops_jobs->inactive_ops,icnt)
    SET inactive_ops_jobs->inactive_ops[icnt].operation_name = ops_jobs->ops[o].operation_name
    SET inactive_ops_jobs->inactive_ops[icnt].ops_task_id = ops_jobs->ops[o].ops_task_id
    SET inactive_ops_jobs->inactive_ops[icnt].op_active_ind = ops_jobs->ops[o].active_ind
    CALL checkandsetdistdetails(ops_jobs->ops[o].operation_name,icnt,setind,checkind)
    CALL checkandsetlawdetails(ops_jobs->ops[o].operation_name,icnt,setind,checkind)
   ELSE
    SET checkind = 1
    CALL checkandsetdistdetails(ops_jobs->ops[o].operation_name,icnt,setind,checkind)
    IF (isinactivedist=1)
     SET icnt = (icnt+ 1)
     SET setind = 1
     SET checkind = 0
     SET inactive_ops_jobs->inactive_ops[icnt].ops_task_id = ops_jobs->ops[o].ops_task_id
     CALL checkandsetlawdetails(inactive_ops_jobs->inactive_ops[icnt].operation_name,icnt,setind,
      checkind)
    ELSE
     CALL checkandsetlawdetails(ops_jobs->ops[o].operation_name,icnt,setind,checkind)
     IF (isinactivelaw=1)
      SET icnt = (icnt+ 1)
      SET setind = 1
      SET checkind = 0
      SET inactive_ops_jobs->inactive_ops[icnt].ops_task_id = ops_jobs->ops[o].ops_task_id
      CALL checkandsetdistdetails(inactive_ops_jobs->inactive_ops[icnt].operation_name,icnt,setind,
       checkind)
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (icnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = icnt),
    ops_task ot,
    ops_job oj
   PLAN (d)
    JOIN (ot
    WHERE (ot.ops_task_id=inactive_ops_jobs->inactive_ops[d.seq].ops_task_id))
    JOIN (oj
    WHERE oj.ops_job_id=ot.ops_job_id)
   DETAIL
    IF (trim(ot.job_grp_name)="")
     inactive_ops_jobs->inactive_ops[d.seq].ops_job_name = oj.name
    ELSE
     inactive_ops_jobs->inactive_ops[d.seq].ops_job_name = concat(trim(ot.job_grp_name),"(",trim(oj
       .name),")")
    ENDIF
    inactive_ops_jobs->inactive_ops[d.seq].frequency_flag = ot.frequency_type, inactive_ops_jobs->
    inactive_ops[d.seq].day_interval = ot.day_interval, inactive_ops_jobs->inactive_ops[d.seq].
    time_ind = ot.time_ind,
    inactive_ops_jobs->inactive_ops[d.seq].time_interval = ot.time_interval, inactive_ops_jobs->
    inactive_ops[d.seq].time_interval_ind = ot.time_interval_ind, inactive_ops_jobs->inactive_ops[d
    .seq].beg_effective_dt_tm = ot.beg_effective_dt_tm,
    inactive_ops_jobs->inactive_ops[d.seq].end_effective_dt_tm = ot.end_effective_dt_tm
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = icnt),
    ops_day_of_week dow
   PLAN (d
    WHERE (inactive_ops_jobs->inactive_ops[d.seq].frequency_flag IN (3, 5)))
    JOIN (dow
    WHERE (dow.ops_task_id=inactive_ops_jobs->inactive_ops[d.seq].ops_task_id)
     AND dow.active_ind=1)
   HEAD d.seq
    dow_cnt = 0
   DETAIL
    dow_cnt = (dow_cnt+ 1), stat = alterlist(inactive_ops_jobs->inactive_ops[d.seq].days_of_week,
     dow_cnt), inactive_ops_jobs->inactive_ops[d.seq].days_of_week[dow_cnt].day_of_week = dow
    .day_of_week
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = icnt),
    ops_day_of_month dom
   PLAN (d
    WHERE (inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=4))
    JOIN (dom
    WHERE (dom.ops_task_id=inactive_ops_jobs->inactive_ops[d.seq].ops_task_id)
     AND dom.active_ind=1)
   HEAD d.seq
    dom_cnt = 0
   DETAIL
    dom_cnt = (dom_cnt+ 1), stat = alterlist(inactive_ops_jobs->inactive_ops[d.seq].days_of_month,
     dom_cnt), inactive_ops_jobs->inactive_ops[d.seq].days_of_month[dom_cnt].day_of_month = dom
    .day_of_month
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = icnt),
    ops_month_of_year moy
   PLAN (d
    WHERE (inactive_ops_jobs->inactive_ops[d.seq].frequency_flag IN (4, 5)))
    JOIN (moy
    WHERE (moy.ops_task_id=inactive_ops_jobs->inactive_ops[d.seq].ops_task_id)
     AND moy.active_ind=1)
   HEAD d.seq
    moy_cnt = 0
   DETAIL
    moy_cnt = (moy_cnt+ 1), stat = alterlist(inactive_ops_jobs->inactive_ops[d.seq].months_of_year,
     moy_cnt), inactive_ops_jobs->inactive_ops[d.seq].months_of_year[moy_cnt].month_of_year = moy
    .month_of_year
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = icnt),
    ops_week_of_month wom
   PLAN (d
    WHERE (inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=5))
    JOIN (wom
    WHERE (wom.ops_task_id=inactive_ops_jobs->inactive_ops[d.seq].ops_task_id)
     AND wom.active_ind=1)
   HEAD d.seq
    wom_cnt = 0
   DETAIL
    wom_cnt = (wom_cnt+ 1), stat = alterlist(inactive_ops_jobs->inactive_ops[d.seq].weeks_of_month,
     wom_cnt), inactive_ops_jobs->inactive_ops[d.seq].weeks_of_month[wom_cnt].week_of_month = wom
    .week_of_month
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Ops Job Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = " Ops Job Occurrence"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Ops Job Scheduled"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Ops Job Time"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Operation Name"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Distribution Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Cross-Encounter Law Name"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 IF (icnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 SELECT INTO "NL:"
  d_ops_job_name = inactive_ops_jobs->inactive_ops[d.seq].ops_job_name, d_frequency_flag =
  inactive_ops_jobs->inactive_ops[d.seq].frequency_flag, d_day_interval = inactive_ops_jobs->
  inactive_ops[d.seq].day_interval,
  d_time_ind = inactive_ops_jobs->inactive_ops[d.seq].time_ind, d_time_interval = inactive_ops_jobs->
  inactive_ops[d.seq].time_interval, d_time_interval_ind = inactive_ops_jobs->inactive_ops[d.seq].
  time_interval_ind,
  d_beg_effective_dt_tm = inactive_ops_jobs->inactive_ops[d.seq].beg_effective_dt_tm,
  d_end_effective_dt_tm = inactive_ops_jobs->inactive_ops[d.seq].end_effective_dt_tm, d_days_of_week
   = inactive_ops_jobs->inactive_ops[d.seq].days_of_week,
  d_days_of_month = inactive_ops_jobs->inactive_ops[d.seq].days_of_month, d_months_of_year =
  inactive_ops_jobs->inactive_ops[d.seq].months_of_year, d_weeks_of_month = inactive_ops_jobs->
  inactive_ops[d.seq].weeks_of_month,
  d_operation_name = inactive_ops_jobs->inactive_ops[d.seq].operation_name, d_op_active_ind =
  inactive_ops_jobs->inactive_ops[d.seq].op_active_ind, d_distribution_name = inactive_ops_jobs->
  inactive_ops[d.seq].distribution_name,
  d_dist_active_ind = inactive_ops_jobs->inactive_ops[d.seq].dist_active_ind, d_law_name =
  inactive_ops_jobs->inactive_ops[d.seq].law_name, d_law_active_ind = inactive_ops_jobs->
  inactive_ops[d.seq].law_active_ind
  FROM (dummyt d  WITH seq = value(size(inactive_ops_jobs->inactive_ops,5)))
  PLAN (d)
  ORDER BY d_ops_job_name
  DETAIL
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,7),
   reply->rowlist[row_nbr].celllist[1].string_value = inactive_ops_jobs->inactive_ops[d.seq].
   ops_job_name
   IF ((inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=1))
    reply->rowlist[row_nbr].celllist[2].string_value = "One Time"
   ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=2))
    reply->rowlist[row_nbr].celllist[2].string_value = "Daily"
   ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=3))
    reply->rowlist[row_nbr].celllist[2].string_value = "Weekly"
   ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=4))
    reply->rowlist[row_nbr].celllist[2].string_value = "Day of Month"
   ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=5))
    reply->rowlist[row_nbr].celllist[2].string_value = "Week of Month"
   ENDIF
   IF ((inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=1))
    reply->rowlist[row_nbr].celllist[3].string_value = format(inactive_ops_jobs->inactive_ops[d.seq].
     beg_effective_dt_tm,"MM/DD/YYYY HH:MM;;D")
   ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=2))
    reply->rowlist[row_nbr].celllist[3].string_value = build2("Every ",trim(cnvtstring(
       inactive_ops_jobs->inactive_ops[d.seq].day_interval))," day(s)")
   ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=3))
    reply->rowlist[row_nbr].celllist[3].string_value = build2("Every ",trim(cnvtstring(
       inactive_ops_jobs->inactive_ops[d.seq].day_interval))," week(s) on ")
    FOR (x = 1 TO size(inactive_ops_jobs->inactive_ops[d.seq].days_of_week,5))
     IF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=1))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sun ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=2))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Mon ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=3))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Tue ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=4))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Wed ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Thu ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=6))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Fri ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=7))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sat ")
     ENDIF
     ,
     IF (x < size(inactive_ops_jobs->inactive_ops[d.seq].days_of_week,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
   ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=4))
    reply->rowlist[row_nbr].celllist[3].string_value = "Day(s) "
    FOR (x = 1 TO size(inactive_ops_jobs->inactive_ops[d.seq].days_of_month,5))
     IF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_month[x].day_of_month=32))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Last ")
     ELSE
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," ",trim(cnvtstring(inactive_ops_jobs->inactive_ops[d.seq].days_of_month[x].
         day_of_month)))
     ENDIF
     ,
     IF (x < size(inactive_ops_jobs->inactive_ops[d.seq].days_of_month,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
    reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
     string_value," of ")
    FOR (x = 1 TO size(inactive_ops_jobs->inactive_ops[d.seq].months_of_year,5))
     IF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=0))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," All Months ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=1))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jan ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=2))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Feb ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=3))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Mar ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=4))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Apr ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," May ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=6))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jun ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=7))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jul ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=8))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Aug ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=9))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sep ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=10))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Oct ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=11))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Nov ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=12))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Dec ")
     ENDIF
     ,
     IF (x < size(inactive_ops_jobs->inactive_ops[d.seq].months_of_year,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
   ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=5))
    reply->rowlist[row_nbr].celllist[3].string_value = "The "
    FOR (x = 1 TO size(inactive_ops_jobs->inactive_ops[d.seq].weeks_of_month,5))
     IF ((inactive_ops_jobs->inactive_ops[d.seq].weeks_of_month[x].week_of_month=1))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," 1st ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].weeks_of_month[x].week_of_month=2))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," 2nd ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].weeks_of_month[x].week_of_month=3))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," 3rd ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].weeks_of_month[x].week_of_month=4))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," 4th ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].weeks_of_month[x].week_of_month=5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Last ")
     ENDIF
     ,
     IF (x < size(inactive_ops_jobs->inactive_ops[d.seq].weeks_of_month,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
    FOR (x = 1 TO size(inactive_ops_jobs->inactive_ops[d.seq].days_of_week,5))
     IF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=1))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sun ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=2))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Mon ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=3))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Tue ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=4))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Wed ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Thu ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=6))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Fri ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].days_of_week[x].day_of_week=7))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sat ")
     ENDIF
     ,
     IF (x < size(inactive_ops_jobs->inactive_ops[d.seq].days_of_week,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
    reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
     string_value," of ")
    FOR (x = 1 TO size(inactive_ops_jobs->inactive_ops[d.seq].months_of_year,5))
     IF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=0))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," All Months ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=1))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jan ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=2))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Feb ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=3))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Mar ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=4))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Apr ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," May ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=6))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jun ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=7))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Jul ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=8))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Aug ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=9))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Sep ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=10))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Oct ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=11))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Nov ")
     ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].months_of_year[x].month_of_year=12))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value," Dec ")
     ENDIF
     ,
     IF (x < size(inactive_ops_jobs->inactive_ops[d.seq].months_of_year,5))
      reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[3].
       string_value,", ")
     ENDIF
    ENDFOR
   ENDIF
   IF ((inactive_ops_jobs->inactive_ops[d.seq].frequency_flag=1))
    reply->rowlist[row_nbr].celllist[4].string_value = " "
   ELSE
    IF ((inactive_ops_jobs->inactive_ops[d.seq].time_ind=1))
     reply->rowlist[row_nbr].celllist[4].string_value = build2("Every ",trim(cnvtstring(
        inactive_ops_jobs->inactive_ops[d.seq].time_interval)))
     IF ((inactive_ops_jobs->inactive_ops[d.seq].time_interval_ind=1))
      reply->rowlist[row_nbr].celllist[4].string_value = build2(reply->rowlist[row_nbr].celllist[4].
       string_value," hour(s) from ")
     ELSE
      reply->rowlist[row_nbr].celllist[4].string_value = build2(reply->rowlist[row_nbr].celllist[4].
       string_value," minute(s) from ")
     ENDIF
     IF ((inactive_ops_jobs->inactive_ops[d.seq].end_effective_dt_tm < cnvtdatetime("31-DEC-2500")))
      reply->rowlist[row_nbr].celllist[4].string_value = build2(reply->rowlist[row_nbr].celllist[4].
       string_value," ",format(cnvtdatetime(inactive_ops_jobs->inactive_ops[d.seq].
         beg_effective_dt_tm),"HH:MM;;D")," to ",format(cnvtdatetime(inactive_ops_jobs->inactive_ops[
         d.seq].end_effective_dt_tm),"HH:MM;;D"))
     ELSE
      time_string = format(cnvtdatetime(inactive_ops_jobs->inactive_ops[d.seq].end_effective_dt_tm),
       "HH:MM:SS;;D"), date_string = build2("31-DEC-2050 ",time_string," UTC"), reply->rowlist[
      row_nbr].celllist[4].string_value = build2(reply->rowlist[row_nbr].celllist[4].string_value," ",
       format(cnvtdatetime(inactive_ops_jobs->inactive_ops[d.seq].beg_effective_dt_tm),"HH:MM;;D"),
       " to ",format(cnvtdatetimeutc(date_string),"HH:MM;;D"))
     ENDIF
    ELSE
     reply->rowlist[row_nbr].celllist[4].string_value = format(inactive_ops_jobs->inactive_ops[d.seq]
      .beg_effective_dt_tm,"HH:MM;;D")
    ENDIF
   ENDIF
   IF (trim(inactive_ops_jobs->inactive_ops[d.seq].operation_name) != "")
    IF ((inactive_ops_jobs->inactive_ops[d.seq].op_active_ind=1))
     reply->rowlist[row_nbr].celllist[5].string_value = concat(trim(inactive_ops_jobs->inactive_ops[d
       .seq].operation_name)," ","(","Active",")")
    ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].op_active_ind=0))
     reply->rowlist[row_nbr].celllist[5].string_value = concat(trim(inactive_ops_jobs->inactive_ops[d
       .seq].operation_name)," ","(","Inactive",")")
    ENDIF
   ENDIF
   IF (trim(inactive_ops_jobs->inactive_ops[d.seq].distribution_name) != "")
    IF ((inactive_ops_jobs->inactive_ops[d.seq].dist_active_ind=1))
     reply->rowlist[row_nbr].celllist[6].string_value = concat(trim(inactive_ops_jobs->inactive_ops[d
       .seq].distribution_name)," ","(","Active",")")
    ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].dist_active_ind=0))
     reply->rowlist[row_nbr].celllist[6].string_value = concat(trim(inactive_ops_jobs->inactive_ops[d
       .seq].distribution_name)," ","(","Inactive",")")
    ENDIF
   ENDIF
   IF (trim(inactive_ops_jobs->inactive_ops[d.seq].law_name) != "")
    IF ((inactive_ops_jobs->inactive_ops[d.seq].law_active_ind=1))
     reply->rowlist[row_nbr].celllist[7].string_value = concat(trim(inactive_ops_jobs->inactive_ops[d
       .seq].law_name)," ","(","Active",")")
    ELSEIF ((inactive_ops_jobs->inactive_ops[d.seq].law_active_ind=0))
     reply->rowlist[row_nbr].celllist[7].string_value = concat(trim(inactive_ops_jobs->inactive_ops[d
       .seq].law_name)," ","(","Inactive",")")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE checkandsetdistdetails(operationname,index,stdistind,chkdistind)
  SELECT INTO "NL:"
   FROM charting_operations co,
    chart_distribution cd
   PLAN (co
    WHERE co.batch_name=operationname
     AND co.param_type_flag=param_distid)
    JOIN (cd
    WHERE cd.distribution_id=cnvtreal(co.param)
     AND parser(where_clause_d))
   DETAIL
    IF (stdistind=1)
     inactive_ops_jobs->inactive_ops[index].distribution_name = cd.dist_descr, inactive_ops_jobs->
     inactive_ops[index].dist_active_ind = cd.active_ind
    ELSEIF (chkdistind=1)
     IF (cd.active_ind != 1)
      index = (index+ 1), stat = alterlist(inactive_ops_jobs->inactive_ops,index), inactive_ops_jobs
      ->inactive_ops[index].distribution_name = cd.dist_descr,
      inactive_ops_jobs->inactive_ops[index].dist_active_ind = cd.active_ind, inactive_ops_jobs->
      inactive_ops[index].operation_name = co.batch_name, inactive_ops_jobs->inactive_ops[index].
      op_active_ind = co.active_ind,
      isinactivedist = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  RETURN(0)
 END ;Subroutine
 SUBROUTINE checkandsetlawdetails(operationname,index,stlawind,chklawind)
  SELECT INTO "NL:"
   FROM charting_operations co,
    chart_law cl
   PLAN (co
    WHERE co.batch_name=operationname
     AND co.param_type_flag=param_law)
    JOIN (cl
    WHERE cl.law_id=cnvtreal(co.param)
     AND parser(where_clause_l))
   DETAIL
    IF (stlawind=1)
     inactive_ops_jobs->inactive_ops[index].law_name = cl.law_descr, inactive_ops_jobs->inactive_ops[
     index].law_active_ind = cl.active_ind
    ELSEIF (chklawind=1)
     IF (cl.active_ind != 1)
      index = (index+ 1), stat = alterlist(inactive_ops_jobs->inactive_ops,index), inactive_ops_jobs
      ->inactive_ops[index].law_name = cl.law_descr,
      inactive_ops_jobs->inactive_ops[index].law_active_ind = cl.active_ind, inactive_ops_jobs->
      inactive_ops[index].operation_name = co.batch_name, inactive_ops_jobs->inactive_ops[index].
      op_active_ind = co.active_ind,
      isinactivelaw = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  RETURN(0)
 END ;Subroutine
#exit_script
END GO
