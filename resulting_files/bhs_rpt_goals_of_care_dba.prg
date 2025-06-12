CREATE PROGRAM bhs_rpt_goals_of_care:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = value(999999),
  "Nurse Unit" = value(999999),
  "Start Date Time" = "SYSDATE",
  "End Date Time" = "SYSDATE",
  "Email Recipients  (leave blank to display to screen)" = ""
  WITH outdev, f_facility_cd, f_nurse_unit_cd,
  s_start_dt_tm, s_end_dt_tm, s_recipients
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
   1 l_qual_cnt = i4
   1 qual[*]
     2 s_facility = vc
     2 s_nurse_unit = vc
     2 s_room_bed = vc
     2 s_patient_name = vc
     2 s_dob = vc
     2 s_fin = vc
     2 s_signing_provider = vc
     2 s_signed_dt_tm = vc
 ) WITH protect
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_gocad_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GOALSOFCAREADVANCEDDIRECTIVE"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_START_DT_TM))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DT_TM))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit_p = vc WITH protect, noconstant("")
 DECLARE ms_error = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(((curdate - day(curdate))+ 1),000000))
  SET mf_end_dt_tm = cnvtdatetime((curdate - day(curdate)),235959)
  SET ms_subject = build2("Goals Of Care Advanced Directive Monthly Report ",trim(format(
     mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")
    ))
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_GOALS_OF_CARE"
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
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1)
  SET ms_subject = build2("Goals Of Care Advanced Directive Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
 ENDIF
 IF (cnvtdatetime(mf_begin_dt_tm) > cnvtdatetime(mf_end_dt_tm))
  SET ms_error = "Start date must be before the end date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 93)
  SET ms_error = "Date range exceeds 3 months."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 SET ms_item_list = reflect(parameter(2,0))
 IF (( $F_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (ml_loop = 1 TO ml_cnt)
    IF (ml_loop=1)
     SET ms_facility_p = build2("e.loc_facility_cd in (",parameter(2,ml_loop))
    ELSE
     SET ms_facility_p = build2(ms_facility_p,",",parameter(2,ml_loop))
    ENDIF
  ENDFOR
  SET ms_facility_p = concat(ms_facility_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_facility_p = build2("e.loc_facility_cd = ",parameter(2,0))
 ENDIF
 SET ms_item_list = reflect(parameter(3,0))
 IF (( $F_NURSE_UNIT_CD=999999))
  SET ms_nurse_unit_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ms_nurse_unit_p = "e.loc_nurse_unit_cd in ("
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (ml_loop = 1 TO ml_cnt)
    SET ms_nurse_unit_p = concat(ms_nurse_unit_p,cnvtstring(parameter(3,ml_loop)),",")
  ENDFOR
  SET ms_nurse_unit_p = concat(substring(1,(textlen(ms_nurse_unit_p) - 1),ms_nurse_unit_p),")")
 ELSE
  SET ms_nurse_unit_p = concat("e.loc_nurse_unit_cd = ",cnvtstring( $F_NURSE_UNIT_CD))
 ENDIF
 SELECT INTO "nl:"
  facility = uar_get_code_display(e.loc_facility_cd), nurse_unit = uar_get_code_display(e
   .loc_nurse_unit_cd), room_bed = build2(trim(uar_get_code_display(e.loc_room_cd),3),"/",trim(
    uar_get_code_display(e.loc_bed_cd),3))
  FROM clinical_event ce,
   encounter e,
   person p,
   prsnl pr,
   encntr_alias ea
  PLAN (ce
   WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.event_cd=mf_gocad_cd
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND ce.publish_flag=1)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND parser(ms_facility_p)
    AND parser(ms_nurse_unit_p)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.active_status_cd=mf_active_cd
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
  ORDER BY facility, nurse_unit, room_bed,
   p.name_full_formatted, ce.performed_dt_tm DESC
  HEAD REPORT
   ml_cnt = 0
  HEAD ce.parent_event_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].s_facility = uar_get_code_display(e.loc_facility_cd), m_rec->qual[ml_cnt].
   s_nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd), m_rec->qual[ml_cnt].s_room_bed = build2(
    trim(uar_get_code_display(e.loc_room_cd),3),"/",trim(uar_get_code_display(e.loc_bed_cd),3)),
   m_rec->qual[ml_cnt].s_patient_name = p.name_full_formatted, m_rec->qual[ml_cnt].s_dob = format(
    cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"mm/dd/yyyy;;d"), m_rec->qual[ml_cnt].
   s_signing_provider = pr.name_full_formatted,
   m_rec->qual[ml_cnt].s_signed_dt_tm = format(ce.performed_dt_tm,"mm/dd/yy HH:mm:ss;;d"), m_rec->
   qual[ml_cnt].s_fin = ea.alias
  FOOT REPORT
   m_rec->l_qual_cnt = ml_cnt,
   CALL alterlist(m_rec->qual,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (textlen(trim(ms_recipients,3)) > 1)
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(sysdate,"mm_dd_yy;;d"),3),".csv")
  SET ms_subject = build2("Goals Of Care Advanced Directive Report ",trim(format(sysdate,
     "mmm-dd-yyyy hh:mm ;;d"),3))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"DATE OF BIRTH",','"FACILITY",','"NURSE UNIT",',
   '"ROOM/BED",',
   '"ACCOUNT#",','"SIGNED DATE TIME",','"SIGNING PROVIDER",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_qual_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_patient_name,3),'","',trim(m_rec->qual[
     ml_cnt].s_dob,3),'","',
    trim(m_rec->qual[ml_cnt].s_facility,3),'","',trim(m_rec->qual[ml_cnt].s_nurse_unit,3),'","',trim(
     m_rec->qual[ml_cnt].s_room_bed,3),
    '","',trim(m_rec->qual[ml_cnt].s_fin,3),'","',trim(m_rec->qual[ml_cnt].s_signed_dt_tm,3),'","',
    trim(m_rec->qual[ml_cnt].s_signing_provider,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,100,m_rec->qual[d.seq].s_patient_name), date_of_birth = substring(1,50,
    m_rec->qual[d.seq].s_dob), facility = substring(1,50,m_rec->qual[d.seq].s_facility),
   nurse_unit = substring(1,50,m_rec->qual[d.seq].s_nurse_unit), room_bed = substring(1,50,m_rec->
    qual[d.seq].s_room_bed), acc# = substring(1,50,m_rec->qual[d.seq].s_fin),
   signed_dt_tm = substring(1,50,m_rec->qual[d.seq].s_signed_dt_tm), signing_provider = substring(1,
    100,m_rec->qual[d.seq].s_signing_provider)
   FROM (dummyt d  WITH seq = m_rec->l_qual_cnt)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 CALL echorecord(frec)
 FREE RECORD m_rec
 FREE RECORD frec
 IF (textlen(trim( $S_RECIPIENTS,3)) > 1
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
