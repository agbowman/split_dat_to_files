CREATE PROGRAM bhs_rpt_portal_patient_by_pool:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Select Pool" = 0,
  "Create File" = 0,
  "Enter Emails" = "",
  "Date Range" = "",
  "Remove Special Character From Phone Numbers" = 0,
  "Task Type" = 0.0,
  "Task Status" = 0.0
  WITH outdev, s_start_date, s_end_date,
  f_assign_grp, f_file, s_emails,
  s_range, s_remove_chars, f_task_type,
  f_task_status
 FREE RECORD m_rec
 RECORD m_rec(
   1 m_pcp_removed = i4
   1 m_pcp_only = i4
   1 m_pcp_priority = i4
   1 m_pcp_priority_add = i4
   1 total_messages = i4
   1 conv[*]
     2 f_conversation_id = f8
     2 f_pool_id = f8
     2 f_taskid = f8
     2 s_msg_subject1 = vc
     2 s_msg_subject2 = vc
     2 s_message_from = vc
     2 s_message_to = vc
     2 m_asterick1 = i4
     2 s_taskdate = vc
     2 m_message_removed = i4
     2 m_asterick2 = i4
     2 m_msgchange = vc
     2 f_enctrid = f8
     2 s_pool_name = vc
     2 s_pat_first_name = vc
     2 s_pat_last_name = vc
     2 s_cmrn = vc
     2 s_mrn = vc
     2 s_dob = vc
     2 f_msg_text_id = f8
     2 s_msg_text = vc
     2 s_task_type = vc
     2 s_task_status = vc
     2 s_email = vc
     2 s_mobile_num = vc
     2 s_language = vc
     2 s_home_phone = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 DECLARE mf_cs2026_phonemsg = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6026,"PHONEMSG")),
 protect
 DECLARE mf_cs43_home = f8 WITH constant(uar_get_code_by("DISPLAYKEY",43,"HOME")), protect
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_cs19189_poolgroup = f8 WITH constant(uar_get_code_by("DISPLAYKEY",19189,"POOLGROUP")),
 protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_cs43_externalsecure = f8 WITH constant(uar_get_code_by("DISPLAYKEY",43,"EXTERNALSECURE")),
 protect
 DECLARE mf_cs43_mobil_ph = f8 WITH constant(uar_get_code_by("DISPLAYKEY",43,"CELL")), protect
 DECLARE pl_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_start_date = vc WITH noconstant(format(cnvtdatetime(cnvtdate2( $S_START_DATE,
     "DD-MMM-YYYY"),0),"DD-MMM-YYYY hh:mm:ss;;Q")), protect
 DECLARE ms_end_date = vc WITH noconstant(format(cnvtdatetime(cnvtdate2( $S_END_DATE,"DD-MMM-YYYY"),
    235959),"DD-MMM-YYYY hh:mm:ss;;Q")), protect
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_subject = vc WITH protect, noconstant("              ")
 DECLARE ml1_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_pool_name = vc WITH protect
 DECLARE ms_pool_file = vc WITH protect
 DECLARE ms_opr_var = vc WITH protect
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ml_vasc_look_back = i4 WITH noconstant(0), protect
 DECLARE mf_contactcenternoninvasivescheduling = f8 WITH noconstant(22328883.0), protect
 DECLARE mf_consultwingcardiology = f8 WITH noconstant(20236678.00), protect
 DECLARE mf_consultcardiologygreenfield = f8 WITH noconstant(20166782.00), protect
 DECLARE mf_consultvascularservices = f8 WITH noconstant(9001555.00), protect
 DECLARE mf_consultnorthamptoncardiology = f8 WITH noconstant(9001549.00), protect
 DECLARE mf_consultcardiology3300main = f8 WITH noconstant(8330627.00), protect
 DECLARE mf_current_pool = f8 WITH noconstant(0.0), protect
 DECLARE ms_filename = vc WITH noconstant("pat_pool"), protect
 SELECT INTO "nl:"
  pg.prsnl_group_name_key
  FROM prsnl_group pg
  PLAN (pg
   WHERE (pg.prsnl_group_id= $F_ASSIGN_GRP)
    AND pg.prsnl_group_id > 0)
  HEAD pg.prsnl_group_id
   ms_pool_name = trim(pg.prsnl_group_name,3), ms_pool_file = trim(pg.prsnl_group_name_key),
   ms_pool_file = replace(replace(cnvtlower(trim(ms_pool_file,3))," ","_"),"-","_"),
   ms_filename = concat(trim(ms_filename,3),"_",ms_pool_file), mf_current_pool =  $F_ASSIGN_GRP
   IF (pg.prsnl_group_id IN (22328883.0, 20236678.0, 9001555.0, 9001549.0, 20166782.0,
   8330627.0))
    ml_vasc_look_back = 1
   ENDIF
  WITH nocounter
 ;end select
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),"_",format(sysdate,
    "YYYYMMDD;;q"),".csv")), protect
 CALL echo(build("ml_vasc_look_back = ",ml_vasc_look_back))
 FREE RECORD grec1
 RECORD grec1(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 IF (ms_lcheck="L")
  SET ms_opr_var = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_TASK_TYPE),ml_gcnt)))
    CALL echo(ms_lcheck)
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gcnt+ 4))
     ENDIF
     SET grec1->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_TASK_TYPE),ml_gcnt))
     SET grec1->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_TASK_TYPE),
       ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec1->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gcnt = 1
  SET grec1->list[1].f_cv =  $F_TASK_TYPE
  IF ((grec1->list[1].f_cv=0.0))
   SET grec1->list[1].s_disp = "All Task Types"
   SET ms_opr_var = "!="
  ELSE
   SET grec1->list[1].s_disp = uar_get_code_display(grec1->list[1].f_cv)
   SET ms_opr_var = "="
  ENDIF
 ENDIF
 SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_TASK_STATUS),0)))
 FREE RECORD grec2
 RECORD grec2(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 SET gcnt = 0
 IF (lcheck="L")
  SET ms_opr_var1 = "IN"
  WHILE (lcheck > " ")
    SET gcnt += 1
    SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_TASK_STATUS),gcnt)))
    CALL echo(lcheck)
    IF (lcheck > " ")
     IF (mod(gcnt,5)=1)
      SET stat = alterlist(grec2->list,(gcnt+ 4))
     ENDIF
     SET grec2->list[gcnt].f_cv = cnvtint(parameter(parameter2( $F_TASK_STATUS),gcnt))
     SET grec2->list[gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_TASK_STATUS),gcnt))
    ENDIF
  ENDWHILE
  SET gcnt -= 1
  SET stat = alterlist(grec2->list,gcnt)
 ELSE
  SET stat = alterlist(grec2->list,1)
  SET gcnt = 1
  SET grec2->list[1].f_cv =  $F_TASK_STATUS
  IF ((grec2->list[1].f_cv=0.0))
   SET grec2->list[1].s_disp = "All Task Statuses"
   SET ms_opr_var1 = "!="
  ELSE
   SET grec2->list[1].s_disp = uar_get_code_display(grec2->list[1].f_cv)
   SET ms_opr_var1 = "="
  ENDIF
 ENDIF
 IF (cnvtupper(trim( $S_RANGE,3))="DAILY")
  IF (mf_current_pool=mf_contactcenternoninvasivescheduling)
   SET ms_start_date = format(cnvtdatetime("01-JAN-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultwingcardiology)
   SET ms_start_date = format(cnvtdatetime("01-OCT-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultcardiologygreenfield)
   SET ms_start_date = format(cnvtdatetime("01-DEC-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultvascularservices)
   SET ms_start_date = format(cnvtdatetime("20-NOV-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultnorthamptoncardiology)
   SET ms_start_date = format(cnvtdatetime("01-DEC-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultcardiology3300main)
   SET ms_start_date = format(cnvtdatetime("04-SEP-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSE
   SET ms_start_date = format(cnvtdatetime("01-JAN-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ENDIF
  SET ms_end_date = format(datetimefind(cnvtlookbehind("0,D",cnvtdatetime(curdate,235959)),"D","E",
    "E"),"DD-MMM-YYYY hh:mm:ss;;D")
 ELSEIF (cnvtupper(trim( $S_RANGE,3))="WEEKLY")
  IF (mf_current_pool=mf_contactcenternoninvasivescheduling)
   SET ms_start_date = format(cnvtdatetime("01-JAN-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultwingcardiology)
   SET ms_start_date = format(cnvtdatetime("01-OCT-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultcardiologygreenfield)
   SET ms_start_date = format(cnvtdatetime("01-DEC-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultvascularservices)
   SET ms_start_date = format(cnvtdatetime("20-NOV-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultnorthamptoncardiology)
   SET ms_start_date = format(cnvtdatetime("01-DEC-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultcardiology3300main)
   SET ms_start_date = format(cnvtdatetime("04-SEP-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSE
   SET ms_start_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","B","B"),
    "DD-MMM-YYYY hh:mm:ss;;D")
  ENDIF
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","E","E"),
   "DD-MMM-YYYY hh:mm:ss;;D")
  SET ms_output_file = build(trim(ms_filename,3),"_",trim(cnvtlower( $S_RANGE),3),"_",trim(cnvtlower(
     format(cnvtdatetime(ms_end_date),"YYYYMMMDD;;q")),3),
   ".csv")
 ELSEIF (cnvtupper(trim( $S_RANGE,3))="MONTHLY")
  IF (mf_current_pool=mf_contactcenternoninvasivescheduling)
   SET ms_start_date = format(cnvtdatetime("01-JAN-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultwingcardiology)
   SET ms_start_date = format(cnvtdatetime("01-OCT-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultcardiologygreenfield)
   SET ms_start_date = format(cnvtdatetime("01-DEC-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultvascularservices)
   SET ms_start_date = format(cnvtdatetime("20-NOV-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultnorthamptoncardiology)
   SET ms_start_date = format(cnvtdatetime("01-DEC-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSEIF (mf_current_pool=mf_consultcardiology3300main)
   SET ms_start_date = format(cnvtdatetime("04-SEP-2024 00:00:00"),"DD-MMM-YYYY hh:mm:ss;;D")
  ELSE
   SET ms_start_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","B","B"),
    "DD-MMM-YYYY hh:mm:ss;;D")
  ENDIF
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","E","E"),
   "DD-MMM-YYYY hh:mm:ss;;D")
  SET ms_output_file = build(trim(ms_filename,3),"_",trim(cnvtlower( $S_RANGE),3),"_",trim(cnvtlower(
     format(cnvtdatetime(ms_end_date),"MMMDDYYYY;;q")),3),
   ".csv")
 ENDIF
 CALL echo(build(ms_start_date,"/",ms_end_date,"/", $S_RANGE))
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
 ELSEIF (datetimediff(cnvtdatetime(ms_end_date),cnvtdatetime(ms_start_date)) > 9300000)
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
 ELSE
  SELECT INTO "nl:"
   FROM task_activity ta,
    task_activity_assignment taa,
    prsnl_group pg,
    prsnl pr,
    prsnl_group pg1,
    person p,
    encntr_alias ea,
    person_alias pa,
    phone email,
    phone ph,
    phone ph1
   PLAN (ta
    WHERE ta.active_ind=1
     AND ta.task_create_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
     AND ta.encntr_id > 0
     AND ta.person_id > 0
     AND operator(ta.task_type_cd,ms_opr_var, $F_TASK_TYPE)
     AND operator(ta.task_status_cd,ms_opr_var1, $F_TASK_STATUS))
    JOIN (p
    WHERE p.person_id=ta.person_id)
    JOIN (pa
    WHERE pa.person_id=ta.person_id
     AND pa.person_alias_type_cd=mf_cmrn_cd
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > sysdate)
    JOIN (ea
    WHERE (ea.encntr_id= Outerjoin(ta.encntr_id))
     AND (ea.active_ind= Outerjoin(1))
     AND (ea.encntr_alias_type_cd= Outerjoin(mf_mrn_cd))
     AND (ea.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
    JOIN (taa
    WHERE taa.task_id=ta.task_id
     AND taa.active_ind=1
     AND (taa.assign_prsnl_group_id= $F_ASSIGN_GRP)
     AND operator(taa.task_status_cd,ms_opr_var1, $F_TASK_STATUS))
    JOIN (pg
    WHERE pg.prsnl_group_id=ta.msg_sender_prsnl_group_id)
    JOIN (pr
    WHERE pr.person_id=ta.msg_sender_id)
    JOIN (pg1
    WHERE pg1.prsnl_group_id=taa.assign_prsnl_group_id)
    JOIN (email
    WHERE (email.parent_entity_id= Outerjoin(p.person_id))
     AND (email.parent_entity_name= Outerjoin("PERSON"))
     AND (email.phone_type_cd= Outerjoin(mf_cs43_externalsecure))
     AND (email.active_ind= Outerjoin(1))
     AND (email.end_effective_dt_tm> Outerjoin(sysdate)) )
    JOIN (ph
    WHERE (ph.parent_entity_id= Outerjoin(p.person_id))
     AND (ph.parent_entity_name= Outerjoin("PERSON"))
     AND (ph.end_effective_dt_tm> Outerjoin(sysdate))
     AND (ph.phone_type_cd= Outerjoin(mf_cs43_mobil_ph))
     AND (ph.active_ind= Outerjoin(1)) )
    JOIN (ph1
    WHERE (ph1.parent_entity_id= Outerjoin(p.person_id))
     AND (ph1.parent_entity_name= Outerjoin("PERSON"))
     AND (ph1.end_effective_dt_tm> Outerjoin(sysdate))
     AND (ph1.phone_type_cd= Outerjoin(mf_cs43_home))
     AND (ph1.active_ind= Outerjoin(1)) )
   ORDER BY taa.assign_prsnl_group_id, p.name_full_formatted, ta.person_id,
    ta.task_id DESC
   HEAD ta.person_id
    pl_cnt += 1
    IF (pl_cnt > size(m_rec->conv,5))
     CALL alterlist(m_rec->conv,(pl_cnt+ 50))
    ENDIF
    m_rec->conv[pl_cnt].f_conversation_id = ta.conversation_id, m_rec->conv[pl_cnt].f_pool_id = taa
    .assign_prsnl_group_id, m_rec->conv[pl_cnt].s_msg_subject1 = trim(ta.msg_subject,3),
    m_rec->conv[pl_cnt].s_taskdate = trim(format(ta.task_create_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec
    ->conv[pl_cnt].s_message_from = trim(pr.name_full_formatted,3), m_rec->conv[pl_cnt].s_message_to
     = trim(pg1.prsnl_group_name,3),
    m_rec->conv[pl_cnt].s_cmrn = trim(pa.alias,3), m_rec->conv[pl_cnt].s_dob = format(cnvtdatetimeutc
     (datetimezone(p.birth_dt_tm,p.birth_tz),1),"mm/dd/yyyy;;d"), m_rec->conv[pl_cnt].s_mrn = trim(ea
     .alias,3),
    m_rec->conv[pl_cnt].f_msg_text_id = ta.msg_text_id, m_rec->conv[pl_cnt].s_pat_first_name = trim(p
     .name_first,3), m_rec->conv[pl_cnt].s_pat_last_name = trim(p.name_last,3),
    m_rec->conv[pl_cnt].s_task_type = trim(uar_get_code_display(ta.task_type_cd),3), m_rec->conv[
    pl_cnt].s_task_status = trim(uar_get_code_display(ta.task_status_cd),3), m_rec->conv[pl_cnt].
    f_taskid = ta.task_id,
    m_rec->conv[pl_cnt].s_email = trim(email.phone_num,3)
    IF (( $S_REMOVE_CHARS=1))
     m_rec->conv[pl_cnt].s_mobile_num = trim(cnvtalphanum(ph.phone_num_key,1),3), m_rec->conv[pl_cnt]
     .s_home_phone = trim(cnvtalphanum(ph1.phone_num_key,1),3)
    ELSE
     m_rec->conv[pl_cnt].s_mobile_num = trim(ph.phone_num,3), m_rec->conv[pl_cnt].s_home_phone = trim
     (ph1.phone_num,3)
    ENDIF
    m_rec->conv[pl_cnt].s_language = trim(uar_get_code_display(p.language_cd),3)
   FOOT REPORT
    CALL alterlist(m_rec->conv,pl_cnt)
   WITH nocounter
  ;end select
  IF (size(m_rec->conv,5) > 0)
   IF (( $F_FILE=0))
    SELECT INTO  $OUTDEV
     task_create_date = substring(1,30,m_rec->conv[d1.seq].s_taskdate), task_type = substring(1,30,
      m_rec->conv[d1.seq].s_task_type), task_status = substring(1,30,m_rec->conv[d1.seq].
      s_task_status),
     message_subject_from = substring(1,200,m_rec->conv[d1.seq].s_msg_subject1), message_to_pool =
     substring(1,200,m_rec->conv[d1.seq].s_message_to), patient_first_name = substring(1,30,m_rec->
      conv[d1.seq].s_pat_first_name),
     patient_last_name = substring(1,30,m_rec->conv[d1.seq].s_pat_last_name), cmrn = substring(1,30,
      m_rec->conv[d1.seq].s_cmrn), mrn = substring(1,30,m_rec->conv[d1.seq].s_mrn),
     dob = substring(1,30,m_rec->conv[d1.seq].s_dob), email = substring(1,100,m_rec->conv[d1.seq].
      s_email), mobile_num = substring(1,50,m_rec->conv[d1.seq].s_mobile_num),
     home_phone = substring(1,50,m_rec->conv[d1.seq].s_home_phone), language = substring(1,50,m_rec->
      conv[d1.seq].s_language)
     FROM (dummyt d1  WITH seq = size(m_rec->conv,5))
     PLAN (d1)
     WITH nocounter, separator = " ", format
    ;end select
   ELSEIF (( $F_FILE=1)
    AND findstring("@", $S_EMAILS))
    SET frec->file_name = ms_output_file
    SET frec->file_buf = "w"
    SET stat = cclio("OPEN",frec)
    SET frec->file_buf = build('"Pool id",','"Create Date",','"Patient First Name",',
     '"Patient Last Name",','"CMRN",',
     '"Mobile Number",','"Home Phone",','"Language",',char(13))
    SET stat = cclio("WRITE",frec)
    FOR (ml1_cnt = 1 TO size(m_rec->conv,5))
     SET frec->file_buf = build('"',format(m_rec->conv[ml1_cnt].f_pool_id,"############"),'","',trim(
       m_rec->conv[ml1_cnt].s_taskdate,3),'","',
      trim(m_rec->conv[ml1_cnt].s_pat_first_name,3),'","',trim(m_rec->conv[ml1_cnt].s_pat_last_name,3
       ),'","',trim(m_rec->conv[ml1_cnt].s_cmrn,3),
      '","',trim(m_rec->conv[ml1_cnt].s_mobile_num,3),'","',trim(m_rec->conv[ml1_cnt].s_home_phone,3),
      '","',
      trim(m_rec->conv[ml1_cnt].s_language,3),'"',char(13))
     SET stat = cclio("WRITE",frec)
    ENDFOR
    SET stat = cclio("CLOSE",frec)
    IF (findstring("@", $S_EMAILS) > 1
     AND textlen(trim(ms_error,3))=0)
     EXECUTE bhs_ma_email_file
     SET ms_subject = build2(ms_pool_name," Pool Patient Audit ",trim(format(cnvtdatetime(
         ms_start_date),"mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),
        "mmm-dd-yyyy hh:mm;;d"),3))
     CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
     SELECT INTO  $OUTDEV
      FROM dummyt d
      HEAD REPORT
       msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
       CALL print(calcpos(36,18)),
       msg1, row + 2, msg2
      WITH dio = 08
     ;end select
    ELSE
     SELECT INTO  $OUTDEV
      FROM dummyt d
      HEAD REPORT
       msg1 = concat("File: ",build2(ms_output_file)),
       CALL print(calcpos(36,18)), msg1
      WITH dio = 08
     ;end select
    ENDIF
   ENDIF
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     msg1 = "No Data Qualified",
     CALL print(calcpos(36,18)), msg1
    WITH dio = 08
   ;end select
  ENDIF
 ENDIF
#exit_script
 FREE RECORD m_rec
END GO
