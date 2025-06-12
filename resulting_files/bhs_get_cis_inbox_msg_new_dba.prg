CREATE PROGRAM bhs_get_cis_inbox_msg_new:dba
 PROMPT
  "Inbox ID:" = "",
  "Beg Date Time" = "SYSDATE",
  "End Date Time:" = "SYSDATE",
  "Strip RTF formatting:" = "0"
  WITH s_inbox_id, s_beg_dt_tm, s_end_dt_tm,
  s_strip_rtf
 EXECUTE bhs_hlp_ccl
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_status = vc
   1 msg[*]
     2 s_reference_id = vc
     2 f_sender_id = f8
     2 s_sender = vc
     2 f_pool_id = f8
     2 s_provider_nbr = vc
     2 f_person_id = f8
     2 s_cmrn = vc
     2 s_msg_dt_tm = vc
     2 s_msg_subject = vc
     2 s_msg_body = vc
     2 f_cis_task_id = f8
     2 f_event_id = f8
   1 phone_cd[*]
     2 f_cd = f8
     2 s_disp = vc
 ) WITH protect
 DECLARE ms_inbox_id = vc WITH protect, constant(build( $S_INBOX_ID))
 DECLARE mf_inbox_id = f8 WITH protect, constant(cnvtreal( $S_INBOX_ID))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_bhs_ext_id_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,
   "BHSEXTERNALID"))
 DECLARE mf_org_nbr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BHSORGNUMBER"))
 DECLARE mf_child_rel_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",24,"C"))
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 CALL echo(build2("mf_BHS_EXT_ID_CD: ",mf_bhs_ext_id_cd))
 CALL echo(build2("mf_ORG_NBR_CD: ",mf_org_nbr_cd))
 CALL echo(build2("mf_CHILD_REL_CD: ",mf_child_rel_cd))
 CALL echo(build2("mf_NO_COMP_CD: ",mf_no_comp_cd))
 CALL echo(build2("mf_COMP_CD: ",mf_comp_cd))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant( $S_BEG_DT_TM)
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant( $S_END_DT_TM)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop1 = i4 WITH protect, noconstant(0)
 DECLARE mf_tmp_id = f8 WITH protect, noconstant(0.0)
 DECLARE mn_strip_rtf_ind = i2 WITH protect, noconstant(1)
 DECLARE ps_blob_out = vc
 IF (substring(1,1,reflect(parameter(4,0))) > " ")
  IF (cnvtint( $S_STRIP_RTF)=0)
   SET mn_strip_rtf_ind = cnvtint( $S_STRIP_RTF)
  ENDIF
 ENDIF
 IF (isnumeric(substring(1,4,ms_beg_dt_tm)) > 0)
  CASE (cnvtint(substring(6,2,ms_beg_dt_tm)))
   OF 1:
    SET ms_tmp = "JAN"
   OF 2:
    SET ms_tmp = "FEB"
   OF 3:
    SET ms_tmp = "MAR"
   OF 4:
    SET ms_tmp = "APR"
   OF 5:
    SET ms_tmp = "MAY"
   OF 6:
    SET ms_tmp = "JUN"
   OF 7:
    SET ms_tmp = "JUL"
   OF 8:
    SET ms_tmp = "AUG"
   OF 9:
    SET ms_tmp = "SEP"
   OF 10:
    SET ms_tmp = "OCT"
   OF 11:
    SET ms_tmp = "NOV"
   OF 12:
    SET ms_tmp = "DEC"
  ENDCASE
  SET ms_beg_dt_tm = concat(substring(9,2,ms_beg_dt_tm),"-",ms_tmp,"-",substring(1,4,ms_beg_dt_tm),
   " ",substring(12,8,ms_beg_dt_tm))
  CALL echo(concat("ODBC: ",ms_tmp))
 ENDIF
 IF (isnumeric(substring(1,4,ms_end_dt_tm)) > 0)
  CASE (cnvtint(substring(6,2,ms_end_dt_tm)))
   OF 1:
    SET ms_tmp = "JAN"
   OF 2:
    SET ms_tmp = "FEB"
   OF 3:
    SET ms_tmp = "MAR"
   OF 4:
    SET ms_tmp = "APR"
   OF 5:
    SET ms_tmp = "MAY"
   OF 6:
    SET ms_tmp = "JUN"
   OF 7:
    SET ms_tmp = "JUL"
   OF 8:
    SET ms_tmp = "AUG"
   OF 9:
    SET ms_tmp = "SEP"
   OF 10:
    SET ms_tmp = "OCT"
   OF 11:
    SET ms_tmp = "NOV"
   OF 12:
    SET ms_tmp = "DEC"
  ENDCASE
  SET ms_end_dt_tm = concat(substring(9,2,ms_end_dt_tm),"-",ms_tmp,"-",substring(1,4,ms_end_dt_tm),
   " ",substring(12,8,ms_end_dt_tm))
  CALL echo(concat("ODBC: ",ms_tmp))
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.person_id=mf_inbox_id
   AND p.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SELECT INTO "nl:"
   FROM prsnl_group pg
   WHERE pg.prsnl_group_id=mf_inbox_id
    AND pg.active_ind=1
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ms_log = "Inbox ID is not valid"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (((textlen(trim(ms_beg_dt_tm))=0) OR (textlen(trim(ms_end_dt_tm))=0)) )
  SET ms_log = "Both dates must be populated"
  GO TO exit_script
 ELSEIF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  SET ms_log = "Beg Date Time is later than End Date Time"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   task_activity ta1,
   task_activity ta2,
   prsnl pr,
   long_text lt
  PLAN (taa
   WHERE taa.assign_prsnl_id=mf_inbox_id
    AND taa.beg_eff_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND taa.active_ind=1)
   JOIN (ta1
   WHERE ta1.task_id=taa.task_id
    AND ta1.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=ta1.msg_sender_id
    AND pr.active_ind=1)
   JOIN (ta2
   WHERE (ta2.task_id= Outerjoin(ta1.orig_pool_task_id)) )
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(ta1.msg_text_id)) )
  ORDER BY ta2.external_reference_number, taa.beg_eff_dt_tm
  HEAD REPORT
   pl_cnt = 0, pl_beg_pos = 0
  HEAD taa.task_id
   pl_cnt += 1, stat = alterlist(m_rec->msg,pl_cnt), m_rec->msg[pl_cnt].s_reference_id = ta2
   .external_reference_number,
   m_rec->msg[pl_cnt].f_cis_task_id = taa.task_id, m_rec->msg[pl_cnt].f_sender_id = ta1.msg_sender_id,
   m_rec->msg[pl_cnt].f_pool_id = ta1.msg_sender_prsnl_group_id,
   m_rec->msg[pl_cnt].f_person_id = ta1.person_id, m_rec->msg[pl_cnt].s_sender = trim(pr
    .name_full_formatted), m_rec->msg[pl_cnt].s_msg_dt_tm = trim(format(taa.beg_eff_dt_tm,
     "dd-mmm-yyyy hh:mm:ss;;d")),
   m_rec->msg[pl_cnt].s_msg_subject = trim(ta1.msg_subject)
   IF (ta1.event_id=0.0)
    blob_rtf = fillstring(64000," "), blob_return_len2 = 0, ps_blob_out = fillstring(64000," "),
    ps_blob_out = trim(lt.long_text)
    IF (mn_strip_rtf_ind=1)
     ms_blob_rtf = fillstring(10000," "),
     CALL uar_rtf2(ps_blob_out,textlen(ps_blob_out),blob_rtf,size(blob_rtf),blob_return_len2,1),
     ms_tmp = trim(blob_rtf)
    ELSE
     ms_tmp = trim(ps_blob_out)
    ENDIF
    m_rec->msg[pl_cnt].s_msg_body = trim(ms_tmp)
   ELSE
    m_rec->msg[pl_cnt].f_event_id = ta1.event_id
   ENDIF
  WITH nocounter
 ;end select
 IF (size(m_rec->msg,5)=0)
  CALL echo("no messages found")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=72
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.data_status_cd=mf_auth_cd
    AND cv.display_key IN ("PHONEMSG", "PATIENTLETTER", "REMINDER", "CORRESPONDENCELETTERS"))
  HEAD REPORT
   pl_cnt = 0
  HEAD cv.code_value
   pl_cnt += 1, stat = alterlist(m_rec->phone_cd,pl_cnt), m_rec->phone_cd[pl_cnt].s_disp = trim(cv
    .display_key),
   m_rec->phone_cd[pl_cnt].f_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->msg,5))),
   clinical_event ce,
   ce_blob cb
  PLAN (d
   WHERE (m_rec->msg[d.seq].f_event_id > 0.0))
   JOIN (ce
   WHERE (ce.parent_event_id=m_rec->msg[d.seq].f_event_id)
    AND expand(ml_cnt,1,size(m_rec->phone_cd,5),ce.event_cd,m_rec->phone_cd[ml_cnt].f_cd)
    AND ce.event_reltn_cd=mf_child_rel_cd
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (cb
   WHERE cb.event_id=ce.event_id
    AND cb.valid_until_dt_tm > sysdate)
  ORDER BY d.seq, ce.collating_seq DESC
  DETAIL
   CALL echo("ce_blob detail"),
   CALL echo(build2("reltn_cd: ",trim(uar_get_code_display(ce.event_reltn_cd)),ce.event_reltn_cd))
   IF (textlen(trim(cb.blob_contents)) > 0)
    IF (cb.compression_cd=mf_comp_cd)
     CALL echo("compressed"), m_rec->msg[d.seq].f_event_id = ce.event_id
    ELSEIF (cb.compression_cd=mf_no_comp_cd)
     CALL echo("not compressed"), ps_blob_out = trim(cb.blob_contents)
     IF (findstring("ocf_blob",ps_blob_out) > 0)
      ps_blob_out = replace(ps_blob_out,"ocf_blob","",0)
     ENDIF
     ms_string = trim(ps_blob_out,3),
     CALL echo(d.seq),
     CALL echo(ms_string),
     m_rec->msg[d.seq].s_msg_body = concat(m_rec->msg[d.seq].s_msg_body,char(10),ms_string)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get original ref id")
 FOR (ml_loop1 = 1 TO size(m_rec->msg,5))
  IF ((m_rec->msg[ml_loop1].f_event_id > 0)
   AND size(m_rec->msg[ml_loop1].s_msg_body) < 1)
   CALL echo(build("bhs_sbr_get_blob(",m_rec->msg[ml_loop1].f_event_id,",",mn_strip_rtf_ind,")"))
   SET m_rec->msg[ml_loop1].s_msg_body = bhs_sbr_get_blob(m_rec->msg[ml_loop1].f_event_id,
    mn_strip_rtf_ind)
   SET m_rec->msg[ml_loop1].s_msg_body = trim(m_rec->msg[ml_loop1].s_msg_body)
   CALL echo(m_rec->msg[ml_loop1].s_msg_body)
  ENDIF
  IF (textlen(m_rec->msg[ml_loop1].s_reference_id)=0)
   SET x = 0
   SET mf_tmp_id = m_rec->msg[ml_loop1].f_cis_task_id
   WHILE (mf_tmp_id > 0.0)
     SET x += 1
     SELECT INTO "nl:"
      FROM task_activity ta
      PLAN (ta
       WHERE ta.task_id=mf_tmp_id)
      HEAD ta.task_id
       mf_tmp_id = ta.orig_pool_task_id
       IF (mf_tmp_id=0.0
        AND size(trim(ta.external_reference_number)) > 0)
        m_rec->msg[ml_loop1].s_reference_id = trim(ta.external_reference_number)
       ENDIF
      WITH nocounter
     ;end select
     IF (curqual < 1)
      SET mf_tmp_id = 0.0
     ENDIF
     IF (x > 10)
      SET mf_tmp_id = 0.0
     ENDIF
   ENDWHILE
  ENDIF
 ENDFOR
 CALL echo("get the cmrn")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->msg,5))),
   person_alias pa
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_id=m_rec->msg[d.seq].f_person_id)
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cmrn_cd)
  HEAD d.seq
   m_rec->msg[d.seq].s_cmrn = format(trim(pa.alias),"#######;p0"),
   CALL echo(concat("CMRN: ",pa.alias))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted, p.person_id, pa.alias
  FROM (dummyt d  WITH seq = value(size(m_rec->msg,5))),
   prsnl_alias pa,
   prsnl p
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_id=m_rec->msg[d.seq].f_sender_id)
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.alias_pool_cd=mf_bhs_ext_id_cd)
   JOIN (p
   WHERE p.person_id=pa.person_id
    AND p.active_ind=1
    AND p.physician_ind=1)
  HEAD d.seq
   CALL echo("get provider number"), m_rec->msg[d.seq].s_provider_nbr = trim(pa.alias)
  WITH nocounter
 ;end select
 SET m_rec->s_status = "Success"
#exit_script
 IF (size(m_rec->msg,5)=0)
  SET ms_tmp = concat('[{"Status":"',m_rec->s_status,'","StatusDetail":"',ms_log,'"}]')
 ELSE
  SET ms_tmp = concat('[{"Status":"',m_rec->s_status,'","StatusDetail":"',ms_log,'","MESSAGES":[')
  FOR (ml_cnt = 1 TO size(m_rec->msg,5))
    IF (ml_cnt > 1)
     SET ms_tmp = concat(ms_tmp,",")
    ENDIF
    SET m_rec->msg[ml_cnt].s_sender = replace(m_rec->msg[ml_cnt].s_sender,"\","\\",0)
    SET m_rec->msg[ml_cnt].s_sender = replace(m_rec->msg[ml_cnt].s_sender,"/","\/",0)
    SET m_rec->msg[ml_cnt].s_msg_subject = replace(m_rec->msg[ml_cnt].s_msg_subject,"\","\\",0)
    SET m_rec->msg[ml_cnt].s_msg_subject = replace(m_rec->msg[ml_cnt].s_msg_subject,'"','\"',0)
    SET m_rec->msg[ml_cnt].s_msg_subject = replace(m_rec->msg[ml_cnt].s_msg_subject,"/","\/",0)
    SET m_rec->msg[ml_cnt].s_msg_body = replace(m_rec->msg[ml_cnt].s_msg_body,"\","\\",0)
    SET m_rec->msg[ml_cnt].s_msg_body = replace(m_rec->msg[ml_cnt].s_msg_body,'"','\"',0)
    SET m_rec->msg[ml_cnt].s_msg_body = replace(m_rec->msg[ml_cnt].s_msg_body,"/","\/",0)
    SET ms_tmp = concat(ms_tmp,"{",'"OriginalMessageID":"',m_rec->msg[ml_cnt].s_reference_id,'",',
     '"SenderID":"',trim(cnvtstring(m_rec->msg[ml_cnt].f_sender_id)),'",','"SenderName":"',m_rec->
     msg[ml_cnt].s_sender,
     '",','"PoolID":"',trim(cnvtstring(m_rec->msg[ml_cnt].f_pool_id)),'",','"ProviderNumber":"',
     m_rec->msg[ml_cnt].s_provider_nbr,'",','"PatientCMRN":"',m_rec->msg[ml_cnt].s_cmrn,'",',
     '"SendTime":"',m_rec->msg[ml_cnt].s_msg_dt_tm,'",','"Subject":"',m_rec->msg[ml_cnt].
     s_msg_subject,
     '",','"Body":"',m_rec->msg[ml_cnt].s_msg_body,'"',"}")
  ENDFOR
  SET ms_tmp = concat(ms_tmp,"]}]")
 ENDIF
 SET _memory_reply_string = ms_tmp
 CALL echo(_memory_reply_string)
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
