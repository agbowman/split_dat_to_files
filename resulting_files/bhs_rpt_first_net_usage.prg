CREATE PROGRAM bhs_rpt_first_net_usage
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Application" = 0,
  "Start Date" = "SYSDATE",
  "End Date " = "SYSDATE",
  "Email to" = "",
  "Position" = 0
  WITH outdev, application, beg_dt_tm,
  end_dt_tm, email_add, position
 DECLARE session_time = f8 WITH noconstant(0), protect
 DECLARE any_status_ind = c1 WITH constant(substring(1,1,reflect(parameter(6,0)))), public
 SET operations = 0
 SET email_ind = 0
 EXECUTE bhs_ma_email_file
 RECORD user_usage(
   1 user[*]
     2 user_name = vc
     2 per_name = vc
     2 position = vc
     2 application = vc
     2 total_usage = f8
 )
 IF (validate(request->batch_selection))
  SET start_date = datetimeadd(cnvtdatetime(curdate,0),- (8))
  SET end_date = datetimeadd(cnvtdatetime(curdate,235959),- (1))
  SET send_mail =  $EMAIL_ADD
  SET operations = 1
 ELSE
  SET start_date = cnvtdatetime( $BEG_DT_TM)
  SET end_date = cnvtdatetime( $END_DT_TM)
  SET send_mail =  $EMAIL_ADD
  IF (datetimediff(cnvtdatetime( $END_DT_TM),cnvtdatetime( $BEG_DT_TM)) > 15)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Your date range is larger than 14 days.", msg2 = "  Please retry.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
   GO TO exit_prg
  ELSEIF (datetimediff(cnvtdatetime( $END_DT_TM),cnvtdatetime( $BEG_DT_TM)) < 0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Your date range is Negative days .", msg2 = "  Please retry.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08
   ;end select
   GO TO exit_prg
  ENDIF
 ENDIF
 IF (findstring("@",send_mail) > 0)
  SET email_ind = 1
  SET var_output = "bhs_firstnet_usage"
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
 ENDIF
 SELECT
  IF (any_status_ind="C")
   PLAN (b
    WHERE (b.application_number= $APPLICATION)
     AND b.start_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date))
    JOIN (p
    WHERE b.person_id=p.person_id)
    JOIN (a
    WHERE a.application_number=b.application_number)
  ELSE
  ENDIF
  INTO "nl:"
  b_position_disp = uar_get_code_display(b.position_cd), pat_name_id = concat(trim(p.name_last,3),
   trim(cnvtstring(p.person_id),3))
  FROM bhs_application_login_data b,
   prsnl p,
   application a
  PLAN (b
   WHERE (b.application_number= $APPLICATION)
    AND b.start_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date))
   JOIN (p
   WHERE b.person_id=p.person_id
    AND (p.position_cd= $POSITION))
   JOIN (a
   WHERE a.application_number=b.application_number)
  ORDER BY pat_name_id, b.start_dt_tm
  HEAD REPORT
   cnt = 0, cnta = 0, stat = alterlist(user_usage->user,10)
  HEAD pat_name_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(user_usage->user,(cnt+ 9))
   ENDIF
   user_usage->user[cnt].user_name = p.username, user_usage->user[cnt].per_name = concat(trim(p
     .name_last,3),", ",trim(p.name_first,3)), user_usage->user[cnt].position = b_position_disp,
   user_usage->user[cnt].application = a.description
  DETAIL
   cnta = (cnta+ 1), user_usage->user[cnt].total_usage = (datetimediff(b.end_dt_tm,b.start_dt_tm,4)+
   user_usage->user[cnt].total_usage), user_usage->user[cnt].total_usage = round(user_usage->user[cnt
    ].total_usage,2)
  FOOT  pat_name_id
   cnta = 0
  FOOT REPORT
   stat = alterlist(user_usage->user,cnt)
  WITH nocounter, time = 120
 ;end select
 CALL echorecord(user_usage)
 IF (email_ind=0)
  SELECT INTO value(var_output)
   emp_num = substring(3,30,user_usage->user[d1.seq].user_name), name = substring(1,30,user_usage->
    user[d1.seq].per_name), position = substring(1,30,user_usage->user[d1.seq].position),
   application = substring(1,30,user_usage->user[d1.seq].application), total_usage_minutes =
   user_usage->user[d1.seq].total_usage
   FROM (dummyt d1  WITH seq = value(size(user_usage->user,5)))
   PLAN (d1)
   WITH nocounter, separator = " ", format,
    time = 120
  ;end select
 ELSEIF (email_ind=1)
  SELECT INTO value(var_output)
   emp_num = concat('"',substring(3,30,user_usage->user[d1.seq].user_name),'"'), name = substring(1,
    30,user_usage->user[d1.seq].per_name), position = substring(1,30,user_usage->user[d1.seq].
    position),
   application = substring(1,30,user_usage->user[d1.seq].application), total_usage_minutes =
   user_usage->user[d1.seq].total_usage
   FROM (dummyt d1  WITH seq = value(size(user_usage->user,5)))
   PLAN (d1)
   WITH nocounter, format, pcformat('"',"	"),
    time = 120
  ;end select
  SET filename_in = trim(concat(var_output,".dat"))
  SET email_address = trim(send_mail)
  SET filename_out = "bhs_firstnet_usage.xls"
  SET subject = concat("FirstNet Login Times")
  CALL emailfile(filename_in,filename_out,email_address,subject,1)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat("File has been emailed to: ",email_address), col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
#exit_prg
END GO
