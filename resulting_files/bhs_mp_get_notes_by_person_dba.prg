CREATE PROGRAM bhs_mp_get_notes_by_person:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person ID" = 0,
  "Note Type" = "",
  "Beg Date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, f_person_id, s_note_type,
  s_beg_dt_tm, s_end_dt_tm
 FREE RECORD m_rec
 RECORD m_rec(
   1 note[*]
     2 f_encntr_id = f8
     2 s_fin = vc
     2 s_title = vc
     2 f_event_id = f8
     2 f_par_event_id = f8
     2 s_sign_dt_tm = vc
     2 s_signed_by = vc
     2 s_perf_by_phys = vc
     2 s_location = vc
     2 s_nurse_unit = vc
     2 s_url = vc
     2 n_onbase = i2
     2 s_note_path = vc
     2 n_mdoc = i2
     2 s_encounter_type = vc
   1 ntypes[*]
     2 s_note_type = vc
   1 ntypes_sort[*]
     2 s_note_type = vc
 ) WITH protect
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PERSON_ID))
 DECLARE ms_note_type = vc WITH protect, constant(trim( $S_NOTE_TYPE,3))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_story_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",15750,"SIGNED"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE mf_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE mf_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE mf_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE mf_rad_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"RADIOLOGY"))
 DECLARE mf_inpt_typ_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_outp_typ_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OUTPATIENT")
  )
 DECLARE mf_inpt_class_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",321,"INPATIENT"))
 DECLARE mf_outpt_class_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",321,"OUTPATIENT")
  )
 DECLARE mf_store_url_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",25,"STORAGEURL"))
 DECLARE mf_adv_dir_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADVANCEDIRECTIVES"))
 DECLARE mf_roi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELEASEOFPATIENTINFORMATION"))
 CALL echo(build2("mf_RAD_CD: ",mf_rad_cd))
 CALL echo(build2("mf_INPT_CLASS_CD: ",mf_inpt_class_cd))
 CALL echo(build2("mf_OUTPT_CLASS_CD: ",mf_outpt_class_cd))
 CALL echo(build2("mf_INPT_TYP_CLS_CD: ",mf_inpt_typ_cls_cd))
 CALL echo(build2("mf_OUTP_TYP_CLS_CD: ",mf_outp_typ_cls_cd))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(trim( $S_BEG_DT_TM))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(trim( $S_END_DT_TM))
 DECLARE mf_hc_proxy_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_note_parse = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 IF (trim(ms_beg_dt_tm) <= " ")
  SET ms_beg_dt_tm = concat(trim(format(cnvtlookbehind("14,D",sysdate),"dd-mmm-yyyy;;d"))," 00:00:00"
   )
  SET ms_end_dt_tm = concat(trim(format(sysdate,"dd-mmm-yyyy;;d"))," 23:59:59")
 ELSE
  SET ms_beg_dt_tm = concat(ms_beg_dt_tm," 00:00:00")
  SET ms_end_dt_tm = concat(ms_end_dt_tm," 23:59:59")
 ENDIF
 CALL echo(concat("beg date: ",ms_beg_dt_tm))
 CALL echo(concat("end date: ",ms_end_dt_tm))
 IF (mf_person_id=0.0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=72
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display_key="HEALTHCAREPROXY"
   AND cv.display="Healthcare Proxy"
   AND cv.data_status_cd=25
  HEAD cv.code_value
   mf_hc_proxy_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL echo("set the parse string for source type")
 CALL echo(build2("ms_NOTE_TYPE: ",ms_note_type))
 IF (cnvtupper(ms_note_type)="ALL")
  SET ms_note_parse = " ce.event_cd  > 0"
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=72
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.display=ms_note_type
   HEAD REPORT
    pl_cnt = 0, ms_note_parse = " ce.event_cd in ("
   DETAIL
    CALL echo(build2("cv.display: ",cv.display)), pl_cnt += 1
    IF (pl_cnt > 1)
     ms_note_parse = concat(ms_note_parse,",")
    ENDIF
    ms_note_parse = concat(ms_note_parse,trim(cnvtstring(cv.code_value),3))
   FOOT REPORT
    ms_note_parse = concat(ms_note_parse,")")
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ms_note_parse = " ce.event_cd > 0"
  ENDIF
 ENDIF
 CALL echo(build2("ms_note_parse: ",ms_note_parse))
 CALL echo("select notes")
 SELECT INTO "nl:"
  FROM encounter e,
   clinical_event ce,
   encntr_loc_hist elh,
   prsnl p,
   ce_blob_result cbr,
   encntr_alias ea
  PLAN (e
   WHERE e.person_id=mf_person_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND e.end_effective_dt_tm > cnvtdatetime(ms_beg_dt_tm)
    AND ((e.encntr_class_cd IN (mf_inpt_class_cd, mf_outpt_class_cd)) OR (e.encntr_type_class_cd IN (
   mf_inpt_typ_cls_cd, mf_outp_typ_cls_cd))) )
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.performed_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ce.view_level=1
    AND ce.event_class_cd IN (mf_doc_cd, mf_mdoc_cd, mf_rad_cd)
    AND parser(ms_note_parse))
   JOIN (elh
   WHERE elh.encntr_id=ce.encntr_id
    AND elh.active_ind=1
    AND ((ce.performed_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm) OR (ce
   .performed_dt_tm > e.disch_dt_tm)) )
   JOIN (p
   WHERE p.person_id=ce.performed_prsnl_id)
   JOIN (ea
   WHERE ea.encntr_id=elh.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (cbr
   WHERE (cbr.event_id= Outerjoin(ce.event_id)) )
  ORDER BY e.beg_effective_dt_tm DESC, ce.performed_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD ce.event_id
   pl_cnt += 1, stat = alterlist(m_rec->note,pl_cnt), m_rec->note[pl_cnt].f_event_id = ce.event_id,
   m_rec->note[pl_cnt].f_encntr_id = e.encntr_id, m_rec->note[pl_cnt].s_fin = trim(ea.alias), m_rec->
   note[pl_cnt].s_sign_dt_tm = trim(format(ce.performed_dt_tm,"mm/dd/yy hh:mm;;d")),
   m_rec->note[pl_cnt].s_signed_by = trim(p.name_full_formatted), m_rec->note[pl_cnt].s_perf_by_phys
    = trim(cnvtstring(p.physician_ind),3)
   IF (textlen(trim(ce.event_title_text)) > 0)
    m_rec->note[pl_cnt].s_title = ce.event_title_text
   ELSE
    m_rec->note[pl_cnt].s_title = trim(uar_get_code_display(ce.event_cd))
   ENDIF
   m_rec->note[pl_cnt].s_location = concat(trim(uar_get_code_display(elh.loc_facility_cd))," - ",trim
    (uar_get_code_display(elh.loc_nurse_unit_cd))), m_rec->note[pl_cnt].s_nurse_unit = trim(
    uar_get_code_display(elh.loc_nurse_unit_cd))
   IF (ce.event_class_cd=mf_mdoc_cd)
    m_rec->note[pl_cnt].n_mdoc = 1
   ENDIF
   IF (((e.encntr_class_cd=mf_inpt_class_cd) OR (e.encntr_type_class_cd=mf_inpt_typ_cls_cd)) )
    m_rec->note[pl_cnt].s_encounter_type = "INPATIENT"
   ELSEIF (((e.encntr_class_cd=mf_outpt_class_cd) OR (e.encntr_type_class_cd=mf_outp_typ_cls_cd)) )
    m_rec->note[pl_cnt].s_encounter_type = "OUTPATIENT"
   ENDIF
   IF (cbr.storage_cd=mf_store_url_cd)
    m_rec->note[pl_cnt].s_url = trim(cbr.blob_handle), m_rec->note[pl_cnt].n_onbase = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (size(m_rec->note,5)=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ps_event_disp = trim(uar_get_code_display(ce.event_cd),3)
  FROM encounter e,
   clinical_event ce,
   encntr_loc_hist elh
  PLAN (e
   WHERE e.person_id=mf_person_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND e.end_effective_dt_tm > cnvtdatetime(ms_beg_dt_tm)
    AND ((e.encntr_class_cd IN (mf_inpt_class_cd, mf_outpt_class_cd)) OR (e.encntr_type_class_cd IN (
   mf_inpt_typ_cls_cd, mf_outp_typ_cls_cd))) )
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.performed_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ce.view_level=1
    AND ce.event_class_cd IN (mf_doc_cd, mf_mdoc_cd, mf_rad_cd))
   JOIN (elh
   WHERE elh.encntr_id=ce.encntr_id
    AND elh.active_ind=1
    AND ((ce.performed_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm) OR (ce
   .performed_dt_tm > e.disch_dt_tm)) )
  ORDER BY ps_event_disp, ce.event_cd
  HEAD REPORT
   pl_cnt = 0
  HEAD ce.event_cd
   ml_idx = size(m_rec->ntypes,5)
   IF (((ml_idx=0) OR (locateval(ml_loc,1,size(m_rec->ntypes,5),trim(uar_get_code_display(ce.event_cd
      ),3),m_rec->ntypes[ml_loc].s_note_type)=0)) )
    ml_idx += 1,
    CALL alterlist(m_rec->ntypes,ml_idx), m_rec->ntypes[ml_idx].s_note_type = trim(
     uar_get_code_display(ce.event_cd),3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->note,5))),
   clinical_event ce,
   ce_blob_result cbr
  PLAN (d
   WHERE (m_rec->note[d.seq].n_mdoc=1)
    AND (m_rec->note[d.seq].n_onbase=0))
   JOIN (ce
   WHERE (ce.parent_event_id=m_rec->note[d.seq].f_event_id))
   JOIN (cbr
   WHERE cbr.event_id=ce.event_id
    AND cbr.storage_cd=mf_store_url_cd
    AND cbr.valid_until_dt_tm > sysdate)
  ORDER BY d.seq
  HEAD d.seq
   m_rec->note[d.seq].n_onbase = 1, m_rec->note[d.seq].s_url = trim(cbr.blob_handle)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ps_path = concat(trim(vcode3.event_set_cd_descr)," - ",trim(vcode2.event_set_cd_descr)," - ",trim(
    vcode1.event_cd_descr),
   " - ",ce.event_title_text)
  FROM (dummyt d  WITH seq = value(size(m_rec->note,5))),
   clinical_event ce,
   v500_event_code vcode1,
   v500_event_set_explode vex,
   v500_event_set_canon vcan1,
   v500_event_set_code vcode2,
   v500_event_set_canon vcan2,
   v500_event_set_code vcode3
  PLAN (d)
   JOIN (ce
   WHERE (ce.event_id=m_rec->note[d.seq].f_event_id))
   JOIN (vcode1
   WHERE vcode1.event_cd=ce.event_cd)
   JOIN (vex
   WHERE vex.event_cd=vcode1.event_cd)
   JOIN (vcan1
   WHERE vcan1.event_set_cd=vex.event_set_cd)
   JOIN (vcode2
   WHERE vcode2.event_set_cd=vcan1.parent_event_set_cd)
   JOIN (vcan2
   WHERE vcan2.event_set_cd=vcode2.event_set_cd)
   JOIN (vcode3
   WHERE vcode3.event_set_cd=vcan2.parent_event_set_cd)
  ORDER BY d.seq, vex.event_set_level, vcan1.event_set_collating_seq,
   vcan2.event_set_collating_seq
  HEAD ce.event_id
   m_rec->note[d.seq].s_note_path = ps_path
  WITH nocounter
 ;end select
#exit_script
 SET _memory_reply_string = cnvtrectojson(m_rec)
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
