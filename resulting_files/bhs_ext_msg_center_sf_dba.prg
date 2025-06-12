CREATE PROGRAM bhs_ext_msg_center_sf:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 IF (cnvtupper(trim( $OUTDEV,3)) != "OPS")
  SET mf_start_dt = cnvtdatetime(trim( $S_START_DT))
  SET mf_stop_dt = cnvtdatetime(trim( $S_STOP_DT))
 ELSEIF (cnvtupper(trim( $OUTDEV,3))="OPS")
  SET mf_stop_dt = cnvtdatetime(sysdate)
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="BHS_EXT_MSG_CENTER_SF"
     AND di.info_name="START_DT_TM")
   DETAIL
    mf_start_dt = di.info_date
   WITH nocounter
  ;end select
  IF (mf_start_dt=0)
   CALL echo("Did not find start DM_INFO row. Exiting ... ")
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo(format(cnvtdatetime(mf_start_dt),";;q"))
 CALL echo(format(cnvtdatetime(mf_stop_dt),";;q"))
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
     2 f_task_id = f8
     2 f_conversation_id = f8
     2 s_msg_dt_tm = vc
     2 s_cmrn = vc
     2 s_inbox_name = vc
     2 s_msg_type = vc
     2 s_msg_status = vc
     2 s_msg_body = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM prsnl_group pg,
   task_activity_assignment taa,
   task_activity ta,
   person_alias pa,
   long_text lt
  PLAN (pg)
   JOIN (taa
   WHERE taa.assign_prsnl_group_id=pg.prsnl_group_id)
   JOIN (ta
   WHERE ta.task_id=taa.task_id
    AND ta.updt_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt))
   JOIN (pa
   WHERE pa.person_id=ta.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
   JOIN (lt
   WHERE lt.long_text_id=taa.msg_text_id)
  ORDER BY ta.task_id, pa.beg_effective_dt_tm
  HEAD ta.task_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].f_task_id
    = ta.task_id,
   m_rec->qual[m_rec->l_cnt].s_msg_dt_tm = format(taa.beg_eff_dt_tm,"YYYY-MM-DD HH:mm:ss;;q"), m_rec
   ->qual[m_rec->l_cnt].s_msg_type = trim(uar_get_code_display(ta.task_type_cd),3), m_rec->qual[m_rec
   ->l_cnt].s_msg_status = trim(uar_get_code_display(taa.task_status_cd),3),
   m_rec->qual[m_rec->l_cnt].s_inbox_name = trim(pg.prsnl_group_name,3), m_rec->qual[m_rec->l_cnt].
   s_msg_body = trim(lt.long_text,3), m_rec->qual[m_rec->l_cnt].s_cmrn = trim(pa.alias,3),
   m_rec->qual[m_rec->l_cnt].f_conversation_id = ta.conversation_id
  WITH nocounter
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   SET frec->file_name = concat(trim(logical("bhscust"),3),"/salesforce/msg/bhs_ma_msg_center_",trim(
     cnvtstring(m_rec->qual[ml_idx1].f_task_id,20,0),3),".csv")
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = concat(m_rec->qual[ml_idx1].s_msg_status,"|",m_rec->qual[ml_idx1].s_msg_type,
    "|",trim(cnvtstring(m_rec->qual[ml_idx1].f_conversation_id,20,0),3),
    "|",trim(cnvtstring(m_rec->qual[ml_idx1].f_task_id,20,0),3),"|",m_rec->qual[ml_idx1].s_msg_dt_tm,
    "|",
    m_rec->qual[ml_idx1].s_cmrn,"|",m_rec->qual[ml_idx1].s_inbox_name,'|"',m_rec->qual[ml_idx1].
    s_msg_body,
    '"')
   SET stat = cclio("WRITE",frec)
   SET stat = cclio("CLOSE",frec)
 ENDFOR
 IF (cnvtupper(trim( $OUTDEV,3))="OPS")
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(mf_stop_dt), di.updt_dt_tm = cnvtdatetime(sysdate)
   WHERE di.info_domain="BHS_EXT_MSG_CENTER_SF"
    AND di.info_name="START_DT_TM"
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
END GO
