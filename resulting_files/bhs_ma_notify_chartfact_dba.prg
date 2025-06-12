CREATE PROGRAM bhs_ma_notify_chartfact:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter a facility (BMC, FMC, MLH, BWH, BNH):" = "",
  "Enter a date (yymmdd):" = ""
  WITH outdev, strfacility, strdate
 IF (( $2="BMC"))
  SET strfacility = "01"
  SET facility_flg = "Y"
 ELSEIF (( $2="FMC"))
  SET strfacility = "02"
  SET facility_flg = "Y"
 ELSEIF (( $2="MLH"))
  SET strfacility = "03"
  SET facility_flg = "Y"
 ELSEIF (( $2="BWH"))
  SET strfacility = "04"
  SET facility_flg = "Y"
 ELSEIF (( $2="BNH"))
  SET strfacility = "05"
  SET facility_flg = "Y"
 ELSE
  SET strfacility = ""
 ENDIF
 IF (( $3=""))
  SET strdate = format((curdate - 1),"yymmdd;;d")
 ELSE
  SET strdate =  $3
 ENDIF
 SET cnt = 0
 DECLARE record_type = c6
 DECLARE pos_comma1 = i4
 DECLARE pos_comma2 = i4
 SET i_prsnl_alias_type_cd = uar_get_code_by("DISPLAYKEY",320,"ORGANIZATIONDOCTOR")
 SET i_alias_pool_cd = uar_get_code_by("DISPLAYKEY",263,"BHSORGNUMBER")
 SET i_data_status_cd = uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")
 SET email_add = "'andrea.galiatsos@bhs.org'"
 SET home_dir = "/cerner/d_test/esa/eletter_in/"
 SET invalid_filename = "invalid_file.dat"
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
      AND ta.msg_subject=value(concat(unsigned_docs_subject1,"*")))
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
      AND ta.msg_subject=value(concat("*",v_subject)))
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
 SET cr = char(10)
 SET msg_date_time = concat("::Date/Time: ",format(cnvtdatetime(curdate,curtime3),
   "mm/dd/yyyy hh:mm;;q"))
 SET msg_physician = "Physician: "
 SET msg_facility = "Facility:  "
 SET msg_salutation = "Message from Health Information Management (Medical Records Dept.):"
 SET msg_bhs_phone = "413-794-2467"
 SET msg_fmc_phone = "413-773-2239"
 SET msg_mlh_phone = "413-967-2145"
 SET msg_bwh_phone = ""
 SET msg_bnh_phone = ""
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
     2 facility_abbr = c4
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
     2 remove_string = vc
 )
 SET filename = fillstring(70," ")
 SET cnt = 0
 SET stat = alterlist(msg->message,10)
 SET errmsg = fillstring(132," ")
 SET errcode = 1
 SET filename = concat(home_dir,"01_General_",strdate,"_1.TXT")
 FREE DEFINE rtl2
 SET logical msg_file filename
 DEFINE rtl2 "msg_file"
 SET errcode = error(errmsg,1)
 CALL echo(build("error_cd:",errcode))
 IF (errcode=0)
  CALL read_files(msg->message_cnt)
  SET cnt = (cnt+ 1)
 ENDIF
 SET filename = concat(home_dir,"01_Suspension_",strdate,"_1.TXT")
 FREE DEFINE rtl2
 SET logical msg_file filename
 DEFINE rtl2 "msg_file"
 SET errcode = error(errmsg,1)
 CALL echo(build("error_cd:",errcode))
 IF (errcode=0)
  CALL read_files(msg->message_cnt)
  SET cnt = (cnt+ 1)
 ENDIF
 SET filename = concat(home_dir,"02_General_",strdate,"_1.TXT")
 FREE DEFINE rtl2
 SET logical msg_file filename
 DEFINE rtl2 "msg_file"
 SET errcode = error(errmsg,1)
 CALL echo(build("error_cd:",errcode))
 IF (errcode=0)
  CALL read_files(msg->message_cnt)
  SET cnt = (cnt+ 1)
 ENDIF
 SET filename = concat(home_dir,"02_General_",strdate,"_2.TXT")
 FREE DEFINE rtl2
 SET logical msg_file filename
 DEFINE rtl2 "msg_file"
 SET errcode = error(errmsg,1)
 CALL echo(build("error_cd:",errcode))
 IF (errcode=0)
  CALL read_files(msg->message_cnt)
  SET cnt = (cnt+ 1)
 ENDIF
 SET filename = concat(home_dir,"02_Suspension_",strdate,"_1.TXT")
 FREE DEFINE rtl2
 SET logical msg_file filename
 DEFINE rtl2 "msg_file"
 SET errcode = error(errmsg,1)
 CALL echo(build("error_cd:",errcode))
 IF (errcode=0)
  CALL read_files(msg->message_cnt)
  SET cnt = (cnt+ 1)
 ENDIF
 SET filename = concat(home_dir,"03_General_",strdate,"_1.TXT")
 FREE DEFINE rtl2
 SET logical msg_file filename
 DEFINE rtl2 "msg_file"
 SET errcode = error(errmsg,1)
 CALL echo(build("error_cd:",errcode))
 IF (errcode=0)
  CALL read_files(msg->message_cnt)
  SET cnt = (cnt+ 1)
 ENDIF
 SET filename = concat(home_dir,"03_Suspension_",strdate,"_1.TXT")
 FREE DEFINE rtl2
 SET logical msg_file filename
 DEFINE rtl2 "msg_file"
 SET errcode = error(errmsg,1)
 CALL echo(build("error_cd:",errcode))
 IF (errcode=0)
  CALL read_files(msg->message_cnt)
  SET cnt = (cnt+ 1)
 ENDIF
 IF (cnt=0)
  GO TO endprog
 ELSE
  SET cnt = 0
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
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND pa.data_status_cd=i_data_status_cd)
   JOIN (p
   WHERE p.person_id=pa.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND p.physician_ind=1)
  ORDER BY pa.person_id, pa.beg_effective_dt_tm DESC
  DETAIL
   msg->message[d.seq].phys_id = p.person_id, msg->message[d.seq].phys_name = concat(trim(p
     .name_first,3)," ",trim(p.name_last,3)), msg->message[d.seq].phys_username = trim(p.username,3),
   msg->message[d.seq].print_flag = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(msg->message_cnt))
  WHERE (msg->message[d.seq].phys_id > 0)
  DETAIL
   msg->message[d.seq].receiver_id = msg->message[d.seq].phys_id
   IF ((msg->message[d.seq].letter_type=1))
    msg->message[d.seq].stat_ind = 0, msg->message[d.seq].subject = concat(general_subject,msg->
     message[d.seq].facility_abbr,subject_line2), msg->message[d.seq].letter = concat(msg_date_time,
     cr,msg_physician,msg->message[d.seq].phys_nbr," ",
     msg->message[d.seq].phys_name,cr,msg_facility,msg->message[d.seq].facility,cr,
     cr,msg_salutation,cr,cr,msg_gen_line1,
     " ",msg->message[d.seq].facility_abbr,".",cr,msg_gen_line2,
     cr,msg_gen_line3,cr,cr,msg_med_recs1,
     " ",msg->message[d.seq].med_recs_phone," ",msg_med_recs2,cr,
     msg_med_recs3,cr,cr,msg_youhave,cr,
     cnvtstring(msg->message[d.seq].cis_docs)," ",msg_cis,cr,cnvtstring(msg->message[d.seq].esa_docs),
     " ",msg_esa,cr,cnvtstring(msg->message[d.seq].dictate_docs)," ",
     msg_dictate,cr,cnvtstring(msg->message[d.seq].other_docs)," ",msg_other)
   ELSEIF ((msg->message[d.seq].letter_type=2))
    msg->message[d.seq].stat_ind = 1, msg->message[d.seq].subject = concat(suspend_subject,msg->
     message[d.seq].facility_abbr,subject_line2), msg->message[d.seq].letter = concat(msg_date_time,
     cr,msg_physician,msg->message[d.seq].phys_nbr," ",
     msg->message[d.seq].phys_name,cr,msg_facility,msg->message[d.seq].facility,cr,
     cr,msg_salutation,cr,cr,msg_susp_line1,
     " ",msg->message[d.seq].facility_abbr," ",msg_susp_line2,cr,
     msg_susp_line3,cr,msg_susp_line4,", ",susp_date,
     ",",cr,msg_susp_line5,cr,cr,
     msg_med_recs1," ",msg->message[d.seq].med_recs_phone," ",msg_med_recs2,
     cr,msg_med_recs3,cr,cr,msg_youhave,
     cr,cnvtstring(msg->message[d.seq].cis_docs)," ",msg_cis,cr,
     cnvtstring(msg->message[d.seq].esa_docs)," ",msg_esa,cr,cnvtstring(msg->message[d.seq].
      dictate_docs),
     " ",msg_dictate,cr,cnvtstring(msg->message[d.seq].other_docs)," ",
     msg_other)
   ELSEIF ((msg->message[d.seq].letter_type=3))
    msg->message[d.seq].subject = concat(unsigned_docs_subject1," ",trim(cnvtstring(msg->message[d
       .seq].nbr_unsigned_docs),3)," ",unsigned_docs_subject2), msg->message[d.seq].letter = concat(
     msg_date_time,cr,msg_physician,msg->message[d.seq].phys_nbr," ",
     msg->message[d.seq].phys_name,cr,cr,unsigned_docs_subject1," ",
     trim(cnvtstring(msg->message[d.seq].nbr_unsigned_docs),3)," ",unsigned_docs_subject2)
   ENDIF
  WITH nocounter
 ;end select
 SET x = 0
 FOR (x = 1 TO msg->message_cnt)
   CALL remove_def_messages(msg->message[x].receiver_id,msg->message[x].remove_string)
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
 CALL send_invalid_file(1)
 SELECT INTO  $OUTDEV
  FROM (dummyt d1  WITH seq = value(msg->message_cnt))
  DETAIL
   col 0, msg->message[d1.seq].phys_id";l", col 15,
   msg->message[d1.seq].long_text_id";l", col 30, msg->message[d1.seq].task_id";l",
   col 45, msg->message[d1.seq].task_assign_id";l", col 60,
   msg->message[d1.seq].phys_nbr, col 60, msg->message[d1.seq].phys_name,
   col 90, msg->message[d1.seq].subject, row + 1
  WITH nocounter, maxcol = 300
 ;end select
 SUBROUTINE read_files(v_cnt)
   SET facility = fillstring(15," ")
   SET letter_type = fillstring(15," ")
   SELECT INTO "nl:"
    r.*
    FROM rtl2t r
    HEAD REPORT
     cnt = v_cnt, pos_comma1 = findstring(",",r.line,0), pos_comma1 = findstring(",",r.line,(
      pos_comma1+ 1)),
     pos_comma1 = findstring(",",r.line,(pos_comma1+ 1)), pos_comma2 = findstring(",",r.line,(
      pos_comma1+ 1)), facility = trim(substring((pos_comma1+ 1),((pos_comma2 - pos_comma1) - 1),r
       .line),3)
     IF (size(trim(facility,3))=1)
      facility = concat("00",facility)
     ELSEIF (size(trim(facility,3))=2)
      facility = concat("0",facility)
     ENDIF
     pos_comma1 = pos_comma2, pos_comma2 = findstring(",",r.line,(pos_comma1+ 1)), letter_type =
     cnvtupper(trim(substring((pos_comma1+ 1),((pos_comma2 - pos_comma1) - 1),r.line),3))
     IF (letter_type="GENERAL")
      letter_type_ind = 1
     ELSEIF (letter_type="SUSPENSION")
      letter_type_ind = 2
     ELSE
      letter_type_ind = 0
     ENDIF
    DETAIL
     pos_comma1 = findstring(",",r.line,0), pos_comma2 = 1
     IF (pos_comma1 > 0)
      record_type = cnvtupper(substring(1,(pos_comma1 - 1),r.line))
     ELSE
      record_type = ""
     ENDIF
     IF (record_type="NOTIFY")
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=0
       AND cnt != 1)
       stat = alterlist(msg->message,(cnt+ 10))
      ENDIF
      IF (facility="001")
       msg->message[cnt].facility = "01 - Baystate Medical Center", msg->message[cnt].facility_abbr
        = "BMC", msg->message[cnt].med_recs_phone = msg_bhs_phone,
       msg->message[cnt].remove_string = "Notification from BMC HIM"
      ELSEIF (facility="002")
       msg->message[cnt].facility = "02 - Baystate Franklin Medical Center", msg->message[cnt].
       facility_abbr = "BFMC", msg->message[cnt].med_recs_phone = msg_fmc_phone,
       msg->message[cnt].remove_string = "Notification from BFMC HIM"
      ELSEIF (facility="003")
       msg->message[cnt].facility = "03 - Baystate Mary Lane Hospital", msg->message[cnt].
       facility_abbr = "BMLH", msg->message[cnt].med_recs_phone = msg_mlh_phone,
       msg->message[cnt].remove_string = "Notification from BMLH HIM"
      ELSEIF (facility="004")
       msg->message[cnt].facility = "04 - Baystate Wing Hospital", msg->message[cnt].facility_abbr =
       "BWH", msg->message[cnt].med_recs_phone = msg_bwh_phone,
       msg->message[cnt].remove_string = "Notification from BWH HIM"
      ELSEIF (facility="005")
       msg->message[cnt].facility = "04 - Baystate Noble Hospital", msg->message[cnt].facility_abbr
        = "BNH", msg->message[cnt].med_recs_phone = msg_bnh_phone,
       msg->message[cnt].remove_string = "Notification from BNH HIM"
      ELSE
       msg->message[cnt].invalid_reason = "Invalid Facility"
      ENDIF
      msg->message[cnt].letter_type = letter_type_ind, pos_comma1 = findstring(",",r.line,(pos_comma2
       + 1)), y = 0
      FOR (y = 1 TO 5)
        pos_comma2 = findstring(",",r.line,(pos_comma1+ 1))
        IF (pos_comma2=0)
         temp_value = substring((pos_comma1+ 1),(size(r.line) - pos_comma1),r.line)
        ELSE
         temp_value = substring((pos_comma1+ 1),((pos_comma2 - pos_comma1) - 1),r.line)
        ENDIF
        CASE (y)
         OF 1:
          msg->message[cnt].phys_nbr = temp_value
         OF 2:
          msg->message[cnt].cis_docs = cnvtint(temp_value)
         OF 3:
          msg->message[cnt].esa_docs = cnvtint(temp_value)
         OF 4:
          msg->message[cnt].dictate_docs = cnvtint(temp_value)
         OF 5:
          msg->message[cnt].other_docs = cnvtint(temp_value)
        ENDCASE
        pos_comma1 = pos_comma2
      ENDFOR
      IF ((msg->message[cnt].cis_docs=0)
       AND (msg->message[cnt].esa_docs=0)
       AND (msg->message[cnt].dictate_docs=0)
       AND (msg->message[cnt].other_docs=0))
       msg->message[cnt].print_flag = 2
      ELSE
       msg->message[cnt].print_flag = 0
      ENDIF
     ENDIF
    FOOT REPORT
     msg->message_cnt = cnt
    WITH nocounter
   ;end select
   SET dclcom = concat("rm ",filename)
   SET len = size(trim(dclcom))
   SET status = 0
   CALL dcl(dclcom,len,status)
 END ;Subroutine
 SUBROUTINE send_invalid_file(dummy1)
   SET invalid_cnt = 0
   SET email_file = concat(home_dir,invalid_filename)
   SELECT INTO value(email_file)
    FROM (dummyt d  WITH seq = value(msg->message_cnt))
    WHERE (msg->message[d.seq].print_flag=0)
    HEAD REPORT
     col 0, "When processing the ChartFact files, the following physicians", row + 1,
     col 0, "did not have SoftMed IDs within the Cerner system:", row + 2,
     col 0, "SoftMed ID", col 20,
     "Physician Name", col 50, "# unsigned doc",
     col 65, "CIS", col 70,
     "ESA", col 75, "Dictated",
     col 85, "Other", row + 2
    DETAIL
     IF ((msg->message[d.seq].phys_nbr != ""))
      invalid_cnt = (invalid_cnt+ 1), col 0, msg->message[d.seq].phys_nbr
      IF ((msg->message[d.seq].letter_type=3))
       col 20, msg->message[d.seq].cs_phys_name
      ELSE
       col 20, msg->message[d.seq].phys_name
      ENDIF
      col 50, msg->message[d.seq].nbr_unsigned_docs";l", col 65,
      msg->message[d.seq].cis_docs";l", col 70, msg->message[d.seq].esa_docs";l",
      col 75, msg->message[d.seq].dictate_docs";l", col 85,
      msg->message[d.seq].other_docs";l", col 100, msg->message[d.seq].phys_id";l",
      row + 1
     ENDIF
    WITH nocounter
   ;end select
   IF (invalid_cnt > 0)
    SET email_subj = "'ChartFact Invalid Physician File'"
    SET email_file = concat(home_dir,invalid_filename)
    SET aix_command = concat("mailx -s ",email_subj," ",email_add," < ",
     email_file)
    SET email_size = size(trim(aix_command))
    SET comm_opt = 0
    CALL echo(email_size)
    CALL echo(aix_command)
    CALL dcl(aix_command,email_size,comm_opt)
    SET email_add = "'Chantou.Sevilla@bhs.org'"
    SET email_subj = "'ChartFact Invalid Physician File'"
    SET email_file = concat(store_directory,invalid_filename)
    SET aix_command = concat("mailx -s ",email_subj," ",email_add," < ",
     email_file)
    SET email_size = size(trim(aix_command))
    SET comm_opt = 0
    CALL echo(email_size)
    CALL echo(aix_command)
   ENDIF
 END ;Subroutine
#endprog
END GO
