CREATE PROGRAM bhs_rpt_id_disch:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = value(999999),
  "Nurse Unit" = value(999999),
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Email Recipients  (leave blank to display to screen)" = ""
  WITH outdev, f_facility_cd, f_nurse_unit_cd,
  s_start_dt, s_end_dt, s_recipients
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
     2 f_encntr_id = f8
     2 s_facility = vc
     2 s_nurse_unit = vc
     2 s_patient_name = vc
     2 s_dob = vc
     2 s_mrn = vc
     2 s_attending = vc
     2 s_consult_phys = vc
     2 s_order = vc
     2 s_encntr_class = vc
     2 s_admit_dt = vc
     2 s_disch_dt = vc
     2 s_follow_up = vc
 ) WITH protect
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION")
  )
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"DAYSTAY"))
 DECLARE mf_consult_id_adult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTINFECTIOUSDISEASEADULT"))
 DECLARE mf_isolation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ISOLATION"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_attending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN"))
 DECLARE mf_consult_phys_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "CONSULTINGPHYSICIAN"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "DISCONTINUED"))
 DECLARE mf_follow_up_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100400,
   "CONSULTFOLLOWUPUNTILPROBLEMRESOLVED"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_expand = i4 WITH protect, noconstant(0)
 DECLARE mf_start_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_START_DT))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DT))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit_p = vc WITH protect, noconstant("")
 DECLARE ms_error = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_start_dt_tm = cnvtdatetime((curdate - 7),000000)
  SET mf_end_dt_tm = cnvtdatetime(curdate,000000)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_ID_DISCH"
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
 IF (mf_start_dt_tm > mf_end_dt_tm)
  SET ms_error = "Start Date must be before the End Date."
  GO TO exit_script
 ELSEIF (datetimediff(mf_end_dt_tm,mf_start_dt_tm) > 365)
  SET ms_error = "Date range exceeds 365 days"
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid"
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
  FROM encounter e,
   orders o,
   person p,
   encntr_alias ea,
   order_detail od
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND parser(ms_facility_p)
    AND parser(ms_nurse_unit_p)
    AND e.encntr_type_class_cd IN (mf_inpatient_cd, mf_observation_cd, mf_daystay_cd)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.catalog_cd IN (mf_consult_id_adult_cd, mf_isolation_cd)
    AND o.order_status_cd IN (mf_ordered_cd, mf_completed_cd, mf_discontinued_cd)
    AND o.active_ind=1
    AND o.active_status_cd=mf_active_cd)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_mrn_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (od
   WHERE (od.order_id= Outerjoin(o.order_id))
    AND (od.oe_field_value= Outerjoin(mf_follow_up_cd)) )
  ORDER BY e.disch_dt_tm
  HEAD REPORT
   ml_cnt = 0
  HEAD e.encntr_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].f_encntr_id = e.encntr_id, m_rec->qual[ml_cnt].s_patient_name = p
   .name_full_formatted, m_rec->qual[ml_cnt].s_dob = format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
   m_rec->qual[ml_cnt].s_mrn = ea.alias, m_rec->qual[ml_cnt].s_facility = uar_get_code_display(e
    .loc_facility_cd), m_rec->qual[ml_cnt].s_nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd),
   m_rec->qual[ml_cnt].s_admit_dt = format(e.reg_dt_tm,"mm/dd/yy;;d"), m_rec->qual[ml_cnt].s_disch_dt
    = format(e.disch_dt_tm,"mm/dd/yy;;d"), m_rec->qual[ml_cnt].s_order = o.order_mnemonic,
   m_rec->qual[ml_cnt].s_encntr_class = uar_get_code_display(e.encntr_type_class_cd), m_rec->qual[
   ml_cnt].s_follow_up = od.oe_field_display_value
  FOOT REPORT
   m_rec->l_qual_cnt = ml_cnt,
   CALL alterlist(m_rec->qual,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = m_rec->l_qual_cnt),
   encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=m_rec->qual[d.seq].f_encntr_id)
    AND epr.encntr_prsnl_r_cd IN (mf_attending_cd, mf_consult_phys_cd)
    AND epr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
    AND epr.active_ind=1
    AND epr.active_status_cd=mf_active_cd)
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id
    AND pr.active_ind=1)
  ORDER BY epr.encntr_id, epr.beg_effective_dt_tm
  DETAIL
   IF (epr.encntr_prsnl_r_cd=mf_attending_cd)
    m_rec->qual[d.seq].s_attending = pr.name_full_formatted
   ELSEIF (epr.encntr_prsnl_r_cd=mf_consult_phys_cd)
    m_rec->qual[d.seq].s_consult_phys = pr.name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 IF (textlen(ms_recipients) > 1)
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(cnvtdatetime(mf_start_dt_tm),
     "mm_dd_yy;;d"),3),"_to_",trim(format(cnvtdatetime(mf_end_dt_tm),"mm_dd_yy;;d"),3),
   ".csv")
  SET ms_subject = build2("Infectious Disease Discharge Report ",trim(format(sysdate,"mmm-dd-yy;;d"),
    3))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"DATE OF BIRTH",','"FACILITY",','"NURSE UNIT",',
   '"ADMIT DATE",',
   '"DISCHARGE DATE",','"MRN#",','"ORDER MNEMONIC",','"ATTENDING PHYSICIAN",',
   '"CONSULTING PHYSICIAN",',
   '"FOLLOW UP",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_qual_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_patient_name,3),'","',trim(m_rec->qual[
     ml_cnt].s_dob,3),'","',
    trim(m_rec->qual[ml_cnt].s_facility,3),'","',trim(m_rec->qual[ml_cnt].s_nurse_unit,3),'","',trim(
     m_rec->qual[ml_cnt].s_admit_dt,3),
    '","',trim(m_rec->qual[ml_cnt].s_disch_dt,3),'","',trim(m_rec->qual[ml_cnt].s_mrn,3),'","',
    trim(m_rec->qual[ml_cnt].s_order,3),'","',trim(m_rec->qual[ml_cnt].s_attending,3),'","',trim(
     m_rec->qual[ml_cnt].s_consult_phys,3),
    '","',trim(m_rec->qual[ml_cnt].s_follow_up,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,50,m_rec->qual[d.seq].s_patient_name), dob = substring(1,50,m_rec->
    qual[d.seq].s_dob), facility = substring(1,50,m_rec->qual[d.seq].s_facility),
   nurse_unit = substring(1,50,m_rec->qual[d.seq].s_nurse_unit), admit_dt = substring(1,50,m_rec->
    qual[d.seq].s_admit_dt), discharge_dt = substring(1,50,m_rec->qual[d.seq].s_disch_dt),
   mrn = substring(1,50,m_rec->qual[d.seq].s_mrn), order_mnemonic = substring(1,50,m_rec->qual[d.seq]
    .s_order), attending_physician = substring(1,100,m_rec->qual[d.seq].s_attending),
   consulting_physician = substring(1,100,m_rec->qual[d.seq].s_consult_phys), encntr_type_class =
   substring(1,50,m_rec->qual[d.seq].s_encntr_class), follow_up = substring(1,100,m_rec->qual[d.seq].
    s_follow_up)
   FROM (dummyt d  WITH seq = m_rec->l_qual_cnt)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 CALL echorecord(frec)
 FREE RECORD m_rec
 FREE RECORD frec
 IF (mn_ops=1)
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
