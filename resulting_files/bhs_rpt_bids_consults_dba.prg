CREATE PROGRAM bhs_rpt_bids_consults:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients" = ""
  WITH outdev, s_begin_date, s_end_date,
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
   1 l_cnt = i4
   1 qual[*]
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_sex = vc
     2 s_dob = vc
     2 s_location = vc
     2 s_bids_cons = vc
     2 s_order_dt_tm = vc
     2 s_ord_provider = vc
     2 s_position = vc
 ) WITH protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_bids_consult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTBMCINPATIENTDIABETESBIDS"))
 DECLARE mf_active_stat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_bmc_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
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
  SET ms_subject = build2("BIDS Consults Report ",trim(format(mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d")
    )," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1)
  SET ms_subject = build2("BIDS Consults Report ",trim(format(mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d")
    )," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
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
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   person p,
   order_action oa,
   prsnl pr,
   encntr_alias ea
  PLAN (o
   WHERE o.catalog_cd=mf_bids_consult_cd
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND o.active_ind=1
    AND o.active_status_cd=mf_active_stat_cd)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.loc_facility_cd=mf_bmc_cd
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.birth_dt_tm <= cnvtlookbehind("18, Y",sysdate))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_order_cd)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=mf_mrn_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY p.name_full_formatted, p.person_id, e.encntr_id,
   o.orig_order_dt_tm
  HEAD REPORT
   ml_cnt = 0
  HEAD o.order_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].s_pat_name = p.name_full_formatted, m_rec->qual[ml_cnt].s_sex =
   uar_get_code_display(p.sex_cd), m_rec->qual[ml_cnt].s_dob = format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
   m_rec->qual[ml_cnt].s_mrn = ea.alias, m_rec->qual[ml_cnt].s_bids_cons = o.order_mnemonic, m_rec->
   qual[ml_cnt].s_order_dt_tm = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d"),
   m_rec->qual[ml_cnt].s_ord_provider = pr.name_full_formatted, m_rec->qual[ml_cnt].s_position =
   uar_get_code_display(pr.position_cd), m_rec->qual[ml_cnt].s_location = trim(uar_get_code_display(e
     .loc_nurse_unit_cd),3)
  FOOT REPORT
   m_rec->l_cnt = ml_cnt,
   CALL alterlist(m_rec->qual,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
   "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy;;d"),3),
   ".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"SEX",','"DATE OF BIRTH",','"MRN#",','"LOCATION",',
   '"BIDS CONSULT",','"ORDER DATE/TIME",','"ORDERING PROVIDER",','"POSITION",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_pat_name,3),'","',trim(m_rec->qual[
     ml_cnt].s_sex,3),'","',
    trim(m_rec->qual[ml_cnt].s_dob,3),'","',trim(m_rec->qual[ml_cnt].s_mrn,3),'","',trim(m_rec->qual[
     ml_cnt].s_location,3),
    '","',trim(m_rec->qual[ml_cnt].s_bids_cons,3),'","',trim(m_rec->qual[ml_cnt].s_order_dt_tm,3),
    '","',
    trim(m_rec->qual[ml_cnt].s_ord_provider,3),'","',trim(m_rec->qual[ml_cnt].s_position,3),'"',char(
     13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,100,m_rec->qual[d.seq].s_pat_name), sex = substring(1,100,m_rec->qual[d
    .seq].s_sex), date_of_birth = substring(1,100,m_rec->qual[d.seq].s_dob),
   mrn# = substring(1,100,m_rec->qual[d.seq].s_mrn), location = substring(1,100,m_rec->qual[d.seq].
    s_location), bids_consult = substring(1,100,m_rec->qual[d.seq].s_bids_cons),
   order_dt_tm = substring(1,100,m_rec->qual[d.seq].s_order_dt_tm), ordering_provider = substring(1,
    100,m_rec->qual[d.seq].s_ord_provider), position = substring(1,100,m_rec->qual[d.seq].s_position)
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
