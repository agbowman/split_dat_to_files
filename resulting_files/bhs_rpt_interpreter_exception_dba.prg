CREATE PROGRAM bhs_rpt_interpreter_exception:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Ops Frequency (Hidden from user)" = "MANUAL",
  "Facility" = value(999999),
  "Nurse Unit" = value(999999),
  "Form Result Status" = value(auth(verified),modified),
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients" = ""
  WITH outdev, s_ops_freq, f_facility_cd,
  f_nurse_unit_cd, f_result_status_cd, s_begin_date,
  s_end_date, s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 s_interpreter_name = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_result_status = vc
     2 s_performed_dt_tm = vc
     2 f_inter_duration = f8
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_inter_serv_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERPRETERSERVICEENCOUNTERFORM"))
 DECLARE mf_dcp_generic_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DCPGENERICCODE"))
 DECLARE mf_inter_start_dt_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERPRETATIONSTARTDATETIME"))
 DECLARE mf_inter_end_dt_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERPRETATATIONENDDATETIME"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit_p = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  IF (( $S_OPS_FREQ="DAILY"))
   SET mf_begin_dt_tm = cnvtdatetime((curdate - 1),000000)
   SET mf_end_dt_tm = cnvtdatetime((curdate - 1),235959)
   SET ms_subject = build2("Interpreter Exception Daily Report ",trim(format(mf_begin_dt_tm,
      "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  ELSEIF (( $S_OPS_FREQ="MONTHLY"))
   SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(((curdate - day(curdate))+ 1),000000))
   SET mf_end_dt_tm = cnvtdatetime((curdate - day(curdate)),235959)
   SET ms_subject = build2("Interpreter Exception Monthly Report ",trim(format(mf_begin_dt_tm,
      "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_INTERPRETER_EXCEPTION"
    AND di.info_char="EMAIL"
   ORDER BY di.info_name
   DETAIL
    IF (textlen(trim(ms_recipients,3)) < 1)
     ms_recipients = trim(di.info_name,3)
    ELSE
     ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cnvtdatetime(mf_begin_dt_tm) > cnvtdatetime(mf_end_dt_tm))
  SET ms_error = "Start date must be less than end date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 93)
  SET ms_error = "Date range exceeds 3 months."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 SET ms_item_list = reflect(parameter(3,0))
 IF (( $F_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (i = 1 TO ml_cnt)
    IF (i=1)
     SET ms_facility_p = build2("e.loc_facility_cd in (",parameter(3,i))
    ELSE
     SET ms_facility_p = build2(ms_facility_p,",",parameter(3,i))
    ENDIF
  ENDFOR
  SET ms_facility_p = concat(ms_facility_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_facility_p = build2("e.loc_facility_cd = ",parameter(3,0))
 ENDIF
 SET ms_item_list = reflect(parameter(4,0))
 IF (( $F_NURSE_UNIT_CD=999999))
  SET ms_nurse_unit_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (i = 1 TO ml_cnt)
    IF (i=1)
     SET ms_nurse_unit_p = build2("e.loc_nurse_unit_cd in (",parameter(4,i))
    ELSE
     SET ms_nurse_unit_p = build2(ms_nurse_unit_p,",",parameter(4,i))
    ENDIF
  ENDFOR
  SET ms_nurse_unit_p = concat(ms_nurse_unit_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_nurse_unit_p = build2("e.loc_nurse_unit_cd = ",parameter(4,0))
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce1,
   encounter e,
   clinical_event ce2,
   clinical_event ce3,
   clinical_event ce4,
   prsnl pr,
   ce_date_result cedr1,
   ce_date_result cedr2,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (ce1
   WHERE ce1.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce1.event_cd=mf_inter_serv_form_cd
    AND (ce1.result_status_cd= $F_RESULT_STATUS_CD)
    AND ce1.view_level=1
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce1.publish_flag=1)
   JOIN (e
   WHERE e.encntr_id=ce1.encntr_id
    AND parser(ms_facility_p)
    AND parser(ms_nurse_unit_p)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.event_cd=mf_dcp_generic_cd
    AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ce3
   WHERE ce3.parent_event_id=ce2.event_id
    AND ce3.event_cd=mf_inter_start_dt_tm_cd
    AND ce3.view_level=1
    AND ce3.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce3.publish_flag=1
    AND ce3.event_tag != "In Error")
   JOIN (ce4
   WHERE (ce4.parent_event_id= Outerjoin(ce2.event_id))
    AND (ce4.event_cd= Outerjoin(mf_inter_end_dt_tm_cd))
    AND (ce4.view_level= Outerjoin(1))
    AND (ce4.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
    AND (ce4.publish_flag= Outerjoin(1))
    AND (ce4.event_tag!= Outerjoin("In Error")) )
   JOIN (pr
   WHERE pr.person_id=ce1.performed_prsnl_id)
   JOIN (cedr1
   WHERE cedr1.event_id=ce3.event_id)
   JOIN (cedr2
   WHERE (cedr2.event_id= Outerjoin(ce4.event_id)) )
   JOIN (ea1
   WHERE ea1.encntr_id=ce1.encntr_id
    AND ea1.encntr_alias_type_cd=mf_mrn_cd
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ea2
   WHERE ea2.encntr_id=ce1.encntr_id
    AND ea2.encntr_alias_type_cd=mf_fin_cd
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY pr.name_last_key, pr.name_first_key, pr.person_id,
   ce1.performed_dt_tm
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   IF ((( NOT (datetimediff(cedr2.result_dt_tm,cedr1.result_dt_tm,4) BETWEEN 0 AND 120)) OR (((ce1
   .result_status_cd=mf_inprogress_cd) OR (ce4.result_val=null)) )) )
    ml_cnt += 1
    IF (ml_cnt > size(m_rec->qual,5))
     CALL alterlist(m_rec->qual,(ml_cnt+ 99))
    ENDIF
    m_rec->qual[ml_cnt].s_interpreter_name = pr.name_full_formatted, m_rec->qual[ml_cnt].
    s_performed_dt_tm = format(ce1.performed_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"), m_rec->qual[ml_cnt].
    s_result_status = uar_get_code_display(ce1.result_status_cd),
    m_rec->qual[ml_cnt].s_mrn = ea1.alias, m_rec->qual[ml_cnt].s_fin = ea2.alias, m_rec->qual[ml_cnt]
    .f_inter_duration = datetimediff(cedr2.result_dt_tm,cedr1.result_dt_tm,4)
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_cnt = ml_cnt
  WITH nocounter
 ;end select
 IF (size(m_rec->qual,5)=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yy_hh_mm ;;d"),
    3),"_to_",trim(format(mf_end_dt_tm,"mm_dd_yy_hh_mm;;d"),3),
   ".csv")
  IF (mn_ops=0)
   SET ms_subject = build2("Interpreter Exception Report ",trim(format(mf_begin_dt_tm,
      "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  ENDIF
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"INTERPRETER NAME",','"FIN",','"MRN",','"PERFORMED DATE TIME",',
   '"INTERPRETATION DURATION (MINS)",',
   '"RESULT STATUS",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_interpreter_name,3),'","',trim(m_rec->
     qual[ml_cnt].s_fin,3),'","',
    trim(m_rec->qual[ml_cnt].s_mrn,3),'","',trim(m_rec->qual[ml_cnt].s_performed_dt_tm,3),'","',trim(
     format(m_rec->qual[ml_cnt].f_inter_duration,"#######.##;R"),3),
    '","',trim(m_rec->qual[ml_cnt].s_result_status,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   interpreter_name = substring(1,50,m_rec->qual[d.seq].s_interpreter_name), fin = substring(1,50,
    m_rec->qual[d.seq].s_fin), mrn = substring(1,50,m_rec->qual[d.seq].s_mrn),
   performed_dt_tm = substring(1,50,m_rec->qual[d.seq].s_performed_dt_tm), inter_duration_mins =
   m_rec->qual[d.seq].f_inter_duration, result_status = substring(1,50,m_rec->qual[d.seq].
    s_result_status)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
 FREE RECORD frec
 IF (((mn_ops=1) OR (textlen(trim( $OUTDEV,3))=0)) )
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
 ENDIF
END GO
