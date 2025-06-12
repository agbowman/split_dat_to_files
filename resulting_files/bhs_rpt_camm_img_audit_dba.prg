CREATE PROGRAM bhs_rpt_camm_img_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Report by number of:" = "NOTE",
  "Begin Date:" = "SYSDATE",
  "End Date:" = "SYSDATE",
  "Email:" = ""
  WITH outdev, s_report_by, s_beg_dt_tm,
  s_end_dt_tm, s_email
 FREE RECORD m_rec
 RECORD m_rec(
   1 note[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_unit = vc
     2 s_med_svc = vc
     2 f_prsnl_id = f8
     2 s_prsnl_userid = vc
     2 s_prsnl_name = vc
     2 s_prsnl_pos = vc
     2 f_attach_prsnl_id = f8
     2 s_attach_prsnl_userid = vc
     2 s_attach_prsnl_name = vc
     2 s_attach_prsnl_pos = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 f_attach_event_id = f8
     2 f_attach_event_cd = f8
     2 s_attach_event_disp = vc
     2 f_note_event_id = f8
     2 s_note_event_title_text = vc
     2 s_note_event_end_dt_tm = vc
     2 s_note_type = vc
     2 l_attach_cnt = i4
     2 s_content_type = vc
 ) WITH protect
 DECLARE ms_report_by = vc WITH protect, constant(trim(cnvtupper( $S_REPORT_BY),3))
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(trim( $S_BEG_DT_TM,3))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(trim( $S_END_DT_TM,3))
 DECLARE ms_email = vc WITH protect, constant(trim( $S_EMAIL,3))
 DECLARE mf_attach_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"ATTACHMENT"))
 DECLARE mf_doc_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE mf_mdoc_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"MDOC"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE ml_row_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_attach_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_email_file = vc WITH protect, noconstant(" ")
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM clinical_event ce1,
   clinical_event ce2,
   dms_media_identifier dmid,
   dms_media_instance dmi,
   dms_content_type dct,
   encounter e,
   encntr_alias ea1,
   encntr_alias ea2,
   prsnl pr,
   prsnl pr2
  PLAN (ce1
   WHERE ce1.clinsig_updt_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ce1.event_class_cd=mf_attach_cls_cd
    AND ce1.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
    AND ce1.valid_until_dt_tm > sysdate)
   JOIN (ce2
   WHERE ce2.event_id=ce1.parent_event_id
    AND ce2.event_class_cd IN (mf_doc_cls_cd, mf_mdoc_cls_cd)
    AND ce2.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
    AND ce2.valid_until_dt_tm > sysdate)
   JOIN (e
   WHERE e.encntr_id=ce1.encntr_id)
   JOIN (dmid
   WHERE dmid.media_object_identifier=substring(1,findstring("}",ce1.reference_nbr,1),ce1
    .reference_nbr))
   JOIN (dmi
   WHERE dmi.dms_media_identifier_id=dmid.dms_media_identifier_id)
   JOIN (dct
   WHERE dct.dms_content_type_id=dmi.dms_content_type_id
    AND dct.content_type_key IN ("BHRIMG", "GNRIMG", "MEDIMG"))
   JOIN (ea1
   WHERE ea1.encntr_id=ce1.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=ce1.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_alias_type_cd=mf_mrn_cd)
   JOIN (pr
   WHERE pr.person_id=outerjoin(dmi.created_by_id))
   JOIN (pr2
   WHERE pr2.person_id=ce1.performed_prsnl_id)
  ORDER BY ce1.parent_event_id, ce1.event_id
  HEAD REPORT
   ml_row_cnt = 0
  HEAD ce1.parent_event_id
   ml_attach_cnt = 0,
   CALL echo(ce2.event_title_text)
  HEAD ce1.event_id
   ml_idx = 0
   IF (ms_report_by="NOTE"
    AND ml_row_cnt > 0)
    ml_idx = locateval(ml_loc,1,ml_row_cnt,ce2.parent_event_id,m_rec->note[ml_loc].f_note_event_id)
    IF (ml_idx > 0)
     ml_attach_cnt = (ml_attach_cnt+ 1), m_rec->note[ml_idx].l_attach_cnt = ml_attach_cnt
    ENDIF
   ENDIF
   IF (((ms_report_by="IMAGE") OR (ml_idx=0)) )
    ml_row_cnt = (ml_row_cnt+ 1), stat = alterlist(m_rec->note,ml_row_cnt), ml_attach_cnt = (
    ml_attach_cnt+ 1),
    ml_idx = locateval(ml_loc,1,ml_row_cnt,ce2.parent_event_id,m_rec->note[ml_loc].f_note_event_id)
    WHILE (ml_idx > 0)
     m_rec->note[ml_idx].l_attach_cnt = ml_attach_cnt,
     IF (ml_idx < ml_row_cnt)
      ml_idx = locateval(ml_loc,(ml_idx+ 1),ml_row_cnt,ce2.parent_event_id,m_rec->note[ml_loc].
       f_note_event_id)
     ENDIF
    ENDWHILE
    m_rec->note[ml_row_cnt].f_encntr_id = ce1.encntr_id, m_rec->note[ml_row_cnt].f_person_id = ce1
    .person_id, m_rec->note[ml_row_cnt].s_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3),
    m_rec->note[ml_row_cnt].s_med_svc = trim(uar_get_code_display(e.med_service_cd),3), m_rec->note[
    ml_row_cnt].f_prsnl_id = dmi.created_by_id, m_rec->note[ml_row_cnt].s_prsnl_name = trim(pr
     .name_full_formatted,3),
    m_rec->note[ml_row_cnt].s_prsnl_userid = trim(pr.username,3), m_rec->note[ml_row_cnt].s_prsnl_pos
     = trim(uar_get_code_display(pr.position_cd),3), m_rec->note[ml_row_cnt].f_attach_event_id = ce1
    .event_id,
    m_rec->note[ml_row_cnt].f_attach_event_cd = ce1.event_cd, m_rec->note[ml_row_cnt].
    s_attach_event_disp = trim(uar_get_code_display(ce1.event_cd)), m_rec->note[ml_row_cnt].
    f_note_event_id = ce2.event_id,
    m_rec->note[ml_row_cnt].s_note_event_title_text = trim(ce2.event_title_text,3), m_rec->note[
    ml_row_cnt].s_note_event_end_dt_tm = trim(format(ce2.event_end_dt_tm,"mm/dd/yy hh:mm;;d")), m_rec
    ->note[ml_row_cnt].s_fin = trim(ea1.alias,3),
    m_rec->note[ml_row_cnt].s_mrn = trim(ea2.alias,3), m_rec->note[ml_row_cnt].l_attach_cnt =
    ml_attach_cnt, m_rec->note[ml_row_cnt].s_content_type = trim(dct.content_type_key),
    m_rec->note[ml_row_cnt].f_attach_prsnl_id = pr2.person_id, m_rec->note[ml_row_cnt].
    s_attach_prsnl_userid = trim(pr2.username,3), m_rec->note[ml_row_cnt].s_attach_prsnl_name = trim(
     pr2.name_full_formatted,3),
    m_rec->note[ml_row_cnt].s_attach_prsnl_pos = trim(uar_get_code_display(pr2.position_cd),3)
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_row_cnt > 0)
  IF (textlen(ms_email) > 0
   AND findstring("@",ms_email,1) > 0)
   SET ms_email_file = concat("bhs_rpt_camm_audit",trim(format(sysdate,"mmddyyhhmmss;;d")),".csv")
   CALL echo(ms_email_file)
   SELECT INTO value(ms_email_file)
    FROM (dummyt d  WITH seq = value(size(m_rec->note,5)))
    ORDER BY d.seq
    HEAD REPORT
     ms_tmp = concat(
      '"Encounter_ID","Person_ID","FIN","MRN","Unit","Med Service","Attachment_Event_ID",',
      '"Attachment_Event_Disp","Attachment_Event_CD","Note_Title_Text","Note_Dt_Tm","Attachment_Count",',
      '"Attach UserId","Attach User Name","Attach Position","UserId","User Name","Position"')
     IF (ms_report_by="IMAGE")
      ms_tmp = concat(ms_tmp,',"Content_Type"')
     ENDIF
     col 0, row 0, ms_tmp
    DETAIL
     ms_tmp = concat('"',trim(cnvtstring(m_rec->note[d.seq].f_encntr_id)),'",','"',trim(cnvtstring(
        m_rec->note[d.seq].f_person_id)),
      '",','"',m_rec->note[d.seq].s_fin,'",','"',
      m_rec->note[d.seq].s_mrn,'",','"',m_rec->note[d.seq].s_unit,'",',
      '"',m_rec->note[d.seq].s_med_svc,'",','"',trim(cnvtstring(m_rec->note[d.seq].f_attach_event_id)
       ),
      '",','"',m_rec->note[d.seq].s_attach_event_disp,'",','"',
      trim(cnvtstring(m_rec->note[d.seq].f_attach_event_cd)),'",','"',m_rec->note[d.seq].
      s_note_event_title_text,'",',
      '"',m_rec->note[d.seq].s_note_event_end_dt_tm,'",','"',trim(cnvtstring(m_rec->note[d.seq].
        l_attach_cnt)),
      '",','"',m_rec->note[d.seq].s_attach_prsnl_userid,'",','"',
      m_rec->note[d.seq].s_attach_prsnl_name,'",','"',m_rec->note[d.seq].s_attach_prsnl_pos,'",',
      '"',m_rec->note[d.seq].s_prsnl_userid,'",','"',m_rec->note[d.seq].s_prsnl_name,
      '",','"',m_rec->note[d.seq].s_prsnl_pos,'"')
     IF (ms_report_by="IMAGE")
      ms_tmp = concat(ms_tmp,',"',m_rec->note[d.seq].s_content_type,'"')
     ENDIF
     col 0, row + 1, ms_tmp
    WITH nocounter, maxrow = 1, maxcol = 500
   ;end select
   EXECUTE bhs_ma_email_file
   CALL emailfile(ms_email_file,ms_email_file,ms_email,concat("CAMM Audit ",ms_beg_dt_tm," - ",
     ms_end_dt_tm),1)
  ENDIF
  IF (ms_report_by="NOTE")
   SELECT INTO value( $OUTDEV)
    encounter_id = m_rec->note[d.seq].f_encntr_id, person_id = m_rec->note[d.seq].f_person_id,
    fin_nbr = substring(1,20,m_rec->note[d.seq].s_fin),
    mrn = substring(1,20,m_rec->note[d.seq].s_mrn), unit = substring(1,40,m_rec->note[d.seq].s_unit),
    med_service = substring(1,50,m_rec->note[d.seq].s_med_svc),
    attachment_event_id = m_rec->note[d.seq].f_attach_event_id, attachment_event_disp = substring(1,
     25,m_rec->note[d.seq].s_attach_event_disp), attachment_event_cd = m_rec->note[d.seq].
    f_attach_event_cd,
    note_title_text = substring(1,50,m_rec->note[d.seq].s_note_event_title_text), note_dt_tm = m_rec
    ->note[d.seq].s_note_event_end_dt_tm, attachment_count = m_rec->note[d.seq].l_attach_cnt,
    attach_prsnl_userid = m_rec->note[d.seq].s_attach_prsnl_userid, attach_prsnl_name = substring(1,
     50,m_rec->note[d.seq].s_attach_prsnl_name), attach_prsnl_position = substring(1,20,m_rec->note[d
     .seq].s_attach_prsnl_pos),
    upload_prsnl_userid = m_rec->note[d.seq].s_prsnl_userid, upload_prsnl_name = substring(1,50,m_rec
     ->note[d.seq].s_prsnl_name), upload_prsnl_position = substring(1,20,m_rec->note[d.seq].
     s_prsnl_pos)
    FROM (dummyt d  WITH seq = value(size(m_rec->note,5)))
    ORDER BY d.seq
    WITH nocounter, format, separator = " "
   ;end select
  ELSEIF (ms_report_by="IMAGE")
   SELECT INTO value( $OUTDEV)
    encounter_id = m_rec->note[d.seq].f_encntr_id, person_id = m_rec->note[d.seq].f_person_id,
    fin_nbr = m_rec->note[d.seq].s_fin,
    mrn = m_rec->note[d.seq].s_mrn, attachment_event_id = m_rec->note[d.seq].f_attach_event_id,
    attachment_event_disp = m_rec->note[d.seq].s_attach_event_disp,
    attachment_event_cd = m_rec->note[d.seq].f_attach_event_cd, note_title_text = m_rec->note[d.seq].
    s_note_event_title_text, note_dt_tm = m_rec->note[d.seq].s_note_event_end_dt_tm,
    attachment_count = m_rec->note[d.seq].l_attach_cnt, content_type = m_rec->note[d.seq].
    s_content_type, attach_prsnl_userid = m_rec->note[d.seq].s_attach_prsnl_userid,
    attach_prsnl_name = m_rec->note[d.seq].s_attach_prsnl_name, attach_prsnl_position = m_rec->note[d
    .seq].s_attach_prsnl_pos, upload_prsnl_userid = m_rec->note[d.seq].s_prsnl_userid,
    upload_prsnl_name = m_rec->note[d.seq].s_prsnl_name, upload_prsnl_position = m_rec->note[d.seq].
    s_prsnl_pos
    FROM (dummyt d  WITH seq = value(size(m_rec->note,5)))
    ORDER BY d.seq
    WITH nocounter, format, separator = " "
   ;end select
  ENDIF
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    CALL print(build2("No attachments from CAMM found on notes in date range ",ms_beg_dt_tm," to ",
     ms_end_dt_tm))
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
