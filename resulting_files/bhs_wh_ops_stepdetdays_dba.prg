CREATE PROGRAM bhs_wh_ops_stepdetdays:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "From Operations Date (MM-DD-YY)" = "",
  "To Operations Date (MM-DD-YY)" = "",
  "Enter Minimum jobs Per Minute:" = ""
  WITH outdev, fromdate, todate,
  scount
 RECORD jobstep(
   1 jobstepday[*]
     2 jobdate = dq8
     2 jobstep[*]
       3 step_count = i4
       3 jobstep1[*]
         4 step_name = c100
         4 beg_dt_tm = dq8
         4 end_dt_tm = dq8
         4 cntrl_grp = c100
         4 job_grp_name = c100
         4 job_name = c100
         4 batch_name = c100
         4 duration = f8
         4 smin = i4
 )
 SET from_date = cnvtdate2( $FROMDATE,"MM-DD-YY")
 SET to_date = cnvtdate2( $TODATE,"MM-DD-YY")
 SET cnta = 0
 SET statuscode = uar_get_code_by("DISPLAYKEY",460,"COMPLETE")
 SELECT INTO "NL:"
  status = uar_get_code_display(o.status_cd), o.ops_schedule_task_id, ocg.name,
  ost.name, ot.job_grp_name, oj.name,
  ojs.step_name, osp.batch_selection, o.ops_job_step_id,
  oj.ops_job_id, ost.ops_task_id, ost.task_type,
  ot.task_type, ot.job_number, start = o.beg_effective_dt_tm"MM/DD/YY HH:MM:SS;;D",
  start1 = o.beg_effective_dt_tm"MM/DD/YY ;;D", finish = o.end_effective_dt_tm"HH:MM:SS;;D", duration
   = datetimediff(o.end_effective_dt_tm,o.beg_effective_dt_tm,5),
  ms = ((hour(o.beg_effective_dt_tm) * 60)+ minute(o.beg_effective_dt_tm)), me = ((hour(o
   .end_effective_dt_tm) * 60)+ minute(o.end_effective_dt_tm))
  FROM ops_schedule_job_step o,
   ops_job_step ojs,
   ops_schedule_task ost,
   ops_schedule_param osp,
   ops_task ot,
   ops_job oj,
   ops_control_group ocg,
   dummyt d
  PLAN (o
   WHERE o.beg_effective_dt_tm BETWEEN cnvtdatetime(from_date,0) AND cnvtdatetime(to_date,235959)
    AND o.status_cd=statuscode)
   JOIN (ojs
   WHERE o.ops_job_step_id=ojs.ops_job_step_id)
   JOIN (ost
   WHERE ost.ops_schedule_task_id=o.ops_schedule_task_id)
   JOIN (ot
   WHERE ot.ops_task_id=ost.ops_task_id)
   JOIN (oj
   WHERE ot.ops_job_id=oj.ops_job_id)
   JOIN (ocg
   WHERE ot.ops_control_grp_id=ocg.ops_control_grp_id)
   JOIN (d)
   JOIN (osp
   WHERE osp.ops_job_step_id=ojs.ops_job_step_id
    AND osp.ops_task_id=ost.ops_task_id)
  ORDER BY start
  HEAD REPORT
   cnr = 0, cntp = 0, cntpx = 0,
   cntax = 0, curmin = 0, curmin1 = 0,
   stat = alterlist(jobstep->jobstepday,10)
  HEAD start1
   cnr = (cnr+ 1), stat = mod(cnr,10)
   IF (stat=1
    AND cnr != 1)
    stat = alterlist(jobstep->jobstepday,(cnr+ 10))
   ENDIF
   jobstep->jobstepday[cnr].jobdate = start1, cntp = 0, cntpx = 0,
   cntax = 0, curmin = 0, curmin1 = 0,
   stat = alterlist(jobstep->jobstepday[cnr].jobstep,1440)
  DETAIL
   cnta = (cnta+ 1), curmin = (ms+ 1), curmin1 = (me+ 1),
   cntpx = 0
   FOR (cntpx = curmin TO curmin1)
    jobcount = 0,
    IF (cntpx >= curmin
     AND cntpx <= curmin1)
     jobcount = size(jobstep->jobstepday[cnr].jobstep[cntpx].jobstep1,5), stat = alterlist(jobstep->
      jobstepday[cnr].jobstep[cntpx].jobstep1,(jobcount+ 1)), jobcount = (jobcount+ 1),
     jobstep->jobstepday[cnr].jobstep[cntpx].step_count = jobcount, jobstep->jobstepday[cnr].jobstep[
     cntpx].jobstep1[jobcount].step_name = ojs.step_name, jobstep->jobstepday[cnr].jobstep[cntpx].
     jobstep1[jobcount].beg_dt_tm = start,
     jobstep->jobstepday[cnr].jobstep[cntpx].jobstep1[jobcount].end_dt_tm = finish, jobstep->
     jobstepday[cnr].jobstep[cntpx].jobstep1[jobcount].cntrl_grp = ocg.name, jobstep->jobstepday[cnr]
     .jobstep[cntpx].jobstep1[jobcount].job_grp_name = substring(1,32,ot.job_grp_name),
     jobstep->jobstepday[cnr].jobstep[cntpx].jobstep1[jobcount].duration = duration, jobstep->
     jobstepday[cnr].jobstep[cntpx].jobstep1[jobcount].job_name = substring(1,40,oj.name), jobstep->
     jobstepday[cnr].jobstep[cntpx].jobstep1[jobcount].batch_name = substring(1,48,osp
      .batch_selection)
    ENDIF
   ENDFOR
  FOOT REPORT
   stat = alterlist(jobstep->jobstepday,cnr)
  WITH nocounter, outerjoin = d
 ;end select
 SET env_name = fillstring(100," ")
 SELECT INTO "nl:"
  i.info_char
  FROM dm_info i
  WHERE i.info_domain="DATA MANAGEMENT"
   AND i.info_name="DM_ENV_NAME"
  DETAIL
   env_name = i.info_char
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   col 5, "TOTAL NO. OF OPERATION JOB STEPS RUNNING CONCURRENTLY IN A MINUTE", row + 1,
   col 5, "ENV NAME :  ", env_name,
   row + 1, col 5, "Minimum Number of Jobs : ",
    $SCOUNT, row + 1, col 5,
   "From  : ",  $FROMDATE, col 23,
   "To : ",  $TODATE, cntdaysize = size(jobstep->jobstepday,5),
   cntday = 0, row + 1
  HEAD PAGE
   row + 1, col 5, "CONTROL GROUP",
   col 45, "JOB GROUP", col 80,
   "JOB NAME", col 125, "STEP NAME",
   col 170, "BATCH", col 220,
   "START TIME", col 233, "END TIME",
   col 245, "DURATION"
   IF (curpage=1)
    row + 1
   ELSE
    row + 2
   ENDIF
  DETAIL
   FOR (cntday = 1 TO cntdaysize)
     row + 1, date = format(jobstep->jobstepday[cntday].jobdate,"MM/DD/YY;;D"), wdate1 = format(
      jobstep->jobstepday[cntday].jobdate,cclfmt->weekdayname),
     col 5, "Date : ", date,
     col 22, wdate1, cnt = 0,
     row + 1
     FOR (cnt = 1 TO 1440)
       IF ((jobstep->jobstepday[cntday].jobstep[cnt].step_count >= cnvtint( $SCOUNT)))
        cntstep = size(jobstep->jobstepday[cntday].jobstep[cnt].jobstep1,5), cnt1 = (cnt - 1), row +
        1,
        hh = 0, mm = 0, hh1 = fillstring(3," "),
        mm1 = fillstring(2," "), t1 = fillstring(5," "), hh = (cnt1/ 60),
        mm = mod(cnt1,60)
        IF (mm < 10)
         mm1 = concat("0",cnvtstring(mm))
        ELSE
         mm1 = cnvtstring(mm)
        ENDIF
        IF (hh < 10)
         hh1 = concat("0",cnvtstring(hh))
        ELSE
         hh1 = cnvtstring(hh)
        ENDIF
        t1 = build(hh1,":",mm1), col 3, "TIME ",
        col 10, t1, col 40,
        "TOTAL NO OF JOBS: ", col 57, jobstep->jobstepday[cntday].jobstep[cnt].step_count
        FOR (cntpx = 1 TO cntstep)
          row + 1
          IF (row > maxrow)
           BREAK
          ENDIF
          date = format(jobstep->jobstepday[cntday].jobstep[cnt].jobstep1[cntpx].beg_dt_tm,
           "HH:MM:SS;;D"), date1 = format(jobstep->jobstepday[cntday].jobstep[cnt].jobstep1[cntpx].
           end_dt_tm,"HH:MM:SS;;D"), col 5,
          jobstep->jobstepday[cntday].jobstep[cnt].jobstep1[cntpx].cntrl_grp, col 45, jobstep->
          jobstepday[cntday].jobstep[cnt].jobstep1[cntpx].job_grp_name,
          col 80, jobstep->jobstepday[cntday].jobstep[cnt].jobstep1[cntpx].job_name, col 125,
          jobstep->jobstepday[cntday].jobstep[cnt].jobstep1[cntpx].step_name, col 170, jobstep->
          jobstepday[cntday].jobstep[cnt].jobstep1[cntpx].batch_name,
          col 220, date, col 233,
          date1, col 242, jobstep->jobstepday[cntday].jobstep[cnt].jobstep1[cntpx].duration
        ENDFOR
        row + 1
       ENDIF
     ENDFOR
   ENDFOR
  WITH maxcol = 280
 ;end select
END GO
