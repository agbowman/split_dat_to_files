CREATE PROGRAM bhs_rpt_spiritual_pref:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 673936.00,
  "Religious/Spiritual Preference" = "",
  "Spiritual Resource" = "",
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients  (Leave blank to output to screen)" = ""
  WITH outdev, f_facility_cd, s_spirit_pref,
  s_spirit_resource, s_begin_date, s_end_date,
  s_recipients
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
   1 list[*]
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_spirit_pref = vc
     2 s_spirit_resource = vc
     2 s_location = vc
     2 s_pat_dob = vc
     2 s_start_dt_tm = vc
     2 s_end_dt_tm = vc
   1 qual[*]
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_spirit_pref = vc
     2 s_spirit_resource = vc
     2 s_location = vc
     2 s_pat_dob = vc
     2 s_start_dt_tm = vc
     2 s_end_dt_tm = vc
 ) WITH protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_dcp_generic_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DCPGENERICCODE"))
 DECLARE mf_spirit_consult_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SPIRITUALSERVICECONSULTFORM"))
 DECLARE mf_spirit_pref_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELIGIOUSSPIRITUALPREFERENCE"))
 DECLARE mf_spirit_resource_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",72,
   "Spiritual/Sacramental Resources"))
 DECLARE mf_spirit_start_time_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "STARTTIMESPIRITUALSERVICE"))
 DECLARE mf_spirit_end_time_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ENDTIMESPIRITUALSERVICE"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_dischdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHDAYSTAY"))
 DECLARE mf_disches_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES"))
 DECLARE mf_dischip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_dischobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE mf_expireddaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "EXPIREDDAYSTAY"))
 DECLARE mf_expiredes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES"))
 DECLARE mf_expiredip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"))
 DECLARE mf_expiredobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(((curdate - day(curdate))+ 1),000000))
  SET mf_end_dt_tm = cnvtdatetime((curdate - day(curdate)),235959)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_SPIRITUAL_PREF"
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
  AND textlen(trim(ms_recipients,3)) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce1,
   clinical_event ce2,
   clinical_event ce3,
   encounter e,
   encntr_alias ea,
   person p,
   ce_date_result cedr
  PLAN (ce1
   WHERE ce1.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce1.event_cd=mf_spirit_consult_form_cd
    AND ce1.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce1.view_level=1
    AND ce1.publish_flag=1)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.event_cd=mf_dcp_generic_cd)
   JOIN (ce3
   WHERE ce3.parent_event_id=ce2.event_id
    AND ce3.event_cd IN (mf_spirit_pref_cd, mf_spirit_resource_cd, mf_spirit_start_time_cd,
   mf_spirit_end_time_cd)
    AND ce3.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce3.view_level=1
    AND ce3.publish_flag=1)
   JOIN (e
   WHERE e.encntr_id=ce1.encntr_id
    AND (e.loc_facility_cd= $F_FACILITY_CD)
    AND e.encntr_type_cd IN (mf_inpatient_cd, mf_observation_cd, mf_daystay_cd, mf_emergency_cd,
   mf_dischdaystay_cd,
   mf_disches_cd, mf_dischip_cd, mf_dischobv_cd, mf_expireddaystay_cd, mf_expiredes_cd,
   mf_expiredip_cd, mf_expiredobv_cd)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_mrn_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (cedr
   WHERE (cedr.event_id= Outerjoin(ce3.event_id)) )
  ORDER BY p.name_full_formatted, p.person_id, e.encntr_id,
   ce1.event_id, ce3.performed_dt_tm
  HEAD REPORT
   ml_cnt = 0
  HEAD ce1.event_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->list,5))
    CALL alterlist(m_rec->list,(ml_cnt+ 99))
   ENDIF
   m_rec->list[ml_cnt].s_pat_dob = format(p.birth_dt_tm,"mm/dd/yyyy ;;d"), m_rec->list[ml_cnt].
   s_location = build2(trim(uar_get_code_display(e.loc_facility_cd),3),"/",trim(uar_get_code_display(
      e.loc_nurse_unit_cd),3),"/",trim(uar_get_code_display(e.loc_room_cd),3)), m_rec->list[ml_cnt].
   s_pat_name = p.name_full_formatted,
   m_rec->list[ml_cnt].s_mrn = ea.alias
  HEAD ce3.event_id
   CASE (ce3.event_cd)
    OF mf_spirit_pref_cd:
     m_rec->list[ml_cnt].s_spirit_pref = ce3.result_val
    OF mf_spirit_resource_cd:
     m_rec->list[ml_cnt].s_spirit_resource = ce3.result_val
    OF mf_spirit_start_time_cd:
     m_rec->list[ml_cnt].s_start_dt_tm = format(cedr.result_dt_tm,"mm/dd/yyyy hh:mm;;d")
    OF mf_spirit_end_time_cd:
     m_rec->list[ml_cnt].s_end_dt_tm = format(cedr.result_dt_tm,"mm/dd/yyyy hh:mm;;d")
   ENDCASE
  FOOT REPORT
   CALL alterlist(m_rec->list,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0
  AND mn_ops=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(m_rec->list,5))
  PLAN (d
   WHERE (m_rec->list[d.seq].s_spirit_pref= $S_SPIRIT_PREF)
    AND (m_rec->list[d.seq].s_spirit_resource=concat("*",trim( $S_SPIRIT_RESOURCE,3),"*")))
  HEAD REPORT
   ml_cnt = 0
  HEAD d.seq
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].s_pat_name = m_rec->list[d.seq].s_pat_name, m_rec->qual[ml_cnt].s_pat_dob =
   m_rec->list[d.seq].s_pat_dob, m_rec->qual[ml_cnt].s_mrn = m_rec->list[d.seq].s_mrn,
   m_rec->qual[ml_cnt].s_location = m_rec->list[d.seq].s_location, m_rec->qual[ml_cnt].s_start_dt_tm
    = m_rec->list[d.seq].s_start_dt_tm, m_rec->qual[ml_cnt].s_end_dt_tm = m_rec->list[d.seq].
   s_end_dt_tm,
   m_rec->qual[ml_cnt].s_spirit_pref = m_rec->list[d.seq].s_spirit_pref, m_rec->qual[ml_cnt].
   s_spirit_resource = m_rec->list[d.seq].s_spirit_resource
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0
  AND mn_ops=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (((textlen( $S_RECIPIENTS) > 1) OR (mn_ops=1)) )
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
   "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy;;d"),3),
   ".csv")
  SET ms_subject = build2("Spiritual Preference Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm ;;d"),3))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"DOB",','"MRN #",','"LOCATION",',
   '"SPIRITUAL PREFERENCE",',
   '"SPIRITUAL RESOURCE",','"START TIME",','"END TIME",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO size(m_rec->qual,5))
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_pat_name,3),'","',trim(m_rec->qual[
     ml_cnt].s_pat_dob,3),'","',
    trim(m_rec->qual[ml_cnt].s_mrn,3),'","',trim(m_rec->qual[ml_cnt].s_location,3),'","',trim(m_rec->
     qual[ml_cnt].s_spirit_pref,3),
    '","',trim(m_rec->qual[ml_cnt].s_spirit_resource,3),'","',trim(m_rec->qual[ml_cnt].s_start_dt_tm,
     3),'","',
    trim(m_rec->qual[ml_cnt].s_end_dt_tm,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(value(frec->file_name),frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,100,m_rec->qual[d.seq].s_pat_name), dob = substring(1,100,m_rec->qual[d
    .seq].s_pat_dob), mrn# = substring(1,100,m_rec->qual[d.seq].s_mrn),
   location = substring(1,100,m_rec->qual[d.seq].s_location), spiritual_preference = substring(1,100,
    m_rec->qual[d.seq].s_spirit_pref), spiritual_resource = substring(1,100,m_rec->qual[d.seq].
    s_spirit_resource),
   start_time = substring(1,100,m_rec->qual[d.seq].s_start_dt_tm), end_time = substring(1,100,m_rec->
    qual[d.seq].s_end_dt_tm)
   FROM (dummyt d  WITH seq = size(m_rec->qual,5))
   PLAN (d)
   ORDER BY patient_name
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen( $S_RECIPIENTS) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) != 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = ms_error, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
