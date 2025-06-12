CREATE PROGRAM bhs_rpt_inerror_document:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 RECORD m_rec(
   1 l_cnt = i4
   1 list[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_event_id = f8
     2 c_patient_name = c100
     2 c_mrn = c20
     2 c_fin = c20
     2 c_date_inerrored = c20
     2 c_reason_inerrored = c500
     2 c_inerror_user = c100
     2 c_inerror_position = c100
     2 c_document_type = c100
 )
 IF ( NOT (validate(reply->status_data.status,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mf_dyndoc = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"DYNDOC"))
 DECLARE mf_powernote = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"POWERNOTE"))
 DECLARE mf_powernoteed = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"POWERNOTEED"))
 DECLARE mf_all_document_sections_es = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "ALLDOCUMENTSECTIONS"))
 DECLARE mf_patienteducationhandout_es = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "PATIENTEDUCATIONHANDOUT"))
 DECLARE mf_patienteducationleaflets_es = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "PATIENTEDUCATIONLEAFLETS"))
 DECLARE mf_ocfcomp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop1 = i4 WITH protect, noconstant(0)
 DECLARE mn_strip_rtf_ind = i2 WITH protect, noconstant(1)
 DECLARE mc_blob_compressed_trimmed = c128000 WITH noconstant(fillstring(128000," "))
 DECLARE mc_blob_uncompressed = c128000 WITH noconstant(fillstring(128000," "))
 DECLARE mc_blob_rtf = c128000 WITH noconstant(fillstring(128000," "))
 DECLARE mn_blob_return_len = w8 WITH noconstant(0)
 DECLARE mn_blob_return_len2 = w8 WITH noconstant(0)
 DECLARE mc_ps_blob_out = c128000 WITH noconstant(fillstring(128000," "))
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_out = vc WITH protect, noconstant(" ")
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 IF (( $OUTDEV="OPS"))
  SET ms_beg_dt_tm = format(cnvtdatetime((curdate - 1),0),"DD-MMM-YYYY HH:mm:ss;;D")
  SET ms_end_dt_tm = format(cnvtdatetime(curdate,0),"DD-MMM-YYYY HH:mm:ss;;D")
  SET mn_email_ind = 1
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtlookbehind("1 D",
      cnvtdatetime(ms_end_dt_tm)),"YYYYMMDD;;D"),".csv"))
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="BHS_RPT_INERROR_DOCUMENT"
     AND di.info_char="EMAIL")
   HEAD REPORT
    ms_address_list = " "
   DETAIL
    IF (ms_address_list=" ")
     ms_address_list = trim(di.info_name)
    ELSE
     ms_address_list = concat(ms_address_list," ",trim(di.info_name))
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET ms_beg_dt_tm = concat( $S_BEG_DT," 00:00:00")
  SET ms_end_dt_tm = format(cnvtlookahead("1 D",cnvtdatetime(concat( $S_END_DT," 00:00:00"))),
   "DD-MMM-YYYY HH:mm:ss;;D")
  IF (findstring("@", $OUTDEV) > 0)
   SET mn_email_ind = 1
   SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtlookbehind("1 D",
       cnvtdatetime(ms_end_dt_tm)),"YYYYMMDD;;D"),".csv"))
   SET ms_address_list =  $OUTDEV
  ELSEIF (cnvtupper( $OUTDEV)="EMAIL")
   SET mn_email_ind = 1
   SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtlookbehind("1 D",
       cnvtdatetime(ms_end_dt_tm)),"YYYYMMDD;;D"),".csv"))
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="BHS_RPT_INERROR_DOCUMENT"
      AND di.info_char="EMAIL")
    HEAD REPORT
     ms_address_list = " "
    DETAIL
     IF (ms_address_list=" ")
      ms_address_list = trim(di.info_name)
     ELSE
      ms_address_list = concat(ms_address_list," ",trim(di.info_name))
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SET mn_email_ind = 0
   SET ms_output_dest =  $OUTDEV
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   v500_event_set_explode vese,
   encounter e,
   person p,
   encntr_alias fin,
   encntr_alias mrn,
   prsnl pr,
   dummyt dlb,
   ce_event_note cen,
   long_blob lb,
   dummyt d1,
   clinical_event ce2
  PLAN (ce
   WHERE ce.clinsig_updt_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND ce.clinsig_updt_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ce.view_level=1
    AND ce.entry_mode_cd IN (mf_dyndoc, mf_powernote, mf_powernoteed)
    AND ce.result_status_cd=mf_inerror_cd)
   JOIN (vese
   WHERE vese.event_cd=ce.event_cd
    AND vese.event_set_cd=mf_all_document_sections_es
    AND  NOT ( EXISTS (
   (SELECT
    vese.event_cd
    FROM v500_event_set_explode vese0
    WHERE vese0.event_cd=vese.event_cd
     AND vese0.event_set_cd IN (mf_patienteducationhandout_es, mf_patienteducationleaflets_es)))))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=mf_fin_cd
    AND fin.active_ind=1
    AND fin.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.encntr_alias_type_cd=mf_mrn_cd
    AND mrn.active_ind=1
    AND mrn.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pr
   WHERE pr.person_id=ce.verified_prsnl_id)
   JOIN (dlb)
   JOIN (cen
   WHERE cen.event_id=ce.event_id)
   JOIN (lb
   WHERE lb.parent_entity_id=cen.ce_event_note_id
    AND lb.parent_entity_name="CE_EVENT_NOTE")
   JOIN (d1)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce.parent_event_id
    AND ce2.view_level=1
    AND ce2.result_status_cd != mf_inerror_cd
    AND ce2.verified_prsnl_id=ce.verified_prsnl_id)
  ORDER BY p.name_full_formatted, ce.performed_dt_tm
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt += 1, m_rec->l_cnt = ml_cnt, stat = alterlist(m_rec->list,ml_cnt),
   m_rec->list[ml_cnt].f_encntr_id = ce.encntr_id, m_rec->list[ml_cnt].f_person_id = ce.person_id,
   m_rec->list[ml_cnt].f_event_id = ce.event_id,
   m_rec->list[ml_cnt].c_patient_name = trim(p.name_full_formatted,3), m_rec->list[ml_cnt].c_mrn =
   mrn.alias, m_rec->list[ml_cnt].c_fin = fin.alias,
   m_rec->list[ml_cnt].c_date_inerrored = format(ce.clinsig_updt_dt_tm,"mm/dd/yy HH:mm;;D")
   IF (cen.compression_cd != mf_ocfcomp_cd
    AND findstring("ocf_blob",lb.long_blob))
    m_rec->list[ml_cnt].c_reason_inerrored = trim(replace(replace(replace(lb.long_blob,"ocf_blob"," "
        ),char(10)," "),char(13)," "),3)
   ELSE
    mc_blob_compressed_trimmed = fillstring(128000," "), mc_blob_uncompressed = fillstring(128000," "
     ), mc_blob_rtf = fillstring(128000," "),
    mc_blob_compressed_trimmed = trim(lb.long_blob), mn_blob_return_len = 0, mn_blob_return_len2 = 0,
    mc_ps_blob_out = fillstring(128000," ")
    IF (cen.compression_cd=mf_ocfcomp_cd)
     CALL uar_ocf_uncompress(mc_blob_compressed_trimmed,size(mc_blob_compressed_trimmed),
     mc_blob_uncompressed,size(mc_blob_uncompressed),mn_blob_return_len), mc_ps_blob_out =
     mc_blob_uncompressed,
     CALL uar_rtf2(mc_blob_uncompressed,mn_blob_return_len,mc_blob_rtf,size(mc_blob_rtf),
     mn_blob_return_len2,1),
     mc_ps_blob_out = trim(mc_blob_rtf,3), m_rec->list[ml_cnt].c_reason_inerrored = trim(replace(
       replace(mc_ps_blob_out,char(10)," "),char(13)," "),3)
    ENDIF
   ENDIF
   m_rec->list[ml_cnt].c_inerror_user = trim(pr.name_full_formatted,3), m_rec->list[ml_cnt].
   c_inerror_position = trim(uar_get_code_display(pr.position_cd),3), m_rec->list[ml_cnt].
   c_document_type =
   IF (ce.event_title_text > " ") concat(trim(uar_get_code_display(ce.event_cd),3)," (",trim(ce
      .event_title_text,3),")")
   ELSE uar_get_code_display(ce.event_cd)
   ENDIF
  WITH outerjoin = dlb, dontcare = cen, dontcare = lb,
   outerjoin = d1, dontexist, nocounter
 ;end select
 IF (ml_cnt < 1)
  SELECT
   IF (mn_email_ind=1)
    WITH format = stream, pcformat('"',",",1), nocounter
   ELSE
   ENDIF
   INTO value(ms_output_dest)
   no_data = "No In Errored Documents Found"
   FROM dummyt d
   WITH format, separator = " ", nocounter
  ;end select
  SET ms_subject = concat(
   "Documents InErrored by Non-Author Audit for - No In Errored Documents Found ",format(
    cnvtlookbehind("1 D",cnvtdatetime(ms_end_dt_tm)),"mm/dd/yyyy;;D"))
  GO TO exit_script
 ENDIF
 SET ms_subject = concat("Documents InErrored by Non-Author Audit for ",format(cnvtlookbehind("1 D",
    cnvtdatetime(ms_end_dt_tm)),"mm/dd/yyyy;;D"))
 SELECT
  IF (mn_email_ind=1)
   WITH format, format = stream, pcformat('"',",",1),
    nocounter
  ELSE
  ENDIF
  DISTINCT INTO value(ms_output_dest)
  patient_name = trim(m_rec->list[d.seq].c_patient_name,3), mrn = trim(m_rec->list[d.seq].c_mrn,3),
  fin = trim(m_rec->list[d.seq].c_fin,3),
  date_inerrored = trim(m_rec->list[d.seq].c_date_inerrored,3), reason_inerrored = trim(m_rec->list[d
   .seq].c_reason_inerrored,3), inerror_user = trim(m_rec->list[d.seq].c_inerror_user,3),
  inerror_user_position = trim(m_rec->list[d.seq].c_inerror_position,3), document_type = trim(m_rec->
   list[d.seq].c_document_type,3)
  FROM (dummyt d  WITH seq = m_rec->l_cnt)
  WITH format, separator = " ", nocounter
 ;end select
#exit_script
 IF (mn_email_ind=1)
  EXECUTE bhs_ma_email_file
  SET ms_filename_out = concat("Documents_InErrored_by_NonAuthor_",format(cnvtlookbehind("1 D",
     cnvtdatetime(ms_end_dt_tm)),"YYYYMMDD;;D"),".csv")
  CALL emailfile(ms_output_dest,ms_filename_out,ms_address_list,ms_subject,1)
 ENDIF
END GO
