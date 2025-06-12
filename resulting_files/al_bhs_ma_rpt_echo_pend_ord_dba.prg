CREATE PROGRAM al_bhs_ma_rpt_echo_pend_ord:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Order Date Start:" = "CURDATE",
  "Order Date End:" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs200_echo2dwcontrast_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ECHO2DWCONTRAST"))
 DECLARE mf_cs200_echocomplete_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ECHOCOMPLETE"))
 DECLARE mf_cs6004_incomplete_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3815"
   ))
 DECLARE mf_cs6004_inprocess_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3224")
  )
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE mf_cs6004_pendingcomplete_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!2564278"))
 DECLARE mf_cs6004_pendingreview_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!3103"))
 DECLARE mf_cs6004_suspended_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3104")
  )
 DECLARE mf_cs6004_unscheduled_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!3105"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs220_bmc_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
 DECLARE mf_cs71_inpatient_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3958"))
 DECLARE mf_cs71_emergency_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3957"))
 DECLARE mf_cs71_observation_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17613"
   ))
 DECLARE mf_cs16449_reasonforexam_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "REASONFOREXAM"))
 DECLARE mf_cs16449_reasonforexamdcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   16449,"REASONFOREXAMDCP"))
 DECLARE mf_cs17_admitting_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17001"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ms_dt = vc WITH protect, constant(trim(format(cnvtdatetime(sysdate),"YYYYMMDD;;q"),3))
 DECLARE mf_cs200_isolation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ISOLATION"))
 DECLARE mf_cs200_isolationcovid_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ISOLATIONCOVID"))
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_order_id = f8
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_pat_dob = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_enc_loc = vc
     2 s_ord_cat = vc
     2 s_ord_dt = vc
     2 s_ord_status = vc
     2 s_reason_for_exam = vc
     2 s_other_reason_for_exam = vc
     2 s_ord_provider = vc
     2 s_admit_dt = vc
     2 s_admit_diag = vc
     2 s_isolation_order = vc
     2 s_isolation_type = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND o.active_ind=1
    AND o.catalog_cd IN (mf_cs200_echo2dwcontrast_cd, mf_cs200_echocomplete_cd)
    AND o.order_status_cd IN (mf_cs6004_incomplete_cd, mf_cs6004_inprocess_cd, mf_cs6004_ordered_cd,
   mf_cs6004_pendingcomplete_cd, mf_cs6004_pendingreview_cd,
   mf_cs6004_suspended_cd, mf_cs6004_unscheduled_cd))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND e.loc_facility_cd=mf_cs220_bmc_cd
    AND e.encntr_type_cd IN (mf_cs71_inpatient_cd, mf_cs71_emergency_cd, mf_cs71_observation_cd)
    AND e.disch_dt_tm = null
    AND e.reg_dt_tm IS NOT null)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea1.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn_cd)
  ORDER BY o.order_id
  HEAD o.order_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_order_id = o.order_id, m_rec->qual[m_rec->l_cnt].f_person_id = p
   .person_id, m_rec->qual[m_rec->l_cnt].s_pat_name = trim(p.name_full_formatted,3),
   m_rec->qual[m_rec->l_cnt].s_pat_dob = trim(format(p.birth_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[
   m_rec->l_cnt].s_fin = trim(ea1.alias,3), m_rec->qual[m_rec->l_cnt].s_mrn = trim(ea2.alias,3),
   m_rec->qual[m_rec->l_cnt].s_enc_loc = trim(uar_get_code_display(e.loc_nurse_unit_cd),3)
   IF (e.loc_room_cd > 0)
    m_rec->qual[m_rec->l_cnt].s_enc_loc = concat(m_rec->qual[m_rec->l_cnt].s_enc_loc,"-",trim(
      uar_get_code_display(e.loc_room_cd),3))
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_ord_cat = trim(uar_get_code_display(o.catalog_cd),3), m_rec->qual[
   m_rec->l_cnt].s_ord_dt = trim(format(o.orig_order_dt_tm,"MM/DD/YYYY HH:mm;;q"),3), m_rec->qual[
   m_rec->l_cnt].s_ord_status = trim(uar_get_code_display(o.order_status_cd),3),
   m_rec->qual[m_rec->l_cnt].s_admit_dt = trim(format(e.reg_dt_tm,"MM/DD/YYYY;;q"),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   oe_format_fields off,
   order_detail od
  PLAN (o
   WHERE expand(ml_idx1,1,m_rec->l_cnt,o.order_id,m_rec->qual[ml_idx1].f_order_id))
   JOIN (off
   WHERE off.oe_format_id=o.oe_format_id
    AND off.label_text IN ("Reason for Exam", "Other Reason for Exam"))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=off.oe_field_id)
  ORDER BY o.order_id, od.oe_field_id, od.action_sequence DESC
  HEAD o.order_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,o.order_id,m_rec->qual[ml_idx1].f_order_id)
  HEAD od.oe_field_id
   IF (ml_idx2 > 0)
    IF (off.label_text="Reason for Exam")
     m_rec->qual[ml_idx2].s_reason_for_exam = trim(od.oe_field_display_value,3)
    ENDIF
    IF (off.label_text="Other Reason for Exam")
     m_rec->qual[ml_idx2].s_other_reason_for_exam = trim(od.oe_field_display_value,3)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE expand(ml_idx1,1,m_rec->l_cnt,d.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
    AND d.active_ind=1
    AND d.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND d.diag_type_cd=mf_cs17_admitting_cd)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
  ORDER BY d.encntr_id, d.diagnosis_id
  HEAD d.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,d.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
   WHILE (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_admit_diag = trim(n.source_string,3),ml_idx2 = locateval(ml_idx1,(ml_idx2
     + 1),m_rec->l_cnt,d.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM order_action oa,
   prsnl p
  PLAN (oa
   WHERE expand(ml_idx1,1,m_rec->l_cnt,oa.order_id,m_rec->qual[ml_idx1].f_order_id))
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
  ORDER BY oa.order_id, oa.action_sequence
  HEAD oa.order_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,oa.order_id,m_rec->qual[ml_idx1].f_order_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_ord_provider = trim(p.name_full_formatted)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE expand(ml_idx1,1,m_rec->l_cnt,o.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
    AND o.active_ind=1
    AND o.catalog_cd IN (mf_cs200_isolation_cd, mf_cs200_isolationcovid_cd)
    AND o.order_status_cd=mf_cs6004_ordered_cd)
   JOIN (od
   WHERE (od.order_id= Outerjoin(o.order_id))
    AND (od.oe_field_meaning= Outerjoin("ISOLATIONCODE")) )
  ORDER BY o.encntr_id, o.order_id DESC, od.action_sequence DESC
  HEAD o.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,o.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
   WHILE (ml_idx2 > 0)
     m_rec->qual[ml_idx2].s_isolation_order = trim(uar_get_code_display(o.catalog_cd),3), m_rec->
     qual[ml_idx2].s_isolation_type = trim(od.oe_field_display_value,3), ml_idx2 = locateval(ml_idx1,
      (ml_idx2+ 1),m_rec->l_cnt,o.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 IF (value( $OUTDEV)="OPS")
  SET frec->file_name = concat("bhs_ma_rpt_echo_pend_order_",ms_dt,".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"',"Patient Name",'","',"DOB",'","',
   "FIN",'","',"MRN",'","',"Patient Location",
   '","',"Order Mnemonic",'","',"Order Date",'","',
   "Order Status",'","',"Reason For Exam",'","',"Other Reason For Exam",
   '","',"Ordering Provider",'","',"Admit Date",'","',
   "Admit Diagnosis",'","',"Isolation Order",'","',"Isolation Type",
   '"',char(13),char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_idx1].s_pat_name,3),'","',trim(m_rec->qual[
     ml_idx1].s_pat_dob,3),'","',
    trim(m_rec->qual[ml_idx1].s_fin,3),'","',trim(m_rec->qual[ml_idx1].s_mrn,3),'","',trim(m_rec->
     qual[ml_idx1].s_enc_loc,3),
    '","',trim(m_rec->qual[ml_idx1].s_ord_cat,3),'","',trim(m_rec->qual[ml_idx1].s_ord_dt,3),'","',
    trim(m_rec->qual[ml_idx1].s_ord_status,3),'","',trim(m_rec->qual[ml_idx1].s_reason_for_exam,3),
    '","',trim(m_rec->qual[ml_idx1].s_other_reason_for_exam,3),
    '","',trim(m_rec->qual[ml_idx1].s_ord_provider,3),'","',trim(m_rec->qual[ml_idx1].s_admit_dt,3),
    '","',
    trim(m_rec->qual[ml_idx1].s_admit_diag,3),'","',trim(m_rec->qual[ml_idx1].s_isolation_order,3),
    '","',trim(m_rec->qual[ml_idx1].s_isolation_type,3),
    '"',char(13),char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  DECLARE ms_tmp = vc WITH protect, noconstant("")
  DECLARE ms_email = vc WITH protect, constant("angelce.lazovski@bhs.org")
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("Echo pending orders report: ",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;q"
    ))
  CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
 ELSE
  SELECT INTO  $OUTDEV
   patient_name = trim(substring(1,100,m_rec->qual[d1.seq].s_pat_name),3), dob = trim(substring(1,20,
     m_rec->qual[d1.seq].s_pat_dob),3), fin = trim(substring(1,20,m_rec->qual[d1.seq].s_fin),3),
   mrn = trim(substring(1,20,m_rec->qual[d1.seq].s_mrn),3), patient_location = trim(substring(1,50,
     m_rec->qual[d1.seq].s_enc_loc),3), order_mnemonic = trim(substring(1,100,m_rec->qual[d1.seq].
     s_ord_cat),3),
   order_date = trim(substring(1,30,m_rec->qual[d1.seq].s_ord_dt),3), order_status = trim(substring(1,
     30,m_rec->qual[d1.seq].s_ord_status),3), reason_for_exam = trim(substring(1,200,m_rec->qual[d1
     .seq].s_reason_for_exam),3),
   other_reason_for_exam = trim(substring(1,200,m_rec->qual[d1.seq].s_other_reason_for_exam),3),
   ordering_provider = trim(substring(1,100,m_rec->qual[d1.seq].s_ord_provider),3), admit_dt = trim(
    substring(1,30,m_rec->qual[d1.seq].s_admit_dt),3),
   admit_diagnosis = trim(substring(1,250,m_rec->qual[d1.seq].s_admit_diag),3), isolation_order =
   trim(substring(1,50,m_rec->qual[d1.seq].s_isolation_order),3), isolation_type = trim(substring(1,
     50,m_rec->qual[d1.seq].s_isolation_type),3)
   FROM (dummyt d1  WITH seq = value(m_rec->l_cnt))
   PLAN (d1)
   ORDER BY patient_name
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ENDIF
#exit_script
END GO
