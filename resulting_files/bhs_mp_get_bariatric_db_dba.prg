CREATE PROGRAM bhs_mp_get_bariatric_db:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person ID" = 0
  WITH outdev, f_person_id
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_ncnt = i4
   1 note[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_event_id = f8
     2 s_section = vc
     2 s_note_type = vc
     2 s_title = vc
     2 s_sign_dt_tm = vc
     2 s_signed_by = vc
   1 l_dcnt = i4
   1 dt[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_event_id = f8
     2 s_section = vc
     2 s_note_type = vc
     2 s_title = vc
     2 s_sign_dt_tm = vc
     2 s_signed_by = vc
   1 l_lcnt = i4
   1 labs[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_event_id = f8
     2 s_title = vc
     2 s_result = vc
     2 s_result_dt_tm = vc
   1 l_vcnt = i4
   1 vitals[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_event_id = f8
     2 s_title = vc
     2 s_result = vc
     2 s_result_dt_tm = vc
   1 l_uscnt = i4
   1 us[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_event_id = f8
     2 s_section = vc
     2 s_note_type = vc
     2 s_title = vc
     2 s_sign_dt_tm = vc
     2 s_signed_by = vc
 ) WITH protect
 FREE RECORD m_mpageconfig
 RECORD m_mpageconfig(
   1 l_tcnt = i4
   1 tlst[*]
     2 c_label = c40
     2 l_scnt = i4
     2 slst[*]
       3 c_label = c40
       3 l_ecnt = i4
       3 elst[*]
         4 f_code_value = f8
         4 c_display = c40
 ) WITH protect
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PERSON_ID))
 DECLARE mf_bariatricsurgery_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "BARIATRICSURGERY"))
 DECLARE mf_generalsurgery_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "GENERALSURGERY"))
 DECLARE mf_sleepmedicine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "SLEEPMEDICINE"))
 DECLARE mf_esophagusbariumswallow_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "ESOPHAGUSBARIUMSWALLOW"))
 DECLARE mf_ggegdcolonoscopy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "GGEGDCOLONOSCOPY"))
 DECLARE mf_tsh_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"TSH"))
 DECLARE mf_helicobacterpyloriiggab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "HELICOBACTERPYLORIIGGAB"))
 DECLARE mf_urinenicotine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "URINENICOTINE"))
 DECLARE mf_hemoglobina1cmonitoring_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "HEMOGLOBINA1CMONITORING"))
 DECLARE mf_glucoselevel_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "GLUCOSELEVEL"))
 DECLARE mf_hpyloriag_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"HPYLORIAG"))
 DECLARE mf_ultrasound_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",93,"ULTRASOUND"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE mf_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE mf_store_url_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",25,"STORAGEURL"))
 DECLARE ms_beg_dt_tm = vc WITH protect
 DECLARE ms_end_dt_tm = vc WITH protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_tcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_scnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ecnt = i4 WITH protect, noconstant(0)
 DECLARE ms_rowclass = vc WITH protect, noconstant(" ")
 DECLARE ms_link = vc WITH public, noconstant("")
 DECLARE ms_writeln = vc WITH protect, noconstant("")
 DECLARE ml_htmlfilehandle = w8 WITH protect, noconstant(0)
 DECLARE ml_htmlfilestat = i4 WITH protect, noconstant(0)
 DECLARE ms_sendto = vc WITH protect, noconstant( $OUTDEV)
 IF (mf_person_id=0.0)
  GO TO exit_script
 ENDIF
 SET ms_beg_dt_tm = format(cnvtlookbehind("12 M",cnvtdatetime(curdate,0)),"DD-MMM-YYYY HH:mm:ss;;D")
 SET ms_end_dt_tm = format(cnvtdatetime((curdate+ 1),0),"DD-MMM-YYYY HH:mm:ss;;D")
 SELECT INTO "nl:"
  FROM br_datamart_category bdc,
   br_datamart_report bdr,
   br_datamart_report_filter_r bdfr,
   br_datamart_filter bdf,
   br_datamart_value bdv,
   br_datamart_report_filter_r bdfr2,
   br_datamart_filter bdf2,
   br_datamart_value bdv2,
   dummyt dcv,
   code_value cv
  PLAN (bdc
   WHERE bdc.category_mean="VB_WFBARIATRICDASHBOARDCONFIGU")
   JOIN (bdr
   WHERE bdr.br_datamart_category_id=bdc.br_datamart_category_id)
   JOIN (bdfr
   WHERE bdfr.br_datamart_report_id=bdr.br_datamart_report_id)
   JOIN (bdf
   WHERE bdf.br_datamart_filter_id=bdfr.br_datamart_filter_id
    AND bdf.filter_category_mean="MP_SECT_PARAMS")
   JOIN (bdv
   WHERE bdv.br_datamart_category_id=bdc.br_datamart_category_id
    AND bdv.br_datamart_filter_id=bdf.br_datamart_filter_id
    AND bdv.mpage_param_value IN ("Documents", "Diagnostics", "Labs-Flowsheet Grouping", "Vital Sign",
   "Vital Signs"))
   JOIN (bdfr2
   WHERE bdfr2.br_datamart_report_id=bdfr.br_datamart_report_id)
   JOIN (bdf2
   WHERE bdf2.br_datamart_filter_id=bdfr2.br_datamart_filter_id
    AND bdf2.filter_category_mean IN ("EVENT_SET", "LINK_ENTRY"))
   JOIN (bdv2
   WHERE bdv2.br_datamart_category_id=bdc.br_datamart_category_id
    AND bdv2.br_datamart_filter_id=bdf2.br_datamart_filter_id)
   JOIN (dcv)
   JOIN (cv
   WHERE cv.code_value=bdv2.parent_entity_id
    AND cv.code_value > 0.00)
  ORDER BY bdf.filter_seq, bdf2.filter_seq
  HEAD REPORT
   ml_tcnt = 0, ml_scnt = 0, ml_ecnt = 0
  HEAD bdf.filter_seq
   ml_tcnt += 1, m_mpageconfig->l_tcnt = ml_tcnt, stat = alterlist(m_mpageconfig->tlst,ml_tcnt),
   m_mpageconfig->tlst[ml_tcnt].c_label = trim(bdv.mpage_param_value,3), ml_scnt = 0
   IF (trim(bdv.mpage_param_value,3) IN ("Vital Sign", "Vital Signs"))
    ml_scnt += 1, m_mpageconfig->tlst[ml_tcnt].l_scnt = ml_scnt, stat = alterlist(m_mpageconfig->
     tlst[ml_tcnt].slst,ml_scnt),
    m_mpageconfig->tlst[ml_tcnt].slst[ml_scnt].c_label = trim(bdv2.freetext_desc,3), ml_ecnt = 0
   ENDIF
  HEAD bdf2.filter_seq
   null
  DETAIL
   CASE (bdf2.filter_category_mean)
    OF "LINK_ENTRY":
     ml_scnt += 1,m_mpageconfig->tlst[ml_tcnt].l_scnt = ml_scnt,stat = alterlist(m_mpageconfig->tlst[
      ml_tcnt].slst,ml_scnt),
     m_mpageconfig->tlst[ml_tcnt].slst[ml_scnt].c_label = trim(bdv2.freetext_desc,3),ml_ecnt = 0
    OF "EVENT_SET":
     ml_ecnt += 1,m_mpageconfig->tlst[ml_tcnt].slst[ml_scnt].l_ecnt = ml_ecnt,stat = alterlist(
      m_mpageconfig->tlst[ml_tcnt].slst[ml_scnt].elst,ml_ecnt),
     m_mpageconfig->tlst[ml_tcnt].slst[ml_scnt].elst[ml_ecnt].f_code_value = cv.code_value,
     m_mpageconfig->tlst[ml_tcnt].slst[ml_scnt].elst[ml_ecnt].c_display = cv.display
   ENDCASE
  WITH outerjoin = dcv, nocounter
 ;end select
 SELECT INTO "nl:"
  note_sort =
  IF (cnvtupper(ce.event_title_text)="*NUTRITION*"
   AND trim(m_mpageconfig->tlst[1].slst[d1.seq].c_label,3)="Dietician") 1
  ELSEIF (cnvtupper(ce.event_title_text) != "*NUTRITION*"
   AND trim(m_mpageconfig->tlst[1].slst[d1.seq].c_label,3)="Provider Notes") 3
  ELSE 2
  ENDIF
  FROM (dummyt d1  WITH seq = m_mpageconfig->tlst[1].l_scnt),
   (dummyt d2  WITH seq = 1),
   v500_event_set_code ves,
   v500_event_set_canon vesc,
   v500_event_set_explode vese,
   clinical_event ce,
   prsnl pr,
   ce_blob_result cbr
  PLAN (d1
   WHERE maxrec(d2,m_mpageconfig->tlst[1].slst[d1.seq].l_ecnt))
   JOIN (d2)
   JOIN (ves
   WHERE (ves.event_set_cd=m_mpageconfig->tlst[1].slst[d1.seq].elst[d2.seq].f_code_value))
   JOIN (vesc
   WHERE ((vesc.parent_event_set_cd=ves.event_set_cd) OR ((vesc.event_set_cd=m_mpageconfig->tlst[1].
   slst[d1.seq].elst[d2.seq].f_code_value))) )
   JOIN (vese
   WHERE vese.event_set_cd=vesc.event_set_cd)
   JOIN (ce
   WHERE ce.person_id=mf_person_id
    AND ce.event_cd=vese.event_cd
    AND ce.event_end_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND  NOT (ce.event_title_text IN ("General Surgery Office Visit Note"))
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd)
    AND ce.view_level=1)
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id)
   JOIN (cbr
   WHERE (cbr.event_id= Outerjoin(ce.event_id)) )
  ORDER BY note_sort, ce.event_end_dt_tm DESC, ce.event_id
  HEAD REPORT
   ml_cnt = 0
  HEAD note_sort
   null
  HEAD ce.event_end_dt_tm
   null
  HEAD ce.event_id
   IF (((cnvtupper(ce.event_title_text)="*NUTRITION*"
    AND trim(m_mpageconfig->tlst[1].slst[d1.seq].c_label,3)="Dietician") OR (((cnvtupper(ce
    .event_title_text) != "*NUTRITION*"
    AND trim(m_mpageconfig->tlst[1].slst[d1.seq].c_label,3)="Provider Notes") OR ( NOT (trim(
    m_mpageconfig->tlst[1].slst[d1.seq].c_label,3) IN ("Provider Notes", "Dietician")))) )) )
    ml_cnt += 1, m_rec->l_ncnt = ml_cnt, stat = alterlist(m_rec->note,ml_cnt),
    m_rec->note[ml_cnt].f_event_id = ce.event_id, m_rec->note[ml_cnt].f_encntr_id = ce.encntr_id,
    m_rec->note[ml_cnt].f_person_id = ce.person_id,
    m_rec->note[ml_cnt].s_section = trim(m_mpageconfig->tlst[1].slst[d1.seq].c_label,3), m_rec->note[
    ml_cnt].s_sign_dt_tm = trim(format(ce.performed_dt_tm,"mm/dd/yy hh:mm;;d")), m_rec->note[ml_cnt].
    s_signed_by = trim(pr.name_full_formatted),
    m_rec->note[ml_cnt].s_note_type = trim(uar_get_code_display(ce.event_cd),3), m_rec->note[ml_cnt].
    s_title = trim(ce.event_title_text,3)
   ENDIF
  FOOT REPORT
   IF (ml_cnt=0)
    ml_cnt += 1, m_rec->l_ncnt = ml_cnt, stat = alterlist(m_rec->note,ml_cnt),
    m_rec->note[ml_cnt].f_event_id = 0.00, m_rec->note[ml_cnt].f_encntr_id = 0.00, m_rec->note[ml_cnt
    ].f_person_id = 0.00,
    m_rec->note[ml_cnt].s_section = "No Notes Found", m_rec->note[ml_cnt].s_sign_dt_tm = " ", m_rec->
    note[ml_cnt].s_signed_by = " ",
    m_rec->note[ml_cnt].s_note_type = " ", m_rec->note[ml_cnt].s_title = " "
   ENDIF
  WITH nullreport, nocounter
 ;end select
 SELECT INTO "nl:"
  nullind_ce_performed_dt_tm = nullind(ce.performed_dt_tm), nullind_ce_performed_dt_tm = nullind(ce
   .performed_dt_tm)
  FROM (dummyt d1  WITH seq = m_mpageconfig->tlst[2].l_scnt),
   (dummyt d2  WITH seq = 1),
   v500_event_set_explode vese,
   clinical_event ce,
   prsnl pr,
   ce_blob_result cbr
  PLAN (d1
   WHERE maxrec(d2,m_mpageconfig->tlst[2].slst[d1.seq].l_ecnt))
   JOIN (d2)
   JOIN (vese
   WHERE (vese.event_set_cd=m_mpageconfig->tlst[2].slst[d1.seq].elst[d2.seq].f_code_value)
    AND vese.dm2_mig_seq_id != 0.00)
   JOIN (ce
   WHERE ce.person_id=mf_person_id
    AND ce.event_cd=vese.event_cd
    AND ce.event_end_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd)
    AND ce.view_level=1)
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id)
   JOIN (cbr
   WHERE (cbr.event_id= Outerjoin(ce.event_id)) )
  ORDER BY d1.seq, d2.seq, ce.event_cd,
   ce.event_end_dt_tm DESC, ce.event_id
  HEAD REPORT
   ml_cnt = 0, ml_ucnt = 0
  HEAD d1.seq
   null
  HEAD d2.seq
   null
  HEAD ce.event_cd
   null
  HEAD ce.event_end_dt_tm
   null
  HEAD ce.event_id
   IF ((m_mpageconfig->tlst[2].slst[d1.seq].elst[d2.seq].c_display="ULTRASOUND"))
    ml_ucnt += 1, m_rec->l_uscnt = ml_ucnt, stat = alterlist(m_rec->us,ml_ucnt),
    m_rec->us[ml_ucnt].f_event_id = ce.event_id, m_rec->us[ml_ucnt].f_encntr_id = ce.encntr_id, m_rec
    ->us[ml_ucnt].f_person_id = ce.person_id
    IF (nullind_ce_performed_dt_tm=1)
     m_rec->us[ml_ucnt].s_sign_dt_tm = trim(format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"))
    ELSE
     m_rec->us[ml_ucnt].s_sign_dt_tm = trim(format(ce.performed_dt_tm,"mm/dd/yy hh:mm;;d"))
    ENDIF
    m_rec->us[ml_ucnt].s_signed_by = trim(pr.name_full_formatted), m_rec->us[ml_ucnt].s_note_type =
    trim(uar_get_code_display(ce.event_cd),3), m_rec->us[ml_ucnt].s_title = trim(uar_get_code_display
     (ce.event_cd),3)
   ELSE
    ml_cnt += 1, m_rec->l_dcnt = ml_cnt, stat = alterlist(m_rec->dt,ml_cnt),
    m_rec->dt[ml_cnt].f_event_id = ce.event_id, m_rec->dt[ml_cnt].f_encntr_id = ce.encntr_id, m_rec->
    dt[ml_cnt].f_person_id = ce.person_id
    IF (nullind_ce_performed_dt_tm=1)
     m_rec->dt[ml_cnt].s_sign_dt_tm = trim(format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"))
    ELSE
     m_rec->dt[ml_cnt].s_sign_dt_tm = trim(format(ce.performed_dt_tm,"mm/dd/yy hh:mm;;d"))
    ENDIF
    m_rec->dt[ml_cnt].s_signed_by = trim(pr.name_full_formatted), m_rec->dt[ml_cnt].s_note_type =
    trim(uar_get_code_display(ce.event_cd),3), m_rec->dt[ml_cnt].s_title = trim(uar_get_code_display(
      ce.event_cd),3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  nullind_ce_performed_dt_tm = nullind(ce.performed_dt_tm)
  FROM (dummyt d1  WITH seq = m_mpageconfig->tlst[3].l_scnt),
   (dummyt d2  WITH seq = 1),
   v500_event_set_explode vese,
   code_value cv,
   clinical_event ce,
   prsnl pr
  PLAN (d1
   WHERE maxrec(d2,m_mpageconfig->tlst[3].slst[d1.seq].l_ecnt))
   JOIN (d2)
   JOIN (vese
   WHERE (vese.event_set_cd=m_mpageconfig->tlst[3].slst[d1.seq].elst[d2.seq].f_code_value)
    AND vese.dm2_mig_seq_id != 0.00)
   JOIN (cv
   WHERE cv.code_value=vese.event_cd)
   JOIN (ce
   WHERE ce.person_id=mf_person_id
    AND ce.event_cd=vese.event_cd
    AND ce.event_end_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd)
    AND ce.view_level=1)
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id)
  ORDER BY cv.display_key, ce.event_cd, ce.event_end_dt_tm DESC,
   ce.event_id
  HEAD REPORT
   ml_cnt = 0
  HEAD cv.display_key
   null
  HEAD ce.event_cd
   ml_cnt += 1, m_rec->l_lcnt = ml_cnt, stat = alterlist(m_rec->labs,ml_cnt),
   m_rec->labs[ml_cnt].f_event_id = ce.event_id, m_rec->labs[ml_cnt].f_encntr_id = ce.encntr_id,
   m_rec->labs[ml_cnt].f_person_id = ce.person_id,
   m_rec->labs[ml_cnt].s_title = trim(uar_get_code_display(ce.event_cd),3), m_rec->labs[ml_cnt].
   s_result = trim(ce.result_val,3)
   IF (nullind_ce_performed_dt_tm=1)
    m_rec->labs[ml_cnt].s_result_dt_tm = trim(format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"))
   ELSE
    m_rec->labs[ml_cnt].s_result_dt_tm = trim(format(ce.performed_dt_tm,"mm/dd/yy hh:mm;;d"))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  nullind_ce_performed_dt_tm = nullind(ce.performed_dt_tm)
  FROM (dummyt d1  WITH seq = m_mpageconfig->tlst[3].l_scnt),
   (dummyt d2  WITH seq = 1),
   v500_event_set_explode vese,
   code_value cv,
   clinical_event ce,
   prsnl pr
  PLAN (d1
   WHERE maxrec(d2,m_mpageconfig->tlst[4].slst[d1.seq].l_ecnt))
   JOIN (d2)
   JOIN (vese
   WHERE (vese.event_set_cd=m_mpageconfig->tlst[4].slst[d1.seq].elst[d2.seq].f_code_value)
    AND vese.dm2_mig_seq_id != 0.00)
   JOIN (cv
   WHERE cv.code_value=vese.event_cd)
   JOIN (ce
   WHERE ce.person_id=mf_person_id
    AND ce.event_cd=vese.event_cd
    AND ce.event_end_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd)
    AND ce.view_level=1)
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id)
  ORDER BY cv.display_key, ce.event_cd, ce.event_end_dt_tm DESC,
   ce.event_id
  HEAD REPORT
   ml_cnt = 0
  HEAD cv.display_key
   null
  HEAD ce.event_cd
   ml_cnt += 1, m_rec->l_vcnt = ml_cnt, stat = alterlist(m_rec->vitals,ml_cnt),
   m_rec->vitals[ml_cnt].f_event_id = ce.event_id, m_rec->vitals[ml_cnt].f_encntr_id = ce.encntr_id,
   m_rec->vitals[ml_cnt].f_person_id = ce.person_id,
   m_rec->vitals[ml_cnt].s_title = trim(uar_get_code_display(ce.event_cd),3)
   IF (cv.display IN ("Height", "Weight"))
    m_rec->vitals[ml_cnt].s_result = concat(trim(ce.result_val,3)," ",trim(uar_get_code_display(ce
       .result_units_cd),3))
   ELSE
    m_rec->vitals[ml_cnt].s_result = trim(ce.result_val,3)
   ENDIF
   IF (nullind_ce_performed_dt_tm=1)
    m_rec->vitals[ml_cnt].s_result_dt_tm = trim(format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"))
   ELSE
    m_rec->vitals[ml_cnt].s_result_dt_tm = trim(format(ce.performed_dt_tm,"mm/dd/yy hh:mm;;d"))
   ENDIF
  WITH nocounter
 ;end select
 SET ml_htmlfilehandle = uar_fopen(nullterm(ms_sendto),"w+b")
 SET ms_writeln = build2('<?xml version="1.0" encoding="utf-8"?>',
  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"',
  ' "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
  '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"',
  ' xmlns:v="urn:schemas-microsoft-com:vml">')
 SET ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
 SET ms_writeln = build2('<head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8;',
  ' CCLLINK; APPLINK; CCLNEWSESSIONWINDOW"/>')
 SET ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
 SET ms_writeln = build2("<style>","td.headrow {","   font-family: helvetica, arial;",
  "   font-size: 100%;","   font-weight: bold;",
  "   font-color: #ffffff;","   color: #000000;","   border-bottom: 1px solid black;","}",
  "td.detailcelldata {",
  "   font-family: helvetica, arial;","   font-size: 100%;","   font-color: #000000","}",
  "tr.evenrow {",
  "   font-family: helvetica, arial;","   font-size: 100%;","   font-color: #ffffff;",
  "   background-color: white;","}",
  "tr.oddrow {","   font-family: helvetica, arial;","   font-size: 100%;","   font-color: #ffffff;",
  "   background-color: #e3e5ff;",
  "}","</style>")
 SET ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
 SET ms_writeln = build2("</head>","<body>")
 SET ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = m_rec->l_ncnt)
  HEAD REPORT
   ms_writeln = build2('<table cellpadding="0" cellspacing="0" border="0" style="width:99%>',
    '  <tr width="100%">',"    <td class = 'headrow' colspan=5><font size=2px>Notes</font></td>",
    "  </tr>",'  <tr width="100%">',
    "    <td class = 'headrow'><font size=2px>Section</font></td>",
    "    <td class = 'headrow'><font size=2px>Note Type</font></td>",
    "    <td class = 'headrow'><font size=2px>Note Title</font></td>",
    "    <td class = 'headrow'><font size=2px>Signed Dt/Tm</font></td>",
    "    <td class = 'headrow'><font size=2px>Signed By</font></td>",
    "  </tr>"), ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
  DETAIL
   CASE (mod(d1.seq,2))
    OF 0:
     ms_rowclass = "evenrow"
    OF 1:
     ms_rowclass = "oddrow"
   ENDCASE
   ms_link = build('<a href="#" onclick="viewNote(',m_rec->note[d1.seq].f_person_id,",",m_rec->note[
    d1.seq].f_event_id,')">',
    m_rec->note[d1.seq].s_title,"</a>"), ms_writeln = build2('<tr class="',ms_rowclass,
    '" width="100%">','		<td class="detailcelldata"><font size=2px>',m_rec->note[d1.seq].s_section,
    "</font></td>",'		<td class="detailcelldata"><font size=2px>',m_rec->note[d1.seq].s_note_type,
    "</font></td>",'   <td class="detailcelldata"><font size=2px>',
    ms_link,"</font></td>",'		<td class="detailcelldata"><font size=2px>',m_rec->note[d1.seq].
    s_sign_dt_tm,"</font></td>",
    '		<td class="detailcelldata"><font size=2px>',m_rec->note[d1.seq].s_signed_by,"</font></td>",
    '		<td class="detailcelldata"><font size=2px> </td>',"	</tr>"), ml_htmlfilestat = uar_fwrite(
    ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
  FOOT REPORT
   ms_writeln = build2("</table></div>"), ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),
    ml_htmlfilehandle)
  WITH nocounter
 ;end select
 IF (size(m_rec->dt,5) > 0)
  SET ms_writeln = build2("<br>")
  SET ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_dcnt)
   HEAD REPORT
    ms_writeln = build2('<table cellpadding="0" cellspacing="0" border="0" style="width:99%>',
     '  <tr width="100%">',
     "    <td class = 'headrow' colspan=2><font size=2px>Diagnostic Tests</font></td>","  </tr>",
     '  <tr width="100%">',
     "    <td class = 'headrow'><font size=2px>Diagnostic Test</font></td>",
     "    <td class = 'headrow'><font size=2px>Date/Time Resulted</font></td>","  </tr>"),
    ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
   DETAIL
    CASE (mod(d1.seq,2))
     OF 0:
      ms_rowclass = "evenrow"
     OF 1:
      ms_rowclass = "oddrow"
    ENDCASE
    ms_link = build('<a href="#" onclick="viewResult(',m_rec->dt[d1.seq].f_person_id,",",m_rec->dt[d1
     .seq].f_event_id,')">',
     m_rec->dt[d1.seq].s_title,"</a>"), ms_writeln = build2('<tr class="',ms_rowclass,
     '" width="100%">','   <td class="detailcelldata"><font size=2px>',ms_link,
     "</font></td>",'		<td class="detailcelldata"><font size=2px>',m_rec->dt[d1.seq].s_sign_dt_tm,
     "</font></td>","	</tr>"), ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),
     ml_htmlfilehandle)
   FOOT REPORT
    ms_writeln = build2("</table></div>"), ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),
     ml_htmlfilehandle)
   WITH nocounter
  ;end select
 ENDIF
 IF (size(m_rec->labs,5) > 0)
  SET ms_writeln = build2("<br>")
  SET ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_lcnt)
   HEAD REPORT
    ms_writeln = build2('<table cellpadding="0" cellspacing="0" border="0" style="width:99%>',
     '  <tr width="100%">',"    <td class = 'headrow' colspan=3><font size=2px>Labs</font></td>",
     "  </tr>",'  <tr width="100%">',
     "    <td class = 'headrow'><font size=2px>Lab Name</font></td>",
     "    <td class = 'headrow'><font size=2px>Lab Result</font></td>",
     "    <td class = 'headrow'><font size=2px>Date/Time Resulted</font></td>","  </tr>"),
    ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
   DETAIL
    CASE (mod(d1.seq,2))
     OF 0:
      ms_rowclass = "evenrow"
     OF 1:
      ms_rowclass = "oddrow"
    ENDCASE
    ms_link = build('<a href="javascript:viewResult(',m_rec->labs[d1.seq].f_person_id,",",m_rec->
     labs[d1.seq].f_event_id,');">',
     m_rec->labs[d1.seq].s_title,"</a>"), ms_writeln = build2('<tr class="',ms_rowclass,
     '" width="100%">','   <td class="detailcelldata"><font size=2px>',ms_link,
     "</font></td>",'		<td class="detailcelldata"><font size=2px>',m_rec->labs[d1.seq].s_result,
     "</font></td>",'		<td class="detailcelldata"><font size=2px>',
     m_rec->labs[d1.seq].s_result_dt_tm,"</font></td>","	</tr>"), ml_htmlfilestat = uar_fwrite(
     ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
   FOOT REPORT
    ms_writeln = build2("</table></div>"), ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),
     ml_htmlfilehandle)
   WITH nocounter
  ;end select
 ENDIF
 IF (size(m_rec->vitals,5) > 0)
  SET ms_writeln = build2("<br>")
  SET ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_vcnt)
   HEAD REPORT
    ms_writeln = build2('<table cellpadding="0" cellspacing="0" border="0" style="width:99%>',
     '  <tr width="100%">',
     "    <td class = 'headrow' colspan=3><font size=2px>Vital Signs</font></td>","  </tr>",
     '  <tr width="100%">',
     "    <td class = 'headrow'><font size=2px>Vital Sign</font></td>",
     "    <td class = 'headrow'><font size=2px>Result</font></td>",
     "    <td class = 'headrow'><font size=2px>Date/Time Resulted</font></td>","  </tr>"),
    ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
   DETAIL
    CASE (mod(d1.seq,2))
     OF 0:
      ms_rowclass = "evenrow"
     OF 1:
      ms_rowclass = "oddrow"
    ENDCASE
    ms_link = build('<a href="javascript:viewResult(',m_rec->vitals[d1.seq].f_person_id,",",m_rec->
     vitals[d1.seq].f_event_id,');">',
     m_rec->vitals[d1.seq].s_title,"</a>"), ms_writeln = build2('<tr class="',ms_rowclass,
     '" width="100%">','   <td class="detailcelldata"><font size=2px>',ms_link,
     "</font></td>",'		<td class="detailcelldata"><font size=2px>',m_rec->vitals[d1.seq].s_result,
     "</font></td>",'		<td class="detailcelldata"><font size=2px>',
     m_rec->vitals[d1.seq].s_result_dt_tm,"</font></td>","	</tr>"), ml_htmlfilestat = uar_fwrite(
     ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
   FOOT REPORT
    ms_writeln = build2("</table></div>"), ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),
     ml_htmlfilehandle)
   WITH nocounter
  ;end select
 ENDIF
 IF (size(m_rec->us,5) > 0)
  SET ms_writeln = build2("<br>")
  SET ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_uscnt)
   HEAD REPORT
    ms_writeln = build2('<table cellpadding="0" cellspacing="0" border="0" style="width:99%>',
     '  <tr width="100%">',
     "    <td class = 'headrow' colspan=2><font size=2px>Ultrasounds</font></td>","  </tr>",
     '  <tr width="100%">',
     "    <td class = 'headrow'><font size=2px>Ultrasound Test</font></td>",
     "    <td class = 'headrow'><font size=2px>Date/Time Resulted</font></td>","  </tr>"),
    ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
   DETAIL
    CASE (mod(d1.seq,2))
     OF 0:
      ms_rowclass = "evenrow"
     OF 1:
      ms_rowclass = "oddrow"
    ENDCASE
    ms_link = build('<a href="#" onclick="viewNote(',m_rec->us[d1.seq].f_person_id,",",m_rec->us[d1
     .seq].f_event_id,')">',
     m_rec->us[d1.seq].s_title,"</a>"), ms_writeln = build2('<tr class="',ms_rowclass,
     '" width="100%">','   <td class="detailcelldata"><font size=2px>',ms_link,
     "</font></td>",'		<td class="detailcelldata"><font size=2px>',m_rec->us[d1.seq].s_sign_dt_tm,
     "</font></td>","	</tr>"), ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),
     ml_htmlfilehandle)
   FOOT REPORT
    ms_writeln = build2("</table></div>"), ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),
     ml_htmlfilehandle)
   WITH nocounter
  ;end select
 ENDIF
 SET ms_writeln = build2("</html>")
 SET ml_htmlfilestat = uar_fwrite(ms_writeln,1,size(ms_writeln),ml_htmlfilehandle)
 SET ml_htmlfilestat = uar_fclose(ml_htmlfilehandle)
#exit_script
END GO
