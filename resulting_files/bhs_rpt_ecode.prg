CREATE PROGRAM bhs_rpt_ecode
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "START_DT_TM" = "CURDATE",
  "END_DT_TM" = "CURDATE",
  "CODER_NAME" = 0
  WITH outdev, start_dt_tm, end_dt_tm,
  coder_name
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(trim(concat( $START_DT_TM," 00:00:00")))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(trim(concat( $END_DT_TM," 23:59:59")))
 DECLARE mf_coder_id = f8 WITH protect, constant(cnvtreal( $CODER_NAME))
 DECLARE mf_phone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6026,"PHONEMSG"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_deleted_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"DELETED"))
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 SET beg_date_qual = cnvtdatetime(ms_beg_dt_tm)
 SET end_date_qual = cnvtdatetime(ms_end_dt_tm)
 IF (datetimediff(end_date_qual,beg_date_qual) > 120)
  CALL echo("Date range > 120")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 120 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) < 0)
  CALL echo("Date range < 0")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
 SELECT INTO  $OUTDEV
  receiver_name = substring(1,50,pr2.name_full_formatted), pt_name = substring(1,50,p
   .name_full_formatted), fin = cnvtalias(ea.alias,ea.encntr_alias_type_cd),
  dos = e.create_dt_tm"@SHORTDATETIME", subject_line = substring(1,50,ta.msg_subject), msg_status =
  uar_get_code_display(taa.task_status_cd),
  msg_create_dt_tm = ta.task_create_dt_tm"@SHORTDATETIME", msg_type = uar_get_code_display(ta
   .task_type_cd), sender_name = substring(1,50,pr1.name_full_formatted),
  num_of_days = datetimediff(cnvtdatetime(curdate,curtime3),ta.task_create_dt_tm)
  FROM task_activity ta,
   person p,
   encounter e,
   prsnl pr1,
   prsnl pr2,
   task_activity_assignment taa,
   encntr_alias ea
  PLAN (ta
   WHERE ta.task_type_cd=mf_phone_cd
    AND ta.task_status_cd != 0
    AND ta.task_create_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ta.msg_sender_id=mf_coder_id)
   JOIN (p
   WHERE p.person_id=ta.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= sysdate)
   JOIN (e
   WHERE e.encntr_id=ta.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm >= sysdate)
   JOIN (ea
   WHERE ea.encntr_id=ta.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (pr1
   WHERE pr1.person_id=ta.msg_sender_id
    AND pr1.active_ind=1
    AND pr1.end_effective_dt_tm >= sysdate)
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND taa.assign_person_id != 1
    AND taa.copy_type_flag=0
    AND taa.task_status_cd != mf_deleted_cd)
   JOIN (pr2
   WHERE pr2.person_id=taa.assign_prsnl_id
    AND pr2.active_ind=1
    AND pr2.end_effective_dt_tm >= sysdate)
  ORDER BY subject_line
  WITH separator = " ", format, skipreport = 1
 ;end select
#exit_prg
END GO
