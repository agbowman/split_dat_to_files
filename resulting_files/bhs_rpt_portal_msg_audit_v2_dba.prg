CREATE PROGRAM bhs_rpt_portal_msg_audit_v2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Select Assigned Group" = value(8330555.00,21728436.00,16531229.00,25382816.00)
  WITH outdev, s_start_date, s_end_date,
  f_assign_grp
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
     2 s_pool_name = vc
     2 s_pat_first_name = vc
     2 s_pat_last_name = vc
     2 s_cmrn = vc
     2 s_mrn = vc
     2 s_dob = vc
     2 f_msg_text_id = f8
     2 s_msg_text = vc
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
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE pl_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE inbuffer = vc
 DECLARE inbuflen = i4
 DECLARE outbuffer = c1000 WITH noconstant("")
 DECLARE outbuflen = i4 WITH noconstant(1000)
 DECLARE retbuflen = i4 WITH noconstant(0)
 DECLARE bflag = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  ta.conversation_id, ta.task_id, ta.encntr_id,
  ta.msg_subject, pr.name_full_formatted, ta.msg_sender_prsnl_group_id,
  pg1.prsnl_group_name, taa.assign_prsnl_group_id
  FROM task_activity ta,
   task_activity_assignment taa,
   prsnl_group pg,
   prsnl pr,
   prsnl_group pg1,
   person p,
   person_alias pa,
   long_text lt,
   encntr_alias ea
  PLAN (ta
   WHERE ta.active_ind=1
    AND ta.task_create_dt_tm BETWEEN cnvtdatetime( $S_START_DATE) AND cnvtdatetime( $S_END_DATE)
    AND ta.encntr_id > 0
    AND ta.person_id > 0)
   JOIN (p
   WHERE p.person_id=ta.person_id)
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(ta.msg_text_id)) )
   JOIN (pa
   WHERE pa.person_id=ta.person_id
    AND pa.person_alias_type_cd=mf_cmrn_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(ta.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_mrn_cd))
    AND (ea.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
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
  ORDER BY p.name_full_formatted, ta.person_id
  HEAD p.person_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->conv,5))
    CALL alterlist(m_rec->conv,(pl_cnt+ 50))
   ENDIF
   m_rec->conv[pl_cnt].f_conversation_id = ta.conversation_id, m_rec->conv[pl_cnt].s_msg_subject1 =
   trim(ta.msg_subject,3), m_rec->conv[pl_cnt].s_taskdate = trim(format(ta.task_create_dt_tm,
     "mm/dd/yy hh:mm;;d"),3),
   m_rec->conv[pl_cnt].s_message_from = trim(pr.name_full_formatted,3), m_rec->conv[pl_cnt].
   s_message_to = trim(pg1.prsnl_group_name,3), m_rec->conv[pl_cnt].s_cmrn = trim(pa.alias,3),
   m_rec->conv[pl_cnt].s_dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),
    "mm/dd/yyyy;;d"), m_rec->conv[pl_cnt].s_mrn = trim(ea.alias,3), m_rec->conv[pl_cnt].f_msg_text_id
    = ta.msg_text_id,
   m_rec->conv[pl_cnt].s_pat_first_name = trim(p.name_first,3), m_rec->conv[pl_cnt].s_pat_last_name
    = trim(p.name_last,3), m_rec->total_messages += 1
  FOOT REPORT
   CALL alterlist(m_rec->conv,pl_cnt), m_rec->total_messages = pl_cnt
  WITH nccounter, time = 800
 ;end select
 SELECT INTO  $OUTDEV
  taskdate = substring(1,30,m_rec->conv[d1.seq].s_taskdate), msg_subject_from = substring(1,200,m_rec
   ->conv[d1.seq].s_msg_subject1), message_to_pool = substring(1,200,m_rec->conv[d1.seq].s_message_to
   ),
  patient_first_name = substring(1,30,m_rec->conv[d1.seq].s_pat_first_name), patient_last_name =
  substring(1,30,m_rec->conv[d1.seq].s_pat_last_name), cmrn = substring(1,30,m_rec->conv[d1.seq].
   s_cmrn),
  mrn = substring(1,30,m_rec->conv[d1.seq].s_mrn), dob = substring(1,30,m_rec->conv[d1.seq].s_dob)
  FROM (dummyt d1  WITH seq = size(m_rec->conv,5))
  PLAN (d1)
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
