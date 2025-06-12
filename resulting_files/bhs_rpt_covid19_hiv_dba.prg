CREATE PROGRAM bhs_rpt_covid19_hiv:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = value(68591952.00,65372709.00,68733320.00),
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients (Leave blank to display to screen):" = ""
  WITH outdev, f_facility_cd, s_begin_date,
  s_end_date, s_recipients
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 RECORD m_rec(
   1 l_ord_cnt = i4
   1 l_qual_cnt = i4
   1 ord[*]
     2 f_catalog_cd = f8
   1 qual[*]
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_dob = vc
     2 s_diag_code = vc
     2 s_diag_loc = vc
     2 s_covid19_ord = vc
     2 s_order_dt_tm = vc
     2 s_result = vc
     2 s_result_dt_tm = vc
     2 s_order_loc = vc
     2 s_ord_provider = vc
 ) WITH protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_icd10cm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"ICD10CM"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_inprocess_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_error = vc WITH protect, noconstant("")
 IF (cnvtdatetime(mf_begin_dt_tm) > cnvtdatetime(mf_end_dt_tm))
  SET ms_error = "Start date must be before end date."
  GO TO exit_script
 ELSEIF (cnvtdatetime(mf_begin_dt_tm) < cnvtdatetime("01-JAN-2020 00:00:00"))
  SET ms_error = "Start date is prior to 2020."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(trim(ms_recipients,3)) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_ordcatsyn_list bol,
   order_catalog oc
  PLAN (bol
   WHERE bol.list_key="COVID19"
    AND bol.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=bol.catalog_cd
    AND oc.active_ind=1)
  ORDER BY oc.catalog_cd
  HEAD REPORT
   ml_cnt = 0
  HEAD oc.catalog_cd
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->ord,5))
    CALL alterlist(m_rec->ord,(ml_cnt+ 9))
   ENDIF
   m_rec->ord[ml_cnt].f_catalog_cd = oc.catalog_cd
  FOOT REPORT
   m_rec->l_ord_cnt = ml_cnt,
   CALL alterlist(m_rec->ord,ml_cnt), ml_cnt = 0
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM encounter e,
   diagnosis d,
   nomenclature n,
   orders o,
   encounter e2,
   order_action oa,
   prsnl pr,
   person p,
   encntr_alias ea,
   clinical_event ce
  PLAN (e
   WHERE (e.loc_facility_cd= $F_FACILITY_CD)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (d
   WHERE d.encntr_id=e.encntr_id
    AND d.active_ind=1
    AND d.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.source_vocabulary_cd=mf_icd10cm_cd
    AND n.source_identifier="B20"
    AND n.active_ind=1
    AND n.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (o
   WHERE o.person_id=e.person_id
    AND expand(ml_cnt,1,m_rec->l_ord_cnt,o.catalog_cd,m_rec->ord[ml_cnt].f_catalog_cd)
    AND o.order_status_cd IN (mf_ordered_cd, mf_completed_cd, mf_inprocess_cd)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND o.active_ind=1)
   JOIN (e2
   WHERE e2.encntr_id=o.encntr_id
    AND e2.active_ind=1
    AND e2.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (oa
   WHERE oa.order_id=o.order_id)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_mrn_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ce
   WHERE (ce.encntr_id= Outerjoin(o.encntr_id))
    AND (ce.order_id= Outerjoin(o.order_id))
    AND (textlen(trim(ce.result_val,3))!= Outerjoin(0))
    AND (ce.publish_flag= Outerjoin(1))
    AND (ce.view_level= Outerjoin(1))
    AND (ce.valid_until_dt_tm> Outerjoin(sysdate)) )
  ORDER BY p.name_full_formatted, p.person_id, o.orig_order_dt_tm DESC,
   ce.event_end_dt_tm DESC
  HEAD REPORT
   ml_cnt = 0
  HEAD p.person_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].s_pat_name = substring(1,50,p.name_full_formatted), m_rec->qual[ml_cnt].s_mrn
    = trim(ea.alias,3), m_rec->qual[ml_cnt].s_dob = trim(format(p.birth_dt_tm,"mm/dd/yy;;d"),3),
   m_rec->qual[ml_cnt].s_diag_code = trim(n.source_identifier,3), m_rec->qual[ml_cnt].s_diag_loc =
   substring(1,50,uar_get_code_display(e.loc_facility_cd)), m_rec->qual[ml_cnt].s_covid19_ord =
   substring(1,50,o.order_mnemonic),
   m_rec->qual[ml_cnt].s_order_dt_tm = trim(format(o.orig_order_dt_tm,"mm/dd/yy HH:mm:ss;;d"),3),
   m_rec->qual[ml_cnt].s_result = evaluate(textlen(trim(ce.result_val,3)),0,"PENDING",cnvtupper(ce
     .result_val)), m_rec->qual[ml_cnt].s_result_dt_tm = format(ce.event_end_dt_tm,
    "mm/dd/yy HH:mm:ss;;d"),
   m_rec->qual[ml_cnt].s_order_loc = build2(trim(uar_get_code_display(e2.loc_facility_cd),3),"/",trim
    (uar_get_code_display(e2.loc_nurse_unit_cd,3))), m_rec->qual[ml_cnt].s_ord_provider = substring(1,
    50,pr.name_full_formatted)
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_qual_cnt = ml_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (textlen(trim( $S_RECIPIENTS,3)) > 1)
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
   "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy;;d"),3),
   ".csv")
  SET ms_subject = build2("Covid19 HIV Report ",trim(format(mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d")),
   " to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"MRN#",','"DATE OF BIRTH",','"DIAGNOSIS CODE",',
   '"DIAGNOSIS LOCATION",',
   '"COVID19 ORDER",','"ORDER DT TM",','"RESULT",','"RESULT DT TM",','"ORDER LOCATION",',
   '"ORDERING PROVIDER",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_qual_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_pat_name,3),'","',trim(m_rec->qual[
     ml_cnt].s_mrn,3),'","',
    trim(m_rec->qual[ml_cnt].s_dob,3),'","',trim(m_rec->qual[ml_cnt].s_diag_code,3),'","',trim(m_rec
     ->qual[ml_cnt].s_diag_loc,3),
    '","',trim(m_rec->qual[ml_cnt].s_covid19_ord,3),'","',trim(m_rec->qual[ml_cnt].s_order_dt_tm,3),
    '","',
    trim(m_rec->qual[ml_cnt].s_result,3),'","',trim(m_rec->qual[ml_cnt].s_result_dt_tm,3),'","',trim(
     m_rec->qual[ml_cnt].s_order_loc,3),
    '","',trim(m_rec->qual[ml_cnt].s_ord_provider,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,50,m_rec->qual[d.seq].s_pat_name), mrn# = m_rec->qual[d.seq].s_mrn,
   date_of_birth = m_rec->qual[d.seq].s_dob,
   diagnosis_code = m_rec->qual[d.seq].s_diag_code, diagnosis_location = m_rec->qual[d.seq].
   s_diag_loc, covid19_order = m_rec->qual[d.seq].s_covid19_ord,
   order_dt_tm = m_rec->qual[d.seq].s_order_dt_tm, result = m_rec->qual[d.seq].s_result, result_dt_tm
    = m_rec->qual[d.seq].s_result_dt_tm,
   order_location = m_rec->qual[d.seq].s_order_loc, ordering_provider = substring(1,50,m_rec->qual[d
    .seq].s_ord_provider)
   FROM (dummyt d  WITH seq = m_rec->l_qual_cnt)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
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
