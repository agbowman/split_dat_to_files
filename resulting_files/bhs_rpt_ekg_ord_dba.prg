CREATE PROGRAM bhs_rpt_ekg_ord:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Email recipient" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_email_recipient
 FREE RECORD m_rec
 RECORD m_rec(
   1 ord[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_fin = vc
     2 s_mrn = vc
     2 s_name = vc
     2 s_enc_type = vc
     2 s_disch_dt_tm = vc
     2 s_rsn_for_exam = vc
     2 f_order_id = f8
     2 s_order = vc
     2 s_ord_stat = vc
     2 s_ord_stat_dt_tm = vc
     2 s_ord_prov = vc
     2 s_ord_loc = vc
   1 cat[*]
     2 f_cat_cd = f8
     2 f_cat_disp = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 DECLARE ms_recipient = vc WITH protect, constant(trim(cnvtlower( $S_EMAIL_RECIPIENT),3))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_card_cat_ty_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"CARDIOLOGY"
   ))
 CALL echo(build2("mf_CARD_CAT_TY_CD: ",mf_card_cat_ty_cd))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(concat(trim( $S_END_DT,4)," 23:59:59"))
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=200
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display_key IN ("*ECG*", "*EKG*", "*HOLTER*")
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->cat,pl_cnt), m_rec->cat[pl_cnt].f_cat_cd = cv.code_value,
   m_rec->cat[pl_cnt].f_cat_disp = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   encounter e,
   encntr_loc_hist elh,
   person p,
   prsnl pr,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND expand(ml_exp,1,size(m_rec->cat,5),o.catalog_cd,m_rec->cat[ml_exp].f_cat_cd)
    AND o.active_ind=1)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_status_cd=o.order_status_cd)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_alias_type_cd=mf_mrn_cd)
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.active_ind=1
    AND o.orig_order_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
  ORDER BY o.person_id, o.encntr_id, o.orig_order_dt_tm DESC,
   oa.action_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD o.order_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->ord,5))
    CALL alterlist(m_rec->ord,(pl_cnt+ 50))
   ENDIF
   m_rec->ord[pl_cnt].f_encntr_id = o.encntr_id, m_rec->ord[pl_cnt].f_person_id = o.person_id, m_rec
   ->ord[pl_cnt].s_fin = trim(ea1.alias,3),
   m_rec->ord[pl_cnt].s_mrn = trim(ea2.alias,3), m_rec->ord[pl_cnt].s_name = trim(p
    .name_full_formatted,3), m_rec->ord[pl_cnt].s_enc_type = trim(uar_get_code_display(e
     .encntr_type_cd),3)
   IF (e.disch_dt_tm != null)
    m_rec->ord[pl_cnt].s_disch_dt_tm = trim(format(e.disch_dt_tm,"mm/dd/yy hh:mm;;d"),3)
   ENDIF
   m_rec->ord[pl_cnt].s_rsn_for_exam = trim(e.reason_for_visit), m_rec->ord[pl_cnt].f_order_id = o
   .order_id, m_rec->ord[pl_cnt].s_order = trim(uar_get_code_display(o.catalog_cd),3),
   m_rec->ord[pl_cnt].s_ord_stat = trim(uar_get_code_display(o.order_status_cd),3), m_rec->ord[pl_cnt
   ].s_ord_stat_dt_tm = trim(format(oa.action_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec->ord[pl_cnt].
   s_ord_prov = trim(pr.name_full_formatted,3),
   m_rec->ord[pl_cnt].s_ord_loc = concat(trim(uar_get_code_display(elh.loc_facility_cd),3)," ",trim(
     uar_get_code_display(elh.loc_nurse_unit_cd),3))
  FOOT REPORT
   CALL alterlist(m_rec->ord,pl_cnt)
  WITH nocounter, expand = 1
 ;end select
 IF (textlen(trim(ms_recipient,3))=0)
  SELECT INTO value( $OUTDEV)
   fin = substring(1,20,m_rec->ord[d.seq].s_fin), mrn = substring(1,20,m_rec->ord[d.seq].s_mrn), name
    = substring(1,50,m_rec->ord[d.seq].s_name),
   encntr_type = substring(1,20,m_rec->ord[d.seq].s_enc_type), disch_dt_tm = m_rec->ord[d.seq].
   s_disch_dt_tm, reason_for_exam = substring(1,200,m_rec->ord[d.seq].s_rsn_for_exam),
   order_name = substring(1,50,m_rec->ord[d.seq].s_order), order_status = substring(1,20,m_rec->ord[d
    .seq].s_ord_stat), order_status_dt_tm = m_rec->ord[d.seq].s_ord_stat_dt_tm,
   ordering_provider = substring(1,50,m_rec->ord[d.seq].s_ord_prov), order_location = substring(1,50,
    m_rec->ord[d.seq].s_ord_loc)
   FROM (dummyt d  WITH seq = value(size(m_rec->ord,5)))
   ORDER BY d.seq
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ELSE
  SET ms_filename = concat("bhs_ekg_ord_",trim(format(sysdate,"mmddyyyyhhmmss;;d"),3),".csv")
  CALL echo(ms_filename)
  SET frec->file_name = ms_filename
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat(
   '"FIN","MRN","NAME","ENCNTR_TYPE","DISCH_DT_TM","REASON_FOR_EXAM","ORDER"',
   '"ORDER_STATUS","ORDER_STATUS_DT_TM","ORDERING_PROVIDER","ORDER_LOCATION"',char(13),char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->ord,5))
   SET frec->file_buf = concat('"',m_rec->ord[ml_loop].s_fin,',"','"',m_rec->ord[ml_loop].s_mrn,
    ',"','"',m_rec->ord[ml_loop].s_name,',"','"',
    m_rec->ord[ml_loop].s_enc_type,',"','"',m_rec->ord[ml_loop].s_disch_dt_tm,',"',
    '"',m_rec->ord[ml_loop].s_rsn_for_exam,',"','"',m_rec->ord[ml_loop].s_order,
    ',"','"',m_rec->ord[ml_loop].s_ord_stat,',"','"',
    m_rec->ord[ml_loop].s_ord_stat_dt_tm,',"','"',m_rec->ord[ml_loop].s_ord_prov,',"',
    '"',m_rec->ord[ml_loop].s_ord_loc,'"',char(13),char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("EKG Ord Report for dates ",ms_beg_dt_tm," - ",ms_end_dt_tm)
  CALL emailfile(value(ms_filename),ms_filename,ms_recipient,ms_tmp,1)
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
