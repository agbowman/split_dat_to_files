CREATE PROGRAM bhs_rpt_consult_gip:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = value(999999),
  "Nurse Unit" = value(999999),
  "Email Recipients  (leave blank to display to screen)" = ""
  WITH outdev, f_facility_cd, f_nurse_unit_cd,
  s_recipients
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
     2 s_room_bed = vc
     2 s_patient_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_order_dt_tm = vc
 ) WITH protect
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION")
  )
 DECLARE mf_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"EMERGENCY"))
 DECLARE mf_consult_gip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTGIPASSESSMENTFORNONCMOPATIENTS"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_expand = i4 WITH protect, noconstant(0)
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit_p = vc WITH protect, noconstant("")
 DECLARE ms_error = vc WITH protect, noconstant("")
 IF (findstring("@",ms_recipients)=0
  AND textlen(trim(ms_recipients,3)) > 0)
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
     SET ms_facility_p = build2("ed.loc_facility_cd in (",parameter(2,ml_loop))
    ELSE
     SET ms_facility_p = build2(ms_facility_p,",",parameter(2,ml_loop))
    ENDIF
  ENDFOR
  SET ms_facility_p = concat(ms_facility_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_facility_p = build2("ed.loc_facility_cd = ",parameter(2,0))
 ENDIF
 SET ms_item_list = reflect(parameter(3,0))
 IF (( $F_NURSE_UNIT_CD=999999))
  SET ms_nurse_unit_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ms_nurse_unit_p = "ed.loc_nurse_unit_cd in ("
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (ml_loop = 1 TO ml_cnt)
    SET ms_nurse_unit_p = concat(ms_nurse_unit_p,cnvtstring(parameter(3,ml_loop)),",")
  ENDFOR
  SET ms_nurse_unit_p = concat(substring(1,(textlen(ms_nurse_unit_p) - 1),ms_nurse_unit_p),")")
 ELSE
  SET ms_nurse_unit_p = concat("ed.loc_nurse_unit_cd = ",cnvtstring( $F_NURSE_UNIT_CD))
 ENDIF
 SELECT INTO "nl:"
  facility = uar_get_code_display(e.loc_facility_cd), nurse_unit = uar_get_code_display(e
   .loc_nurse_unit_cd), room_bed = build2(trim(uar_get_code_display(e.loc_room_cd),3),"/",trim(
    uar_get_code_display(e.loc_bed_cd),3))
  FROM encntr_domain ed,
   encounter e,
   orders o,
   person p
  PLAN (ed
   WHERE parser(ms_facility_p)
    AND parser(ms_nurse_unit_p)
    AND ed.active_ind=1
    AND ed.active_status_cd=mf_active_cd
    AND ed.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_class_cd IN (mf_inpatient_cd, mf_observation_cd, mf_emergency_cd)
    AND e.reg_dt_tm BETWEEN cnvtdatetime((curdate - 365),curtime) AND cnvtdatetime(curdate,curtime)
    AND e.disch_dt_tm=null
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.catalog_cd=mf_consult_gip_cd
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime((curdate - 365),curtime) AND cnvtdatetime(curdate,
    curtime)
    AND o.order_status_cd=mf_ordered_cd
    AND o.active_ind=1
    AND o.active_status_cd=mf_active_cd)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY o.orig_order_dt_tm DESC, facility, nurse_unit,
   room_bed, p.name_full_formatted
  HEAD REPORT
   ml_cnt = 0
  HEAD e.encntr_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].f_encntr_id = e.encntr_id, m_rec->qual[ml_cnt].s_facility =
   uar_get_code_display(e.loc_facility_cd), m_rec->qual[ml_cnt].s_nurse_unit = uar_get_code_display(e
    .loc_nurse_unit_cd),
   m_rec->qual[ml_cnt].s_room_bed = build2(trim(uar_get_code_display(e.loc_room_cd),3),"/",trim(
     uar_get_code_display(e.loc_bed_cd),3)), m_rec->qual[ml_cnt].s_patient_name = p
   .name_full_formatted, m_rec->qual[ml_cnt].s_order_dt_tm = format(o.orig_order_dt_tm,
    "mm/dd/yy HH:mm:ss;;d")
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
   encntr_alias ea
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_id=m_rec->qual[d.seq].f_encntr_id)
    AND ea.encntr_alias_type_cd IN (mf_mrn_cd, mf_fin_cd)
    AND ea.active_ind=1
    AND ea.active_status_cd=mf_active_cd
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
  DETAIL
   IF (ea.encntr_alias_type_cd=mf_mrn_cd)
    m_rec->qual[d.seq].s_mrn = ea.alias
   ELSEIF (ea.encntr_alias_type_cd=mf_fin_cd)
    m_rec->qual[d.seq].s_fin = ea.alias
   ENDIF
  WITH nocounter
 ;end select
 IF (textlen(trim( $S_RECIPIENTS,3)) > 1)
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(sysdate,"mm_dd_yy;;d"),3),".csv")
  SET ms_subject = build2("Active Consult GIP Report ",trim(format(sysdate,"mmm-dd-yyyy hh:mm ;;d"),3
    ))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"FACILITY",','"NURSE UNIT",','"ROOM/BED",','"PATIENT",','"MRN#",',
   '"FIN#",','"ORDER DATE TIME",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_qual_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_facility,3),'","',trim(m_rec->qual[
     ml_cnt].s_nurse_unit,3),'","',
    trim(m_rec->qual[ml_cnt].s_room_bed,3),'","',trim(m_rec->qual[ml_cnt].s_patient_name,3),'","',
    trim(m_rec->qual[ml_cnt].s_mrn,3),
    '","',trim(m_rec->qual[ml_cnt].s_fin,3),'","',trim(m_rec->qual[ml_cnt].s_order_dt_tm,3),'"',
    char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   facility = substring(1,50,m_rec->qual[d.seq].s_facility), nurse_unit = substring(1,50,m_rec->qual[
    d.seq].s_nurse_unit), room_bed = substring(1,50,m_rec->qual[d.seq].s_room_bed),
   patient = substring(1,100,m_rec->qual[d.seq].s_patient_name), mrn = substring(1,50,m_rec->qual[d
    .seq].s_mrn), fin = substring(1,50,m_rec->qual[d.seq].s_fin),
   order_dt_tm = substring(1,50,m_rec->qual[d.seq].s_order_dt_tm)
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
