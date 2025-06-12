CREATE PROGRAM bhs_ops_jobs
 PROMPT
  "Output to File/Printer/MINE " = mine
 SELECT INTO  $1
  job = concat(trim(oj.name)," (",trim(ot.job_grp_name),")"), control_group = trim(ocg.name),
  last_control_group_update = concat(format(ocg.updt_dt_tm,"@SHORTDATETIME")," (by) ",trim(p
    .name_full_formatted)),
  step_nr = ojs.step_number, step_name = ojs.step_name, last_step_update = concat(format(osp
    .updt_dt_tm,"@SHORTDATETIME"),"(by) ",trim(p3.name_full_formatted)),
  batch = trim(osp.batch_selection), enabled =
  IF (ot.enable_ind=1) "Y"
  ELSE "N"
  ENDIF
  , autostart =
  IF (ot.autostart_ind=1) "Y"
  ELSE "N"
  ENDIF
  ,
  distribution = trim(osp.output_dist), threshold =
  IF (ot.thresh_ind=1) "Y"
  ELSE "N"
  ENDIF
  , start_time = substring(10,18,format(ot.beg_effective_dt_tm,"@SHORTDATETIME")),
  time_interval =
  IF (ot.time_interval_ind)
   IF (ot.time_ind) concat("runs every ",trim(cnvtstring(ot.time_interval))," hour(s)")
   ELSE "none"
   ENDIF
  ELSEIF (ot.time_interval_ind=0)
   IF (ot.time_ind) concat(trim(cnvtstring(ot.time_interval))," minutes")
   ELSE "none"
   ENDIF
  ELSE "-"
  ENDIF
  , frequency_type =
  IF (ot.frequency_type=1) "One Time"
  ELSEIF (ot.frequency_type=2) concat("Daily every ",trim(cnvtstring(ot.day_interval))," day(s)")
  ELSEIF (ot.frequency_type=3) concat("Weekly every",trim(cnvtstring(ot.day_interval))," week(s)")
  ELSEIF (ot.frequency_type=4) "Day of Month"
  ELSEIF (ot.frequency_type=5) "week ofMonth"
  ENDIF
  , day_of_week =
  IF (odw.day_of_week=1) "Sunday"
  ELSEIF (odw.day_of_week=2) "Monday"
  ELSEIF (odw.day_of_week=3) "Tuesday"
  ELSEIF (odw.day_of_week=4) "Wednesday"
  ELSEIF (odw.day_of_week=5) "Thursday"
  ELSEIF (odw.day_of_week=6) "Friday"
  ELSEIF (odw.day_of_week=7) "Saturday"
  ENDIF
  ,
  day = odm.day_of_month, week =
  IF (owm.week_of_month=1) "1st week of"
  ELSEIF (owm.week_of_month=2) "2nd week of"
  ELSEIF (owm.week_of_month=3) "3rd week of"
  ELSEIF (owm.week_of_month=4) "4thweek of"
  ELSEIF (owm.week_of_month=5) "Lastweek of"
  ENDIF
  , month =
  IF (omy.month_of_year=1) "January"
  ELSEIF (omy.month_of_year=2) "February"
  ELSEIF (omy.month_of_year=3) "March"
  ELSEIF (omy.month_of_year=4) "April"
  ELSEIF (omy.month_of_year=5) "May"
  ELSEIF (omy.month_of_year=6) "June"
  ELSEIF (omy.month_of_year=7) "July"
  ELSEIF (omy.month_of_year=8) "August"
  ELSEIF (omy.month_of_year=9) "September"
  ELSEIF (omy.month_of_year=10) "October"
  ELSEIF (omy.month_of_year=11) "November"
  ELSEIF (omy.month_of_year=12) "December"
  ENDIF
  ,
  last_schedule_update = concat(format(ot.updt_dt_tm,"@SHORTDATETIME")," (by) ",trim(p2
    .name_full_formatted))
  FROM ops_job oj,
   ops_job_step ojs,
   ops_schedule_param osp,
   ops_task ot,
   ops_control_group ocg,
   prsnl p,
   prsnl p2,
   prsnl p3,
   dummyt d,
   ops_month_of_year omy,
   dummyt d2,
   ops_day_of_month odm,
   dummyt d3,
   ops_day_of_week odw,
   dummyt d4,
   ops_week_of_month owm
  PLAN (ot)
   JOIN (osp
   WHERE ot.ops_task_id=osp.ops_task_id
    AND osp.active_ind=1)
   JOIN (oj
   WHERE oj.ops_job_id=ot.ops_job_id
    AND oj.active_ind=1
    AND oj.end_effective_dt_tm=cnvtdatetime(cnvtdate(12312100),0))
   JOIN (ojs
   WHERE ojs.ops_job_step_id=osp.ops_job_step_id
    AND ojs.active_ind=1)
   JOIN (ocg
   WHERE ot.ops_control_grp_id=ocg.ops_control_grp_id
    AND ocg.active_ind=1
    AND ocg.end_effective_dt_tm=cnvtdatetime(cnvtdate(12312100),0))
   JOIN (p
   WHERE p.person_id=ocg.updt_id)
   JOIN (p2
   WHERE p2.person_id=ot.updt_id)
   JOIN (p3
   WHERE p3.person_id=osp.updt_id)
   JOIN (d3)
   JOIN (odw
   WHERE odw.ops_task_id=ot.ops_task_id
    AND odw.active_ind=1)
   JOIN (d)
   JOIN (omy
   WHERE omy.ops_task_id=ot.ops_task_id
    AND omy.active_ind=1)
   JOIN (d2)
   JOIN (odm
   WHERE odm.ops_task_id=ot.ops_task_id
    AND odm.active_ind=1)
   JOIN (d4)
   JOIN (owm
   WHERE owm.ops_task_id=ot.ops_task_id
    AND owm.active_ind=1)
  ORDER BY ocg.name, oj.name, ot.ops_task_id
  WITH separator = " ", format, outerjoin = d,
   outerjoin = d2, outerjoin = d3, outerjoin = d4,
   dontcare = odw, dontcare = omy, dontcare = odm,
   dontcare = owm
 ;end select
END GO
