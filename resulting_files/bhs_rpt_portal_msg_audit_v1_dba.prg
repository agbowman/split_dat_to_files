CREATE PROGRAM bhs_rpt_portal_msg_audit_v1:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Assigned Group" = value(8330555.00,21728436.00,16531229.00,25382816.00),
  "Check for Summary" = 0
  WITH outdev, f_assign_grp, summary
 FREE RECORD m_rec
 RECORD m_rec(
   1 m_pcp_removed = i4
   1 m_pcp_only = i4
   1 m_pcp_priority = i4
   1 m_pcp_priority_add = i4
   1 total_messages = i4
   1 conv[*]
     2 f_conversation_id = f8
     2 f_taskid = f8
     2 s_msg_subject1 = vc
     2 s_msg_subject2 = vc
     2 s_message_from = vc
     2 s_message_to = vc
     2 m_asterick1 = i4
     2 s_taskdate = vc
     2 m_message_removed = i4
     2 m_asterick2 = i4
     2 m_msgchange = vc
     2 f_enctrid = f8
     2 msg[*]
       3 f_from_id = f8
       3 s_from = vc
       3 f_to_id = f8
       3 s_to = vc
       3 f_to_group_id = f8
       3 s_to_group = vc
       3 f_to_groupid = f8
       3 s_sent_dt_tm = vc
       3 s_pat_name = vc
       3 s_pat_cmrn = vc
       3 s_msg_subject = vc
       3 s_msg_type = vc
 ) WITH protect
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_cs19189_poolgroup = f8 WITH constant(uar_get_code_by("DISPLAYKEY",19189,"POOLGROUP")),
 protect
 DECLARE pl_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  ta.conversation_id, ta.task_id, ta1.task_id,
  ta.encntr_id, ta.msg_subject, ta1.msg_subject,
  pr.name_full_formatted, ta.msg_sender_prsnl_group_id, pg1.prsnl_group_name,
  taa.assign_prsnl_group_id, ta1.msg_sender_prsnl_group_id
  FROM task_activity ta,
   task_activity_assignment taa,
   prsnl_group pg,
   prsnl pr,
   prsnl_group pg1,
   task_activity ta1
  PLAN (ta
   WHERE ta.active_ind=1
    AND ta.task_create_dt_tm BETWEEN cnvtdatetime("01-SEP-2024 00:00:00") AND cnvtdatetime(
    "04-SEP-2024 23:59:59"))
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND taa.active_ind=1
    AND (taa.assign_prsnl_group_id= $F_ASSIGN_GRP))
   JOIN (pg
   WHERE pg.prsnl_group_id=ta.msg_sender_prsnl_group_id)
   JOIN (pr
   WHERE pr.person_id=ta.msg_sender_id)
   JOIN (pg1
   WHERE pg1.prsnl_group_id=taa.assign_prsnl_group_id)
   JOIN (ta1
   WHERE ta1.conversation_id=ta.conversation_id
    AND ta1.task_id != ta.task_id)
  ORDER BY ta.conversation_id, ta.task_id, ta1.task_id
  DETAIL
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->conv,5))
    CALL alterlist(m_rec->conv,(pl_cnt+ 50))
   ENDIF
   m_rec->conv[pl_cnt].f_conversation_id = ta.conversation_id, m_rec->conv[pl_cnt].s_msg_subject1 =
   trim(ta.msg_subject,3), m_rec->conv[pl_cnt].s_msg_subject2 = trim(ta1.msg_subject,3),
   m_rec->conv[pl_cnt].s_taskdate = trim(format(ta.task_create_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec->
   conv[pl_cnt].s_message_from = trim(pr.name_full_formatted,3), m_rec->conv[pl_cnt].s_message_to =
   trim(pg1.prsnl_group_name,3),
   m_rec->total_messages += 1
   IF (findstring(nopatstring("*MYHEALTH"),cnvtupper(ta1.msg_subject)) > 0)
    m_rec->conv[pl_cnt].m_asterick2 = 1, m_rec->m_pcp_priority += 1
    IF ((m_rec->conv[pl_cnt].m_asterick1=0))
     m_rec->m_pcp_priority_add += 1
    ENDIF
   ELSE
    m_rec->m_pcp_only += 1
    IF ((m_rec->conv[pl_cnt].m_asterick1=1))
     m_rec->m_pcp_removed += 1, m_rec->conv[pl_cnt].m_message_removed = 1
    ENDIF
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->conv,pl_cnt), m_rec->total_messages = pl_cnt
  WITH nccounter, maxrec = 100, time = 180
 ;end select
 IF (( $SUMMARY=0))
  SELECT INTO  $OUTDEV
   conversation_id = m_rec->conv[d1.seq].f_conversation_id, taskdate = substring(1,30,m_rec->conv[d1
    .seq].s_taskdate), message_from = substring(1,200,m_rec->conv[d1.seq].s_message_from),
   msg_subject_from = substring(1,200,m_rec->conv[d1.seq].s_msg_subject1), message_to = substring(1,
    200,m_rec->conv[d1.seq].s_message_to), msg_subject_from = substring(1,200,m_rec->conv[d1.seq].
    s_msg_subject2)
   FROM (dummyt d1  WITH seq = size(m_rec->conv,5))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   total_priority_messages = m_rec->m_pcp_priority, total_non_priority_messages = m_rec->m_pcp_only,
   total_priority_removed = m_rec->m_pcp_removed,
   totak_priority_added = m_rec->m_pcp_priority_add, total_messages = m_rec->total_messages
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
