CREATE PROGRAM bhs_rpt_portal_msgs_to_cis:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Recipient Type:" = "pool",
  "Email to:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_recipient_type, s_email
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_tot_msg_cnt = i4
   1 recip[*]
     2 f_recip_id = f8
     2 s_recip = vc
     2 s_recip_type = vc
     2 l_msg_cnt = i4
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE ms_recip_type = vc WITH protect, constant(trim(cnvtlower( $S_RECIPIENT_TYPE),3))
 DECLARE ms_filename = vc WITH protect, constant(concat("portal_to_pool_msg_counts_",trim(format(
     sysdate,"mmddyyhhmm;;d"),3),".csv"))
 DECLARE ms_email = vc WITH protect, constant(trim(cnvtlower( $S_EMAIL),3))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 EXECUTE bhs_ma_email_file
 IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
  SET ms_log = "Both dates must be filled out"
  GO TO exit_script
 ENDIF
 IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
  SET ms_log = "End date must be greater than Beg date"
  GO TO exit_script
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 IF (textlen(trim(ms_email,3)) > 0
  AND findstring("@bhs.org",ms_email)=0
  AND findstring("@baystatehealth.org",ms_email)=0)
  SET ms_log = "Invalid email, must be a bhs.org or baystatehealth.org email address"
  GO TO exit_script
 ENDIF
 CALL echo("get msgs into CIS from Portal")
 IF (ms_recip_type IN ("pool", "all"))
  SELECT INTO "nl:"
   FROM task_activity ta,
    task_activity_assignment taa,
    prsnl_group pg
   PLAN (ta
    WHERE ta.msg_sender_id=22146075
     AND ta.active_ind=1
     AND ta.task_create_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
    JOIN (taa
    WHERE taa.task_id=ta.task_id
     AND taa.active_ind=1
     AND taa.assign_prsnl_group_id > 0.0)
    JOIN (pg
    WHERE pg.prsnl_group_id=taa.assign_prsnl_group_id)
   ORDER BY taa.assign_prsnl_group_id, ta.task_id
   HEAD REPORT
    pl_cnt = 0
   HEAD taa.assign_prsnl_group_id
    pl_cnt += 1
    IF (pl_cnt > size(m_rec->recip,5))
     CALL alterlist(m_rec->recip,(pl_cnt+ 50))
    ENDIF
    m_rec->recip[pl_cnt].f_recip_id = taa.assign_prsnl_group_id, m_rec->recip[pl_cnt].s_recip = trim(
     pg.prsnl_group_name,3), m_rec->recip[pl_cnt].s_recip_type = "Pool"
   HEAD ta.task_id
    m_rec->l_tot_msg_cnt += 1, m_rec->recip[pl_cnt].l_msg_cnt += 1
   FOOT REPORT
    CALL alterlist(m_rec->recip,pl_cnt)
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (ms_recip_type IN ("prsnl", "all"))
  SELECT INTO "nl:"
   FROM task_activity ta,
    task_activity_assignment taa,
    prsnl pr
   PLAN (ta
    WHERE ta.msg_sender_id=22146075
     AND ta.active_ind=1
     AND ta.task_create_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
    JOIN (taa
    WHERE taa.task_id=ta.task_id
     AND taa.active_ind=1
     AND taa.assign_prsnl_id > 0.0)
    JOIN (pr
    WHERE pr.person_id=taa.assign_prsnl_id)
   ORDER BY taa.assign_prsnl_id, ta.task_id
   HEAD REPORT
    pl_cnt = size(m_rec->recip,5)
   HEAD taa.assign_prsnl_id
    pl_cnt += 1
    IF (pl_cnt > size(m_rec->recip,5))
     CALL alterlist(m_rec->recip,(pl_cnt+ 50))
    ENDIF
    m_rec->recip[pl_cnt].f_recip_id = taa.assign_prsnl_id, m_rec->recip[pl_cnt].s_recip = trim(pr
     .name_full_formatted,3), m_rec->recip[pl_cnt].s_recip_type = "Prsnl"
   HEAD ta.task_id
    m_rec->l_tot_msg_cnt += 1, m_rec->recip[pl_cnt].l_msg_cnt += 1
   FOOT REPORT
    CALL alterlist(m_rec->recip,pl_cnt)
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (textlen(trim(ms_email,3)) > 0)
  CALL echo(build2("ms_FILENAME: ",ms_filename))
  IF (size(m_rec->recip,5))
   SET frec->file_name = ms_filename
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET ms_tmp = concat(
    '"TOTAL_MSG_COUNT","BEG_DT_TM","END_DT_TM","RECIPIENT_ID","RECIPIENT","RECIPIENT_TYPE",',
    '"RECIPIENTMSG_COUNT"')
   SET frec->file_buf = concat(ms_tmp,char(13),char(10))
   SET stat = cclio("WRITE",frec)
   FOR (ml_loop = 1 TO size(m_rec->recip,5))
     SET ms_tmp = concat('"',trim(cnvtstring(m_rec->l_tot_msg_cnt),3),'",','"',ms_beg_dt_tm,
      '",','"',ms_end_dt_tm,'",','"',
      trim(cnvtstring(m_rec->recip[ml_loop].f_recip_id),3),'",','"',m_rec->recip[ml_loop].s_recip,
      '",',
      '"',m_rec->recip[ml_loop].s_recip_type,'",','"',trim(cnvtstring(m_rec->recip[ml_loop].l_msg_cnt
        ),3),
      '"')
     SET frec->file_buf = concat(ms_tmp,char(13),char(10))
     SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   SET ms_tmp = concat("Portal to recipient message counts.  Run date: ",format(cnvtdatetime(sysdate),
     "YYYYMMDDHHMMSS;;q"))
   CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
   SET ms_log = concat("report emailed to: ",ms_email)
  ENDIF
 ELSE
  SELECT INTO value( $OUTDEV)
   total_msg_count = substring(1,5,trim(cnvtstring(m_rec->l_tot_msg_cnt),3)), beg_dt_tm =
   ms_beg_dt_tm, end_dt_tm = ms_end_dt_tm,
   recipient_id = substring(1,10,trim(cnvtstring(m_rec->recip[d.seq].f_recip_id),3)), recipient =
   substring(1,100,m_rec->recip[d.seq].s_recip), recipient_type = substring(1,10,m_rec->recip[d.seq].
    s_recip_type),
   recipient_msg_count = substring(1,5,trim(cnvtstring(m_rec->recip[d.seq].l_msg_cnt),3))
   FROM (dummyt d  WITH seq = value(size(m_rec->recip,5)))
   ORDER BY recipient_type, recipient
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ENDIF
#exit_script
 IF (textlen(trim(ms_log,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt
   HEAD REPORT
    ms_tmp = concat("Date range: ",ms_beg_dt_tm," to ",ms_end_dt_tm), col 0, ms_tmp,
    row + 1, col 1, ms_log
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_rec
END GO
