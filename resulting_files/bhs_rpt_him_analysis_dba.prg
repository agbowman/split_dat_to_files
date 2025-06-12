CREATE PROGRAM bhs_rpt_him_analysis:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Select Personnel" = value(0.0),
  "Select Task Status" = value(419.00),
  "Enter Emails" = "",
  "Select for Summary Unselect for Detail" = 0,
  "Date Range" = ""
  WITH outdev, s_start_date, s_end_date,
  f_prsnl, f_status, s_emails,
  l_sum, s_range
 FREE RECORD tasks
 RECORD tasks(
   1 cnt_tasks = i4
   1 cnt_per = i4
   1 avg_crt_final = f8
   1 avg_dis_final = f8
   1 cnt_prsnl = i4
   1 prsnl[*]
     2 first_name = vc
     2 last_name = vc
     2 position = vc
     2 avg_crt_final = f8
     2 avg_dis_final = f8
     2 cnt_task = i4
     2 queue[*]
       3 que_name = cv
       3 avg_crt_final = f8
       3 avg_dis_final = f8
       3 cnt_tasks = i4
       3 task[*]
         4 crt_dt = vc
         4 los = f8
         4 comp_dt = vc
         4 create_to_final = f8
         4 discharge_to_final = f8
         4 disch_dt = vc
         4 fin = vc
 )
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD grec
 RECORD grec(
   1 list[*]
     2 f_prsnlid = f8
     2 s_name = c15
 )
 FREE RECORD grec1
 RECORD grec1(
   1 list[*]
     2 f_cv = f8
     2 s_disp = vc
 )
 DECLARE mf_himpatientdeficiencyanalysis = f8 WITH constant(uar_get_code_by("MEANING",29762,
   "HIMANALYSIS")), protect
 DECLARE mf_complete = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"COMPLETE")), protect
 DECLARE ml_task_type_codeset = i4 WITH protect, constant(6026)
 DECLARE processing_var = f8 WITH constant(uar_get_code_by("MEANING",14172,"PROCESSING")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE cnt_que = i4 WITH noconstant(0), protect
 DECLARE cnt_task = i4 WITH noconstant(0), protect
 DECLARE cnt_prsnl = i4 WITH noconstant(0), protect
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE ml1_cnt = i4 WITH noconstant(0), protect
 DECLARE ml2_cnt = i4 WITH noconstant(0), protect
 DECLARE ml3_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_opr_var2 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_filename = vc WITH noconstant("bhs_deficiency_analysis_"), protect
 IF (( $L_SUM=1))
  SET ms_filename = build(trim(ms_filename,3),"summary")
 ELSEIF (( $L_SUM=0))
  SET ms_filename = build(trim(ms_filename,3),"detail")
 ENDIF
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),"_",trim(cnvtlower( $S_RANGE),
    3),format(sysdate,"MMDDYYYY;;q"),".csv")), protect
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_PRSNL),0)))
 SET ml_gcnt = 0
 IF (ms_lcheck="L")
  SET ms_opr_var1 = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_PRSNL),ml_gcnt)))
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec->list,(ml_gcnt+ 4))
     ENDIF
     SET grec->list[ml_gcnt].f_prsnlid = cnvtint(parameter(parameter2( $F_PRSNL),ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec->list,1)
  SET ml_gcnt = 1
  SET grec->list[1].f_prsnlid =  $F_PRSNL
  IF ((grec->list[1].f_prsnlid=0.0))
   SET ms_opr_var1 = "!="
  ELSE
   SET ms_opr_var1 = "="
  ENDIF
 ENDIF
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_STATUS),0)))
 SET ml_gcnt = 0
 IF (ms_lcheck="L")
  SET ms_opr_var2 = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_STATUS),ml_gcnt)))
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gcnt+ 4))
     ENDIF
     SET grec1->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_STATUS),ml_gcnt))
     SET grec1->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_STATUS),ml_gcnt)
      )
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec1->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gcnt = 1
  SET grec1->list[1].f_cv =  $F_STATUS
  IF ((grec1->list[1].f_cv=0.0))
   SET grec1->list[1].s_disp = "All Statuses"
   SET ms_opr_var2 = "!="
  ELSE
   SET grec1->list[1].s_disp = uar_get_code_display(grec1->list[1].f_cv)
   SET ms_opr_var2 = "="
  ENDIF
 ENDIF
 IF (cnvtupper(trim( $S_RANGE,3))="DAILY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0)),"D","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0)),"D","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ELSEIF (cnvtupper(trim( $S_RANGE,3))="WEEKLY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ELSEIF (cnvtupper(trim( $S_RANGE,3))="MONTHLY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ENDIF
 IF (cnvtdatetime(ms_start_date) > cnvtdatetime(ms_end_date))
  SET ms_error = "Start date must be less than end date."
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(ms_end_date),cnvtdatetime(ms_start_date)) > 93)
  SET ms_error = "Date range exceeds 93 days."
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
  GO TO exit_script
 ELSEIF (findstring("@", $S_EMAILS)=0
  AND textlen( $S_EMAILS) > 0
  AND ( $S_RANGE != "SCREEN"))
  SET ms_error = "Recipient email is invalid."
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  task_queue = uar_get_code_display(tah.task_type_cd)
  FROM code_value_group cvg,
   task_activity_history tah,
   prsnl usr,
   encounter e,
   organization o,
   person p,
   encntr_alias fin
  PLAN (cvg
   WHERE cvg.code_set=ml_task_type_codeset
    AND cvg.parent_code_value=mf_himpatientdeficiencyanalysis)
   JOIN (tah
   WHERE tah.task_type_cd=cvg.child_code_value
    AND tah.active_ind=1
    AND tah.task_completed_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)
    AND operator(tah.task_status_cd,ms_opr_var2, $F_STATUS))
   JOIN (e
   WHERE e.encntr_id=tah.encntr_id
    AND e.active_ind=1
    AND e.active_status_cd=188)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_status_cd=mf_cs48_active
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND fin.active_ind=1)
   JOIN (o
   WHERE o.organization_id=e.organization_id)
   JOIN (usr
   WHERE usr.person_id=tah.task_completed_prsnl_id
    AND operator(usr.person_id,ms_opr_var1, $F_PRSNL))
   JOIN (p
   WHERE p.person_id=tah.person_id)
  ORDER BY usr.name_last, usr.name_first, usr.person_id,
   task_queue
  HEAD REPORT
   stat = alterlist(tasks->prsnl,10)
  HEAD usr.person_id
   tasks->cnt_prsnl, tasks->cnt_prsnl += 1, tasks->cnt_prsnl = tasks->cnt_prsnl
   IF (mod(tasks->cnt_prsnl,10)=1
    AND (tasks->cnt_prsnl > 1))
    stat = alterlist(tasks->prsnl,(tasks->cnt_prsnl+ 9))
   ENDIF
   tasks->prsnl[tasks->cnt_prsnl].last_name = trim(usr.name_last,3), tasks->prsnl[tasks->cnt_prsnl].
   first_name = trim(usr.name_first,3), tasks->prsnl[tasks->cnt_prsnl].position = trim(
    uar_get_code_display(usr.position_cd),3),
   stat = alterlist(tasks->prsnl[tasks->cnt_prsnl].queue,10)
  HEAD task_queue
   cnt_que += 1
   IF (mod(cnt_que,10)=1
    AND cnt_que > 1)
    stat = alterlist(tasks->prsnl[tasks->cnt_prsnl].queue,(cnt_que+ 9))
   ENDIF
   tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].que_name = trim(uar_get_code_display(tah
     .task_type_cd),3), stat = alterlist(tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task,10)
  DETAIL
   cnt_task += 1
   IF (mod(cnt_task,10)=1
    AND cnt_task > 1)
    stat = alterlist(tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task,(cnt_task+ 9))
   ENDIF
   tasks->prsnl[tasks->cnt_prsnl].cnt_task += 1, tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].
   cnt_tasks += 1, tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task[cnt_task].comp_dt = trim(format
    (tah.task_completed_dt_tm,"mm/dd/yyyy hh:mm;;Q"),3),
   tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task[cnt_task].disch_dt = trim(format(e.disch_dt_tm,
     "mm/dd/yyyy hh:mm;;Q"),3), tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task[cnt_task].crt_dt
    = trim(format(tah.task_create_dt_tm,"mm/dd/yyyy hh:mm;;Q"),3)
   IF (((e.disch_dt_tm=null) OR (e.reg_dt_tm=null)) )
    tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task[cnt_task].los = 0
   ELSE
    tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task[cnt_task].los = datetimecmp(e.disch_dt_tm,e
     .reg_dt_tm)
   ENDIF
   IF (tah.task_completed_dt_tm > tah.task_create_dt_tm)
    tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task[cnt_task].create_to_final = round(datetimediff
     (tah.task_completed_dt_tm,tah.task_create_dt_tm,1),2), tasks->prsnl[tasks->cnt_prsnl].queue[
    cnt_que].avg_crt_final += datetimediff(tah.task_completed_dt_tm,tah.task_create_dt_tm,1)
   ELSE
    tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task[cnt_task].create_to_final = 0
   ENDIF
   IF (tah.task_completed_dt_tm > e.disch_dt_tm)
    tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task[cnt_task].discharge_to_final = round(
     datetimediff(tah.task_completed_dt_tm,e.disch_dt_tm,1),2), tasks->prsnl[tasks->cnt_prsnl].queue[
    cnt_que].avg_dis_final += datetimediff(tah.task_completed_dt_tm,e.disch_dt_tm,1)
   ELSE
    tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task[cnt_task].discharge_to_final = 0
   ENDIF
   tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task[cnt_task].fin = trim(fin.alias,3)
  FOOT  task_queue
   stat = alterlist(tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].task,cnt_task), tasks->prsnl[tasks
   ->cnt_prsnl].queue[cnt_que].avg_crt_final = round((tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].
    avg_crt_final/ cnt_task),2), tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].avg_dis_final = round(
    (tasks->prsnl[tasks->cnt_prsnl].queue[cnt_que].avg_dis_final/ cnt_task),2),
   cnt_task = 0
  FOOT  usr.person_id
   stat = alterlist(tasks->prsnl[tasks->cnt_prsnl].queue,cnt_que), cnt_que = 0
  FOOT REPORT
   stat = alterlist(tasks->prsnl,tasks->cnt_prsnl), cnt_prsnl = 0
  WITH nocounter
 ;end select
 IF (( $S_RANGE="SCREEN")
  AND ( $L_SUM=0))
  SELECT INTO  $OUTDEV
   first_name = substring(1,50,tasks->prsnl[d1.seq].first_name), last_name = substring(1,50,tasks->
    prsnl[d1.seq].last_name), que_name = substring(1,50,trim(tasks->prsnl[d1.seq].queue[d2.seq].
     que_name,3)),
   account_number = substring(1,30,tasks->prsnl[d1.seq].queue[d2.seq].task[d3.seq].fin), create_date
    = substring(1,30,tasks->prsnl[d1.seq].queue[d2.seq].task[d3.seq].crt_dt), discharge_date =
   substring(1,30,tasks->prsnl[d1.seq].queue[d2.seq].task[d3.seq].disch_dt),
   completed_date = substring(1,30,tasks->prsnl[d1.seq].queue[d2.seq].task[d3.seq].comp_dt), los =
   tasks->prsnl[d1.seq].queue[d2.seq].task[d3.seq].los, create_to_final = tasks->prsnl[d1.seq].queue[
   d2.seq].task[d3.seq].create_to_final,
   discharge_to_final = tasks->prsnl[d1.seq].queue[d2.seq].task[d3.seq].discharge_to_final
   FROM (dummyt d1  WITH seq = size(tasks->prsnl,5)),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(tasks->prsnl[d1.seq].queue,5)))
    JOIN (d2
    WHERE maxrec(d3,size(tasks->prsnl[d1.seq].queue[d2.seq].task,5)))
    JOIN (d3)
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (( $S_RANGE="SCREEN")
  AND ( $L_SUM=1))
  SELECT INTO  $OUTDEV
   first_name = substring(1,50,tasks->prsnl[d1.seq].first_name), last_name = substring(1,50,tasks->
    prsnl[d1.seq].last_name), queue_name = substring(1,50,tasks->prsnl[d1.seq].queue[d2.seq].que_name
    ),
   total_queue_tasks = tasks->prsnl[d1.seq].queue[d2.seq].cnt_tasks, total_tasks_per_person = tasks->
   prsnl[d1.seq].cnt_task, avg_create_to__final = tasks->prsnl[d1.seq].queue[d2.seq].avg_crt_final,
   avg_discharge_to_final = tasks->prsnl[d1.seq].queue[d2.seq].avg_dis_final
   FROM (dummyt d1  WITH seq = size(tasks->prsnl,5)),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(tasks->prsnl[d1.seq].queue,5)))
    JOIN (d2)
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (findstring("@", $S_EMAILS) > 0
  AND textlen(trim( $S_EMAILS,3)) > 1
  AND textlen(trim(ms_error,3))=0)
  IF (( $S_RANGE != "SCREEN")
   AND ( $L_SUM=1))
   SET frec->file_name = ms_output_file
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"First Name",','"Last Name",','"Queue Name",','"Total Queue Tasks",',
    '"Total Tasks Per Person",',
    '"Create To Final",','"Discharge To Final",',char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml1_cnt = 1 TO size(tasks->prsnl,5))
     FOR (ml2_cnt = 1 TO size(tasks->prsnl[ml1_cnt].queue,5))
      SET frec->file_buf = build('"',substring(1,50,tasks->prsnl[ml1_cnt].first_name),'","',substring
       (1,50,tasks->prsnl[ml1_cnt].last_name),'","',
       substring(1,50,tasks->prsnl[ml1_cnt].queue[ml2_cnt].que_name),'","',tasks->prsnl[ml1_cnt].
       queue[ml2_cnt].cnt_tasks,'","',tasks->prsnl[ml1_cnt].cnt_task,
       '","',tasks->prsnl[ml1_cnt].queue[ml2_cnt].avg_crt_final,'","',tasks->prsnl[ml1_cnt].queue[
       ml2_cnt].avg_dis_final,'"',
       char(13))
      SET stat = cclio("WRITE",frec)
     ENDFOR
   ENDFOR
   SET stat = cclio("CLOSE",frec)
  ELSEIF (( $S_RANGE != "SCREEN")
   AND ( $L_SUM=0))
   SET frec->file_name = ms_output_file
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"First Name",','"Last Name",','"Queue Name",','"Account Number",',
    '"Create Date",',
    '"Discharge Date",','"Completed Date",','"LOS",','"Create To Final",','"Discharge To Final",',
    char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml1_cnt = 1 TO size(tasks->prsnl,5))
     FOR (ml2_cnt = 1 TO size(tasks->prsnl[ml1_cnt].queue,5))
       FOR (ml3_cnt = 1 TO size(tasks->prsnl[ml1_cnt].queue[ml2_cnt].task,5))
        SET frec->file_buf = build('"',substring(1,50,tasks->prsnl[ml1_cnt].first_name),'","',
         substring(1,50,tasks->prsnl[ml1_cnt].last_name),'","',
         substring(1,50,trim(tasks->prsnl[ml1_cnt].queue[ml2_cnt].que_name,3)),'","',substring(1,30,
          tasks->prsnl[ml1_cnt].queue[ml2_cnt].task[ml3_cnt].fin),'","',substring(1,30,tasks->prsnl[
          ml1_cnt].queue[ml2_cnt].task[ml3_cnt].crt_dt),
         '","',substring(1,30,tasks->prsnl[ml1_cnt].queue[ml2_cnt].task[ml3_cnt].disch_dt),'","',
         substring(1,30,tasks->prsnl[ml1_cnt].queue[ml2_cnt].task[ml3_cnt].comp_dt),'","',
         tasks->prsnl[ml1_cnt].queue[ml2_cnt].task[ml3_cnt].los,'","',tasks->prsnl[ml1_cnt].queue[
         ml2_cnt].task[ml3_cnt].create_to_final,'","',tasks->prsnl[ml1_cnt].queue[ml2_cnt].task[
         ml3_cnt].discharge_to_final,
         '"',char(13))
        SET stat = cclio("WRITE",frec)
       ENDFOR
     ENDFOR
   ENDFOR
   SET stat = cclio("CLOSE",frec)
  ENDIF
  EXECUTE bhs_ma_email_file
  SET ms_subject = build2("Defeciency Audit Report ",trim(format(cnvtdatetime(ms_start_date),
     "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),"mmm-dd-yyyy hh:mm;;d"),
    3))
  CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ENDIF
#exit_script
END GO
