CREATE PROGRAM bhs_rpt_portal_sender_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Select Assigned Group" = value(8330555.00),
  "Create File" = 0,
  "Date Range" = "",
  "Enter Emails" = "",
  "summary" = 0
  WITH outdev, s_start_date, s_end_date,
  f_assign_grp, f_file, s_range,
  s_emails, summary
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
     2 s_msg_subject = vc
     2 s_msg_from_per = vc
     2 s_msg_from_pool = vc
     2 s_msg_to_prsnl = vc
     2 s_msg_to_pool = vc
     2 m_asterick1 = i4
     2 s_taskdate = vc
     2 m_message_removed = i4
     2 s_task_type = vc
     2 f_enctrid = f8
     2 s_update_dt_tm = vc
     2 s_message = vc
     2 f_message_id = f8
     2 m_msg_length = i4
     2 f_encntr_id = f8
     2 s_location = vc
 ) WITH protect
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_cs19189_poolgroup = f8 WITH constant(uar_get_code_by("DISPLAYKEY",19189,"POOLGROUP")),
 protect
 DECLARE mf_cs2026_phonemsg = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6026,"PHONEMSG")),
 protect
 DECLARE pl_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_start_date = vc WITH noconstant(format(cnvtdatetime(cnvtdate2( $S_START_DATE,
     "DD-MMM-YYYY"),0),"DD-MMM-YYYY hh:mm:ss;;Q")), protect
 DECLARE ms_end_date = vc WITH noconstant(format(cnvtdatetime(cnvtdate2( $S_END_DATE,"DD-MMM-YYYY"),
    235959),"DD-MMM-YYYY hh:mm:ss;;Q")), protect
 DECLARE inbuffer = vc
 DECLARE inbuflen = i4
 DECLARE outbuffer = c1000 WITH noconstant("")
 DECLARE outbuflen = i4 WITH noconstant(100)
 DECLARE retbuflen = i4 WITH noconstant(0)
 DECLARE bflag = i4 WITH noconstant(0)
 DECLARE no_rtfblob = c32000
 DECLARE lout = i4
 DECLARE stat = i4
 SELECT INTO "nl:"
  FROM task_activity ta,
   task_activity ta1,
   task_activity_assignment taa,
   prsnl_group pg,
   prsnl pr,
   prsnl pr1,
   prsnl_group pg1,
   encounter e
  PLAN (ta
   WHERE ta.active_ind=1
    AND ta.task_create_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
    AND ta.msg_sender_id=22146075)
   JOIN (ta1
   WHERE ta1.conversation_id=ta.conversation_id
    AND ta1.task_type_cd=mf_cs2026_phonemsg)
   JOIN (taa
   WHERE taa.task_id=ta1.task_id
    AND taa.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=ta1.msg_sender_id)
   JOIN (pg
   WHERE pg.prsnl_group_id=ta1.msg_sender_prsnl_group_id)
   JOIN (pr1
   WHERE pr1.person_id=taa.assign_prsnl_id)
   JOIN (pg1
   WHERE pg1.prsnl_group_id=taa.assign_prsnl_group_id)
   JOIN (e
   WHERE (e.encntr_id= Outerjoin(ta.encntr_id))
    AND (e.encntr_id> Outerjoin(0)) )
  ORDER BY ta.conversation_id, ta1.task_id, ta1.task_create_dt_tm
  DETAIL
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->conv,5))
    CALL alterlist(m_rec->conv,(pl_cnt+ 50))
   ENDIF
   m_rec->conv[pl_cnt].f_conversation_id = ta.task_id, m_rec->conv[pl_cnt].f_conversation_id = ta
   .conversation_id, m_rec->conv[pl_cnt].s_taskdate = trim(format(ta1.task_create_dt_tm,
     "mm/dd/yy hh:mm:ss;;d"),3),
   m_rec->conv[pl_cnt].s_msg_from_per = trim(pr.name_full_formatted,3)
   IF (pg.prsnl_group_id > 0)
    m_rec->conv[pl_cnt].s_msg_from_pool = trim(pg.prsnl_group_name,3)
   ENDIF
   m_rec->conv[pl_cnt].s_msg_subject = trim(ta1.msg_subject,3), m_rec->conv[pl_cnt].s_msg_to_prsnl =
   trim(pr1.name_full_formatted,3)
   IF (pg1.prsnl_group_id > 0)
    m_rec->conv[pl_cnt].s_msg_to_pool = pg1.prsnl_group_name
   ENDIF
   m_rec->conv[pl_cnt].s_task_type = trim(uar_get_code_display(ta1.task_type_cd),3), m_rec->conv[
   pl_cnt].f_message_id = taa.msg_text_id, m_rec->conv[pl_cnt].f_enctrid = ta.encntr_id,
   m_rec->conv[pl_cnt].s_location = concat(trim(uar_get_code_display(e.loc_facility_cd,3)))
  FOOT REPORT
   CALL alterlist(m_rec->conv,pl_cnt), m_rec->total_messages = pl_cnt
  WITH nccounter, maxrec = 100000, time = 3200
 ;end select
 DECLARE ms_tmp = vc WITH protect
 DECLARE ml_attloc = i4 WITH protect
 DECLARE ml_num = i4 WITH protect
 DECLARE ml_loc = i4 WITH protect
 DECLARE ml_numres = i4 WITH protect
 SELECT INTO "nl:"
  FROM long_text lt
  WHERE expand(ml_num,1,size(m_rec->conv,5),lt.long_text_id,m_rec->conv[ml_num].f_message_id)
  HEAD lt.long_text_id
   ml_attloc = 0, ml_attloc = locateval(ml_numres,1,size(m_rec->conv,5),lt.long_text_id,m_rec->conv[
    ml_numres].f_message_id)
   IF (ml_attloc != 0)
    inbuffer = lt.long_text, inbuflen = size(inbuffer), stat = uar_rtf2(inbuffer,textlen(inbuffer),
     no_rtfblob,size(no_rtfblob),retbuflen,
     1),
    no_rtf = replace(replace(trim(substring(1,retbuflen,no_rtfblob),3),char(10),""),char(13),""),
    m_rec->conv[ml_attloc].m_msg_length = textlen(no_rtf), m_rec->conv[ml_attloc].s_message = trim(
     no_rtf,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO  $OUTDEV
  conversation_id = m_rec->conv[d1.seq].f_conversation_id, task_id = m_rec->conv[d1.seq].f_taskid,
  task_date = substring(1,30,m_rec->conv[d1.seq].s_taskdate),
  message_from_pool = substring(1,100,m_rec->conv[d1.seq].s_msg_from_pool), message_from_person =
  substring(1,100,m_rec->conv[d1.seq].s_msg_from_per), messsage_subject = substring(1,200,m_rec->
   conv[d1.seq].s_msg_subject),
  message_to_pool = substring(1,30,m_rec->conv[d1.seq].s_msg_to_pool), message_to_personnel =
  substring(1,100,m_rec->conv[d1.seq].s_msg_to_prsnl), message = substring(1,2000,m_rec->conv[d1.seq]
   .s_message),
  encounter_location = substring(1,100,m_rec->conv[d1.seq].s_location)
  FROM (dummyt d1  WITH seq = size(m_rec->conv,5))
  PLAN (d1)
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
