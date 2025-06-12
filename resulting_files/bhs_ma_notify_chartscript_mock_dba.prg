CREATE PROGRAM bhs_ma_notify_chartscript_mock:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter a date (yyyymmdd):" = ""
  WITH outdev, strdate
 IF (( $STRDATE=""))
  SET sdatediff = datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(curdate,0),3)
  IF (sdatediff < 4)
   SET sdate = format(cnvtdatetime((curdate - 1),0),"yyyymmdd;;d")
  ELSE
   SET sdate = format(curdate,"yyyymmdd;;d")
  ENDIF
 ELSE
  SET sdate = trim( $2,3)
 ENDIF
 SET cnt = 0
 DECLARE record_type = c6
 DECLARE pos_comma1 = i4
 DECLARE pos_comma2 = i4
 SET i_prsnl_alias_type_cd = uar_get_code_by("DISPLAYKEY",320,"ORGANIZATIONDOCTOR")
 SET i_alias_pool_cd = uar_get_code_by("DISPLAYKEY",263,"BHSORGNUMBER")
 SET i_data_status_cd = uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")
 SET email_add = "'andrea.galiatsos@bhs.org'"
 SET store_directory = "/cerner/d_prod/esa/esa_in/"
 SET invalid_filename = "invalid_file.dat"
 SET new_chart_file = "/cerner/d_prod/esa/esa_out/chartscript_file.dat"
 DECLARE new_text_id(dummy1) = f8
 SUBROUTINE new_text_id(dummy1)
   SET text_id = 0.0
   SELECT INTO "nl:"
    next_id = seq(long_data_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     text_id = cnvtreal(next_id)
    WITH format, nocounter
   ;end select
   RETURN(text_id)
 END ;Subroutine
 DECLARE new_task_id(dummy1) = f8
 SUBROUTINE new_task_id(dummy1)
   SET task_id = 0.0
   SELECT INTO "nl:"
    next_id = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     task_id = cnvtreal(next_id)
    WITH format, nocounter
   ;end select
   RETURN(task_id)
 END ;Subroutine
 DECLARE new_task_assign_id(dummy1) = f8
 SUBROUTINE new_task_assign_id(dummy1)
   SET task_assign_id = 0.0
   SELECT INTO "nl:"
    next_id = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     task_assign_id = cnvtreal(next_id)
    WITH format, nocounter
   ;end select
   RETURN(task_assign_id)
 END ;Subroutine
 SET i_system_id = 18015671
 SET i_task_type_cd = uar_get_code_by("DISPLAYKEY",6026,"PHONEMSG")
 SET i_active_status_cd = uar_get_code_by("DISPLAYKEY",48,"ACTIVE")
 SET i_task_activity_cd = uar_get_code_by("DISPLAYKEY",6027,"COMPLETEPERSONAL")
 SET i_task_deleted_cd = uar_get_code_by("DISPLAYKEY",79,"DELETED")
 SET i_task_pending_cd = uar_get_code_by("DISPLAYKEY",79,"PENDING")
 SUBROUTINE insert_messages(v_task_id,v_task_act_assign_id,v_text_id,v_to_id,v_msg_subject,
  v_msg_letter,v_stat_ind)
   SET i_reference_task_id = 0
   SELECT INTO "nl:"
    FROM order_task ot
    WHERE ot.task_description="Phone Message"
     AND ot.active_ind=1
     AND ot.task_activity_cd=i_task_activity_cd
     AND ot.task_type_cd=i_task_type_cd
    DETAIL
     i_reference_task_id = ot.reference_task_id
    WITH nocounter
   ;end select
   INSERT  FROM task_activity
    SET active_ind = 1, active_status_cd = i_active_status_cd, active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     active_status_prsnl_id = i_system_id, msg_sender_id = i_system_id, msg_text_id = v_text_id,
     msg_subject = v_msg_subject, reference_task_id = i_reference_task_id, stat_ind = v_stat_ind,
     task_activity_cd = i_task_activity_cd, task_create_dt_tm = cnvtdatetime(curdate,curtime3),
     task_id = v_task_id,
     task_status_cd = i_task_pending_cd, task_type_cd = i_task_type_cd, updt_cnt = 0,
     updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = i_system_id
   ;end insert
   INSERT  FROM task_activity_assignment
    SET active_ind = 1, assign_prsnl_id = v_to_id, beg_eff_dt_tm = cnvtdatetime(curdate,curtime3),
     end_eff_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), msg_text_id = v_text_id,
     task_activity_assign_id = v_task_act_assign_id,
     task_id = v_task_id, task_status_cd = i_task_pending_cd, updt_cnt = 0,
     updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = i_system_id
   ;end insert
   INSERT  FROM long_text
    SET active_ind = 1, active_status_cd = i_active_status_cd, active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     active_status_prsnl_id = i_system_id, long_text = v_msg_letter, long_text_id = v_text_id,
     parent_entity_id = v_text_id, parent_entity_name = "TASK_ACTIVITY", updt_cnt = 0,
     updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = i_system_id
   ;end insert
   COMMIT
 END ;Subroutine
 SUBROUTINE remove_udocs_messages(v_to_id)
   SET i_resch_reason_cd = uar_get_code_by("DISPLAYKEY",6014,"ABNORMALLAB")
   SET update_cnt = 0
   RECORD data(
     1 qual[*]
       2 task_id = f8
   )
   SELECT INTO "nl:"
    FROM task_activity ta,
     task_activity_assignment taa
    PLAN (ta
     WHERE ta.msg_sender_id=i_system_id
      AND ta.task_type_cd=i_task_type_cd
      AND trim(ta.msg_subject)=value(concat(unsigned_docs_subject1,"*")))
     JOIN (taa
     WHERE taa.task_id=ta.task_id
      AND taa.assign_prsnl_id=v_to_id
      AND taa.task_status_cd != i_task_deleted_cd)
    HEAD REPORT
     stat = alterlist(data->qual,10)
    DETAIL
     update_cnt = (update_cnt+ 1)
     IF (mod(update_cnt,10)=0
      AND update_cnt != 1)
      stat = alterlist(data->qual,(update_cnt+ 10))
     ENDIF
     data->qual[update_cnt].task_id = ta.task_id, col 0, ta.task_id,
     row + 1
    FOOT REPORT
     IF (update_cnt > 0)
      stat = alterlist(data->qual,update_cnt)
     ENDIF
    WITH nocounter
   ;end select
   SET y = 0
   FOR (y = 1 TO update_cnt)
     UPDATE  FROM task_activity
      SET reschedule_reason_cd = i_resch_reason_cd, updt_cnt = (updt_cnt+ 1), updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       updt_id = i_system_id
      WHERE (task_id=data->qual[y].task_id)
     ;end update
     UPDATE  FROM task_activity_assignment
      SET task_status_cd = i_task_deleted_cd, updt_cnt = (updt_cnt+ 1), updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       updt_id = i_system_id
      WHERE (task_id=data->qual[y].task_id)
     ;end update
     IF (mod(y,10)=1
      AND y != 1)
      COMMIT
     ENDIF
   ENDFOR
   COMMIT
 END ;Subroutine
 SUBROUTINE remove_def_messages(v_to_id,v_subject)
   SET i_resch_reason_cd = uar_get_code_by("DISPLAYKEY",6014,"ABNORMALLAB")
   SET update_cnt = 0
   RECORD data(
     1 qual[*]
       2 task_id = f8
   )
   SELECT INTO "nl:"
    FROM task_activity ta,
     task_activity_assignment taa
    PLAN (ta
     WHERE ta.msg_sender_id=i_system_id
      AND ta.task_type_cd=i_task_type_cd
      AND trim(ta.msg_subject)=value(concat("*",v_subject)))
     JOIN (taa
     WHERE taa.task_id=ta.task_id
      AND taa.assign_prsnl_id=v_to_id
      AND taa.task_status_cd != i_task_deleted_cd)
    HEAD REPORT
     stat = alterlist(data->qual,10)
    DETAIL
     update_cnt = (update_cnt+ 1)
     IF (mod(update_cnt,10)=0
      AND update_cnt != 1)
      stat = alterlist(data->qual,(update_cnt+ 10))
     ENDIF
     data->qual[update_cnt].task_id = ta.task_id, col 0, ta.task_id,
     row + 1
    FOOT REPORT
     IF (update_cnt > 0)
      stat = alterlist(data->qual,update_cnt)
     ENDIF
    WITH nocounter
   ;end select
   SET y = 0
   FOR (y = 1 TO update_cnt)
     UPDATE  FROM task_activity
      SET reschedule_reason_cd = i_resch_reason_cd, updt_cnt = (updt_cnt+ 1), updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       updt_id = i_system_id
      WHERE (task_id=data->qual[y].task_id)
     ;end update
     UPDATE  FROM task_activity_assignment
      SET task_status_cd = i_task_deleted_cd, updt_cnt = (updt_cnt+ 1), updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       updt_id = i_system_id
      WHERE (task_id=data->qual[y].task_id)
     ;end update
     IF (mod(y,10)=1
      AND y != 1)
      COMMIT
     ENDIF
   ENDFOR
   COMMIT
 END ;Subroutine
 SET cr = char(13)
 SET msg_date_time = concat("::Date/Time: ",format(cnvtdatetime(curdate,curtime3),
   "mm/dd/yyyy hh:mm;;q"))
 SET msg_physician = "Physician: "
 SET msg_facility = "Facility:  "
 SET msg_salutation = "Message from Health Information Management (Medical Records Dept.):"
 SET msg_bhs_phone = "413-794-2467"
 SET msg_fmc_phone = "413-773-2239"
 SET msg_mlh_phone = "413-967-2145"
 SET msg_gen_line1 = "This is your electronic notification of your incomplete medical records at "
 SET msg_gen_line2 =
 "According to Medical Staff Rules and Regulations you can be suspended for incomplete"
 SET msg_gen_line3 = "delinquent medical records."
 SET msg_youhave = "You have:"
 SET msg_susp_line1 = "Please be advised that the following records at"
 SET msg_susp_line2 = "remain incomplete"
 SET msg_susp_line3 = "more than 14 days after the date of discharge.  Your delinquent"
 SET msg_susp_line4 = "medical records MUST  be completed  by Wednesday"
 SET msg_susp_line5 = "at NOON in order to avoid suspension."
 SET msg_med_recs1 = "Please contact Medical Records at"
 SET msg_med_recs2 = "with any questions.  You will also"
 SET msg_med_recs3 = "receive a letter/fax notification with specific details."
 SET msg_cis = "records to sign in CIS"
 SET msg_esa = "reports to sign using ESA - Documents to Sign link"
 SET msg_dictate = "records to dictate (Please visit Medical Records)"
 SET msg_other = "records wtih other deficiencies (Please visit Medical Records)"
 SET general_subject = "General Letter Deficiency Notification from "
 SET suspend_subject = "Suspension Letter Deficiency Notification from "
 SET no_def_subject = "No Deficiency Notification from "
 SET subject_line2 = " HIM"
 SET unsigned_docs_subject1 = "Dictated Document(s) ("
 SET unsigned_docs_subject2 =
 ") requiring electronic signature. Please complete these using ESA - Documents to Sign link."
 SET x = 0
 FOR (x = 1 TO 7)
  SET temp_day = format((curdate+ x),"www;;d")
  IF (temp_day="WED")
   SET susp_date = format((curdate+ x),"mm/dd/yyyy;;d")
  ENDIF
 ENDFOR
 RECORD msg(
   1 message_cnt = i4
   1 message[*]
     2 facility = vc
     2 facility_abbr = c3
     2 receiver_id = f8
     2 long_text_id = f8
     2 task_id = f8
     2 task_assign_id = f8
     2 subject = vc
     2 phys_nbr = vc
     2 phys_id = f8
     2 phys_name = vc
     2 cis_docs = f8
     2 esa_docs = f8
     2 dictate_docs = f8
     2 other_docs = f8
     2 letter = c32000
     2 letter_type = i2
     2 stat_ind = i1
     2 nbr_unsigned_docs = f8
     2 print_flag = i1
     2 cs_phys_name = vc
     2 invalid_reason = vc
     2 med_recs_phone = c12
     2 phys_username = vc
 )
 SET cnt = 0
 SET errmsg = fillstring(132," ")
 SET errcode = 1
 SET stat = alterlist(msg->message,10)
 SET filename = concat("/cerner/d_mock/ccluserdir/200801221845.dat")
 FREE DEFINE rtl
 SET logical msg_file filename
 DEFINE rtl "msg_file"
 SET errcode = error(errmsg,1)
 CALL echo(build("error_cd:",errcode))
 IF (errcode > 0)
  GO TO endprog
 ENDIF
 CALL read_chartscript_file(msg->message_cnt)
 IF (cnt > 0)
  SET stat = alterlist(msg->message,cnt)
  SET msg->message_cnt = cnt
 ENDIF
 SELECT INTO "nl:"
  pa.person_id, pa.beg_effective_dt_tm
  FROM (dummyt d  WITH seq = value(msg->message_cnt)),
   prsnl_alias pa,
   prsnl p
  PLAN (d)
   JOIN (pa
   WHERE (pa.alias=msg->message[d.seq].phys_nbr)
    AND pa.alias_pool_cd=i_alias_pool_cd
    AND pa.prsnl_alias_type_cd=i_prsnl_alias_type_cd
    AND ((pa.active_ind+ 0)=1)
    AND ((pa.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
    AND ((pa.data_status_cd+ 0)=i_data_status_cd))
   JOIN (p
   WHERE p.person_id=pa.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND p.physician_ind=1)
  ORDER BY pa.person_id, pa.beg_effective_dt_tm DESC
  DETAIL
   msg->message[d.seq].phys_id = p.person_id, msg->message[d.seq].phys_name = concat(trim(p
     .name_first,3)," ",trim(p.name_last,3)), msg->message[d.seq].phys_username = trim(p.username,3)
   IF ((msg->message[d.seq].nbr_unsigned_docs=0))
    msg->message[d.seq].print_flag = 0
   ELSE
    msg->message[d.seq].print_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(msg->message_cnt))
  WHERE (msg->message[d.seq].phys_id > 0)
  DETAIL
   msg->message[d.seq].receiver_id = msg->message[d.seq].phys_id, msg->message[d.seq].subject =
   concat(unsigned_docs_subject1," ",trim(cnvtstring(msg->message[d.seq].nbr_unsigned_docs),3)," ",
    unsigned_docs_subject2), msg->message[d.seq].letter = concat(msg_date_time,cr,msg_physician,msg->
    message[d.seq].phys_nbr," ",
    msg->message[d.seq].phys_name,cr,cr,unsigned_docs_subject1," ",
    trim(cnvtstring(msg->message[d.seq].nbr_unsigned_docs),3)," ",unsigned_docs_subject2)
  WITH nocounter
 ;end select
 SET x = 0
 FOR (x = 1 TO msg->message_cnt)
   CALL remove_udocs_messages(msg->message[x].receiver_id)
 ENDFOR
 SET x = 0
 FOR (x = 1 TO msg->message_cnt)
   IF ((msg->message[x].print_flag=1))
    SET msg->message[x].task_id = new_task_id(1)
    SET msg->message[x].long_text_id = new_text_id(1)
    SET msg->message[x].task_assign_id = new_task_assign_id(1)
    CALL insert_messages(msg->message[x].task_id,msg->message[x].task_assign_id,msg->message[x].
     long_text_id,msg->message[x].receiver_id,msg->message[x].subject,
     msg->message[x].letter,msg->message[x].stat_ind)
   ENDIF
 ENDFOR
 CALL modify_invalid_file(1)
 SELECT INTO value(new_chart_file)
  output_string = concat(trim(msg->message[d.seq].phys_nbr),",",trim(cnvtstring(msg->message[d.seq].
     nbr_unsigned_docs),3),",",trim(msg->message[d.seq].phys_username,3))
  FROM (dummyt d  WITH seq = value(msg->message_cnt))
  PLAN (d)
  DETAIL
   col 0, output_string, row + 1
  WITH formfeed = none
 ;end select
 SET dclcom = concat("rm ",filename)
 SET len = size(trim(dclcom))
 SET status = 0
 CALL dcl(dclcom,len,status)
 SUBROUTINE read_chartscript_file(v_cnt)
   SELECT INTO "nl:"
    r.*
    FROM rtlt r
    HEAD REPORT
     cnt = v_cnt, pass = 0
    DETAIL
     IF (pass > 0)
      IF (trim(substring(1,12,r.line),3) != " "
       AND cnvtint(trim(substring(38,5,r.line),3)) > 0)
       cnt = (cnt+ 1)
       IF (mod(cnt,10)=1
        AND cnt != 0)
        stat = alterlist(msg->message,(cnt+ 10))
       ENDIF
       msg->message[cnt].phys_nbr = trim(substring(1,12,r.line),3), msg->message[cnt].
       nbr_unsigned_docs = cnvtint(trim(substring(38,5,r.line),3)), msg->message[cnt].cs_phys_name =
       trim(substring(13,25,r.line),3),
       msg->message[cnt].print_flag = 0
      ENDIF
     ENDIF
     pass = 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE modify_invalid_file(dummy1)
   SET invalid_file = 0
   SET email_file = concat(store_directory,invalid_filename)
   SET stat = findfile(email_file)
   IF (stat=1)
    SELECT INTO value(email_file)
     current_date = format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;q")
     FROM (dummyt d  WITH seq = value(msg->message_cnt))
     WHERE (msg->message[d.seq].print_flag=0)
     DETAIL
      IF ((msg->message[d.seq].phys_nbr != ""))
       invalid_file = (invalid_file+ 1), col 0, msg->message[d.seq].phys_nbr,
       col 20, msg->message[d.seq].cs_phys_name, col 50,
       msg->message[d.seq].nbr_unsigned_docs";l", col 65, msg->message[d.seq].cis_docs";l",
       col 70, msg->message[d.seq].esa_docs";l", col 75,
       msg->message[d.seq].dictate_docs";l", col 85, msg->message[d.seq].other_docs";l",
       col 95, current_date, row + 1
      ENDIF
     WITH nocounter, append
    ;end select
   ELSE
    SELECT INTO value(email_file)
     current_date = format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;q")
     FROM (dummyt d  WITH seq = value(msg->message_cnt))
     WHERE (msg->message[d.seq].print_flag=0)
     DETAIL
      IF ((msg->message[d.seq].phys_nbr != ""))
       invalid_file = (invalid_file+ 1), col 0, msg->message[d.seq].phys_nbr,
       col 20, msg->message[d.seq].cs_phys_name, col 50,
       msg->message[d.seq].nbr_unsigned_docs";l", col 65, msg->message[d.seq].cis_docs";l",
       col 70, msg->message[d.seq].esa_docs";l", col 75,
       msg->message[d.seq].dictate_docs";l", col 85, msg->message[d.seq].other_docs";l",
       col 95, current_date, row + 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
#endprog
END GO
