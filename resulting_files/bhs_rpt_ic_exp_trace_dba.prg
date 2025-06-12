CREATE PROGRAM bhs_rpt_ic_exp_trace:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "FIN" = "",
  "Exposure Start Date:" = "CURDATE",
  "Exposure End Date:" = "CURDATE"
  WITH outdev, s_fin, s_beg_dt,
  s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[1]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_pat_name_last = vc
     2 s_pat_name_first = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_unit_room_bed = vc
     2 s_reg_dt_tm = vc
     2 s_disch_dt_tm = vc
     2 exp[*]
       3 f_prsnl_id = f8
       3 s_prsnl_name_last = vc
       3 s_prsnl_name_first = vc
       3 s_prsnl_reltn = vc
       3 s_emp_num = vc
       3 s_document_name = vc
       3 s_document_type = vc
       3 s_document_folder = vc
       3 f_event_id = f8
       3 f_event_cd = f8
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE ms_fin = vc WITH protect, constant(trim( $S_FIN,3))
 DECLARE mf_cs8_active = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2669"))
 DECLARE mf_cs21_author = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2638"))
 DECLARE mf_cs21_perform = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2647"))
 DECLARE mf_cs53_doc = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3804"))
 DECLARE mf_cs53_mdoc = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2696"))
 DECLARE mf_cs53_rad = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!5115"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_333_chart_rev = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,"CHARTREVIEW")
  )
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encounter e,
   person p
  PLAN (ea
   WHERE ea.alias=ms_fin
    AND ea.encntr_alias_type_cd=mf_cs319_fin
    AND ea.end_effective_dt_tm > sysdate
    AND ea.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   mf_encntr_id = e.encntr_id, mf_person_id = e.person_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
#select2
 SELECT INTO "nl:"
  FROM ce_event_prsnl cep,
   clinical_event ce,
   encounter e,
   encntr_alias ea,
   person p,
   prsnl pr
  PLAN (cep
   WHERE cep.person_id=mf_person_id
    AND cep.action_type_cd IN (mf_cs21_author, mf_cs21_perform)
    AND cep.action_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ce.encntr_id=mf_encntr_id
    AND ce.event_class_cd IN (mf_cs53_doc, mf_cs53_mdoc, mf_cs53_rad)
    AND ce.view_level=1)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_cs319_mrn
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pr
   WHERE pr.person_id=cep.action_prsnl_id
    AND pr.name_last != "Not on Staff"
    AND pr.name_full_formatted != "HIM , Scanning Tech"
    AND pr.username != "SYSTEM")
  ORDER BY pr.person_id
  HEAD REPORT
   pl_cnt = size(m_rec->pat[1].exp,5)
  DETAIL
   IF (((pl_cnt=0) OR (locateval(ml_loc,1,size(m_rec->pat[1].exp,5),pr.person_id,m_rec->pat[1].exp[
    ml_loc].f_prsnl_id)=0)) )
    pl_cnt += 1
    IF (pl_cnt=1)
     m_rec->pat[1].f_person_id = e.person_id, m_rec->pat[1].s_pat_name_last = trim(p.name_last,3),
     m_rec->pat[1].s_pat_name_first = trim(p.name_first,3),
     m_rec->pat[1].s_fin = ms_fin, m_rec->pat[1].s_mrn = trim(ea.alias,3), m_rec->pat[1].
     s_unit_room_bed = concat(trim(uar_get_code_display(e.loc_nurse_unit_cd),3),"/",trim(
       uar_get_code_display(e.loc_room_cd),3),trim(uar_get_code_display(e.loc_bed_cd),3)),
     m_rec->pat[1].s_reg_dt_tm = trim(format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec->pat[1].
     s_disch_dt_tm = trim(format(e.disch_dt_tm,"mm/dd/yy hh:mm;;d"),3)
    ENDIF
    CALL alterlist(m_rec->pat[1].exp,pl_cnt), m_rec->pat[1].exp[pl_cnt].f_prsnl_id = pr.person_id,
    m_rec->pat[1].exp[pl_cnt].s_prsnl_name_last = trim(pr.name_last,3),
    m_rec->pat[1].exp[pl_cnt].s_prsnl_name_first = trim(pr.name_first,3), m_rec->pat[1].exp[pl_cnt].
    s_prsnl_reltn = "Created Note", m_rec->pat[1].exp[pl_cnt].s_emp_num = trim(pr.username,3),
    m_rec->pat[1].exp[pl_cnt].s_document_name = trim(ce.event_title_text,3), m_rec->pat[1].exp[pl_cnt
    ].s_document_type = trim(uar_get_code_display(ce.event_cd),3), m_rec->pat[1].exp[pl_cnt].
    f_event_cd = ce.event_cd,
    m_rec->pat[1].exp[pl_cnt].f_event_id = ce.event_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pat[1].exp,5))),
   v500_event_set_explode vese
  PLAN (d
   WHERE (m_rec->pat[1].exp[d.seq].f_event_cd > 0.0))
   JOIN (vese
   WHERE (vese.event_cd=m_rec->pat[1].exp[d.seq].f_event_cd)
    AND vese.event_set_level=1)
  ORDER BY d.seq
  HEAD d.seq
   null
  DETAIL
   m_rec->pat[1].exp[d.seq].s_document_folder = trim(uar_get_code_display(vese.event_set_cd),3)
  WITH nocounter
 ;end select
 SELECT
  sc.surg_case_id, sc.surg_start_dt_tm, ca.active_ind,
  ca.attendee_free_text_name, ca.case_attendance_id, ca.case_attendee_id,
  pr.name_full_formatted, ca.role_perf_cd
  FROM surgical_case sc,
   case_attendance ca,
   prsnl pr,
   encounter e,
   encntr_alias ea,
   person p
  PLAN (sc
   WHERE sc.person_id=mf_person_id
    AND sc.encntr_id=mf_encntr_id
    AND sc.surg_start_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND sc.active_ind=1)
   JOIN (ca
   WHERE ca.surg_case_id=sc.surg_case_id)
   JOIN (pr
   WHERE pr.person_id=ca.case_attendee_id)
   JOIN (e
   WHERE e.encntr_id=sc.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_cs319_mrn
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY sc.surg_case_id, pr.person_id
  HEAD REPORT
   pl_cnt = size(m_rec->pat[1].exp,5)
  HEAD pr.person_id
   IF (((pl_cnt=0) OR (locateval(ml_loc,1,size(m_rec->pat[1].exp,5),pr.person_id,m_rec->pat[1].exp[
    ml_loc].f_prsnl_id)=0)) )
    pl_cnt += 1
    IF (pl_cnt=1)
     m_rec->pat[1].f_person_id = e.encntr_id, m_rec->pat[1].s_pat_name_last = trim(p.name_last,3),
     m_rec->pat[1].s_pat_name_first = trim(p.name_first,3),
     m_rec->pat[1].s_fin = ms_fin, m_rec->pat[1].s_mrn = trim(ea.alias,3), m_rec->pat[1].
     s_unit_room_bed = concat(trim(uar_get_code_display(e.loc_nurse_unit_cd),3),"/",trim(
       uar_get_code_display(e.loc_room_cd),3),trim(uar_get_code_display(e.loc_bed_cd),3)),
     m_rec->pat[1].s_reg_dt_tm = trim(format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec->pat[1].
     s_disch_dt_tm = trim(format(e.disch_dt_tm,"mm/dd/yy hh:mm;;d"),3)
    ENDIF
    CALL alterlist(m_rec->pat[1].exp,pl_cnt), m_rec->pat[1].exp[pl_cnt].f_prsnl_id = pr.person_id,
    m_rec->pat[1].exp[pl_cnt].s_prsnl_name_last = trim(pr.name_last,3),
    m_rec->pat[1].exp[pl_cnt].s_prsnl_name_first = trim(pr.name_first,3), m_rec->pat[1].exp[pl_cnt].
    s_prsnl_reltn = concat("Surg Attendee:",trim(uar_get_code_display(ca.role_perf_cd),3)), m_rec->
    pat[1].exp[pl_cnt].s_emp_num = trim(pr.username,3)
   ELSE
    ml_idx = locateval(ml_loc,1,size(m_rec->pat[1].exp,5),pr.person_id,m_rec->pat[1].exp[ml_loc].
     f_prsnl_id)
    IF (ml_idx > 0)
     m_rec->pat[1].exp[ml_idx].s_prsnl_reltn = concat(m_rec->pat[1].exp[ml_idx].s_prsnl_reltn,
      "; Surg Attendee:",trim(uar_get_code_display(ca.role_perf_cd),3))
    ENDIF
   ENDIF
  WITH uar_code(d)
 ;end select
 SET ms_tmp = value( $OUTDEV)
 IF (ms_tmp != "*json*")
  CALL echo("output to mine")
  SELECT INTO value( $OUTDEV)
   patient_name_last = substring(1,50,m_rec->pat[1].s_pat_name_last), patient_name_first = substring(
    1,50,m_rec->pat[1].s_pat_name_first), fin = substring(1,50,m_rec->pat[1].s_fin),
   mrn = substring(1,50,m_rec->pat[1].s_mrn), unit_room_bed = substring(1,50,m_rec->pat[1].
    s_unit_room_bed), exposure_start_date = ms_beg_dt_tm,
   exposure_end_date = ms_end_dt_tm, reg_dt_tm = m_rec->pat[1].s_reg_dt_tm, staff_name_last =
   substring(1,50,m_rec->pat[1].exp[d.seq].s_prsnl_name_last),
   staff_name_first = substring(1,50,m_rec->pat[1].exp[d.seq].s_prsnl_name_first), staff_reltn =
   substring(1,50,m_rec->pat[1].exp[d.seq].s_prsnl_reltn), staff_en = substring(1,10,m_rec->pat[1].
    exp[d.seq].s_emp_num),
   document_name = substring(1,75,m_rec->pat[1].exp[d.seq].s_document_name), document_type =
   substring(1,75,m_rec->pat[1].exp[d.seq].s_document_type), document_folder = substring(1,75,m_rec->
    pat[1].exp[d.seq].s_document_folder)
   FROM (dummyt d  WITH seq = value(size(m_rec->pat[1].exp,5)))
   PLAN (d)
   ORDER BY staff_name_last, staff_name_first
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ELSE
  CALL echo("set json")
  SET _memory_reply_string = cnvtrectojson(m_rec)
  CALL echo(_memory_reply_string)
 ENDIF
#exit_script
 FREE RECORD m_rec
END GO
