CREATE PROGRAM bhs_rpt_portal_msg_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD m_rec
 RECORD m_rec(
   1 conv[*]
     2 f_conversation_id = f8
     2 s_msg_subject1 = vc
     2 s_msg_subject2 = vc
     2 m_asterick1 = ml
     2 m_asterick2 = ml
     2 m_msgchange = vc
     2 msg[*]
       3 f_from_id = f8
       3 s_from = vc
       3 f_to_id = f8
       3 s_to = vc
       3 f_to_group_id = f8
       3 s_to_group = vc
       3 s_sent_dt_tm = vc
       3 s_pat_name = vc
       3 s_pat_cmrn = vc
       3 s_msg_subject = vc
       3 s_msg_type = vc
 ) WITH protect
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 CALL echo(build2("mf_CMRN_CD: ",mf_cmrn_cd))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 CALL echo("get outbound")
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   task_activity ta
  PLAN (taa
   WHERE taa.assign_prsnl_id=22146075
    AND taa.beg_eff_dt_tm BETWEEN cnvtdatetime("19-MAR-2024 00:00") AND cnvtdatetime(
    "24-apr-2024 23:59")
    AND taa.active_ind=1)
   JOIN (ta
   WHERE ta.task_id=taa.task_id
    AND ta.active_ind=1
    AND ta.conversation_id > 0.0
    AND cnvtupper(ta.msg_subject)="*MYHEALTH - APPOINTMENT*")
  ORDER BY ta.conversation_id
  HEAD REPORT
   pl_cnt = 0
  HEAD ta.conversation_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->conv,5))
    CALL alterlist(m_rec->conv,(pl_cnt+ 50))
   ENDIF
   m_rec->conv[pl_cnt].f_conversation_id = ta.conversation_id, m_rec->conv[pl_cnt].s_msg_subject1 =
   ta.msg_subject
   IF (findstring(nopatring("*MYHEALTH"),cnvtupper(ta.msg_subject)) > 0)
    m_rec->conv[pl_cnt].m_asterick1 = 1
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->conv,pl_cnt)
  WITH format(date,"mm/dd/yy hh:mm:ss;;d"), uar_code("D")
 ;end select
 CALL echo("get inbound")
 SELECT INTO "nl:"
  FROM task_activity ta
  PLAN (ta
   WHERE ta.msg_sender_id=22146075
    AND ta.active_ind=1
    AND ta.task_create_dt_tm BETWEEN cnvtdatetime("19-MAR-2024 00:00") AND cnvtdatetime(
    "24-apr-2024 23:59")
    AND  NOT (expand(ml_exp,1,size(m_rec->conv,5),ta.conversation_id,m_rec->conv[ml_exp].
    f_conversation_id))
    AND ta.conversation_id > 0.0)
  ORDER BY ta.conversation_id
  HEAD REPORT
   pl_cnt = size(m_rec->conv,5)
  HEAD ta.conversation_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->conv,5))
    CALL alterlist(m_rec->conv,(pl_cnt+ 50))
   ENDIF
   m_rec->conv[pl_cnt].f_conversation_id = ta.conversation_id, m_rec->conv[pl_cnt].s_msg_subject2 =
   ta.msg_subject
  FOOT REPORT
   CALL alterlist(m_rec->conv,pl_cnt)
  WITH nocounter, expand = 1
 ;end select
 CALL echo("get all by conv id")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->conv,5))),
   task_activity ta,
   task_activity_assignment taa,
   prsnl pr1,
   prsnl pr2,
   person p,
   person_alias pa,
   prsnl_group pg
  PLAN (d)
   JOIN (ta
   WHERE (ta.conversation_id=m_rec->conv[d.seq].f_conversation_id)
    AND ta.active_ind=1)
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND taa.active_ind=1)
   JOIN (pr1
   WHERE pr1.person_id=ta.msg_sender_id)
   JOIN (pr2
   WHERE pr2.person_id=taa.assign_prsnl_id)
   JOIN (p
   WHERE p.person_id=ta.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cmrn_cd)
   JOIN (pg
   WHERE (pg.prsnl_group_id= Outerjoin(taa.assign_prsnl_group_id))
    AND (pg.prsnl_group_id!= Outerjoin(0.0)) )
  ORDER BY ta.conversation_id, ta.task_create_dt_tm, ta.task_id
  HEAD REPORT
   pl_cnt = 0
  HEAD ta.conversation_id
   pl_cnt = 0
  HEAD ta.task_id
   pl_cnt += 1,
   CALL alterlist(m_rec->conv[d.seq].msg,pl_cnt), m_rec->conv[d.seq].msg[pl_cnt].f_from_id = ta
   .msg_sender_id,
   m_rec->conv[d.seq].msg[pl_cnt].s_from = trim(pr1.name_full_formatted,3), m_rec->conv[d.seq].msg[
   pl_cnt].f_to_id = taa.assign_prsnl_id, m_rec->conv[d.seq].msg[pl_cnt].s_to = trim(pr2
    .name_full_formatted,3),
   m_rec->conv[d.seq].msg[pl_cnt].f_to_group_id = taa.assign_prsnl_group_id, m_rec->conv[d.seq].msg[
   pl_cnt].s_to_group = trim(pg.prsnl_group_name,3), m_rec->conv[d.seq].msg[pl_cnt].s_sent_dt_tm =
   trim(format(ta.task_create_dt_tm,"mm/dd/yy hh:mm;;d"),3),
   m_rec->conv[d.seq].msg[pl_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->conv[d.seq].msg[
   pl_cnt].s_pat_cmrn = trim(pa.alias,3), m_rec->conv[d.seq].msg[pl_cnt].s_msg_subject = trim(ta
    .msg_subject,3),
   m_rec->conv[d.seq].msg[pl_cnt].s_msg_type = trim(uar_get_code_display(ta.msg_subject_cd),3)
   IF (findstring(nopatring("*MYHEALTH"),cnvtupper(ta.msg_subject)) > 0)
    m_rec->conv[d.seq].m_asterick2 = 1
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 CALL echo("output")
 SELECT INTO value( $OUTDEV)
  conversation_id = m_rec->conv[d1.seq].f_conversation_id, msg_from = substring(1,50,m_rec->conv[d1
   .seq].msg[d2.seq].s_from), msg_to = substring(1,50,m_rec->conv[d1.seq].msg[d2.seq].s_to),
  msg_to_group = substring(1,50,m_rec->conv[d1.seq].msg[d2.seq].s_to_group), sent = m_rec->conv[d1
  .seq].msg[d2.seq].s_sent_dt_tm, patient_name = substring(1,75,m_rec->conv[d1.seq].msg[d2.seq].
   s_pat_name),
  cmrn = substring(1,25,m_rec->conv[d1.seq].msg[d2.seq].s_pat_cmrn), subject = substring(1,255,m_rec
   ->conv[d1.seq].msg[d2.seq].s_msg_subject), subjectto = substring(1,255,m_rec->conv[d1.seq].
   s_msg_subject1),
  subjectfrom = substring(1,255,m_rec->conv[d1.seq].s_msg_subject2), subjectfrom = m_rec->conv[d1.seq
  ].m_asterick1, subjectfrom = m_rec->conv[d1.seq].m_asterick2
  FROM (dummyt d1  WITH seq = value(size(m_rec->conv,5))),
   dummyt d2
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->conv[d1.seq].msg,5)))
   JOIN (d2)
  ORDER BY d1.seq, d2.seq
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
