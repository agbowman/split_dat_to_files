CREATE PROGRAM bhs_ma_rpt_pool_msg:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Msg Start Date:" = "CURDATE",
  "Msg End Date:" = "CURDATE",
  "Msg Pool:" = 10426582.00
  WITH outdev, s_start_dt, s_end_dt,
  f_msg_pool
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_prev_task_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_prev_task_time_diff = f8 WITH protect, noconstant(0.0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_conversation_id = f8
     2 s_msg_pool = vc
     2 f_task_id = f8
     2 s_sender = vc
     2 s_subject = vc
     2 s_msg_type = vc
     2 s_create_dt = vc
     2 s_msg_status = vc
     2 f_msg_status_cd = f8
     2 s_patient = vc
     2 s_fin = vc
     2 f_inbox_time = f8
     2 f_prev_msg_time = f8
     2 l_tcnt = i4
     2 tqual[*]
       3 f_task_activity_assign_id = f8
       3 f_task_activity_assign_msg_h_id = f8
       3 s_action_status = vc
       3 s_action_status_prsnl = vc
       3 s_action_dt_tm = vc
       3 l_updt_cnt = i4
 ) WITH protect
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   task_activity ta,
   task_activity_assign_msg_h taamh,
   prsnl p1,
   prsnl p2,
   encntr_alias ea,
   person p,
   prsnl_group pg
  PLAN (taa
   WHERE (taa.assign_prsnl_group_id= $F_MSG_POOL)
    AND taa.beg_eff_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND taa.active_ind=1)
   JOIN (ta
   WHERE ta.task_id=taa.task_id)
   JOIN (taamh
   WHERE taamh.task_activity_assign_id=taa.task_activity_assign_id
    AND taamh.task_id=taa.task_id
    AND taamh.active_ind=1)
   JOIN (p1
   WHERE p1.person_id=taamh.updt_id)
   JOIN (p2
   WHERE (p2.person_id= Outerjoin(ta.msg_sender_id)) )
   JOIN (p
   WHERE (p.person_id= Outerjoin(ta.person_id))
    AND (p.active_ind= Outerjoin(1)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(ta.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_cs319_fin_cd)) )
   JOIN (pg
   WHERE pg.prsnl_group_id=taa.assign_prsnl_group_id)
  ORDER BY ta.conversation_id, taa.task_id, taa.task_activity_assign_id,
   taamh.task_activity_assign_msg_h_id
  HEAD ta.conversation_id
   null
  HEAD taa.task_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_conversation_id = ta.conversation_id,
   m_rec->qual[m_rec->l_cnt].s_msg_pool = trim(pg.prsnl_group_name,3), m_rec->qual[m_rec->l_cnt].
   f_task_id = ta.task_id, m_rec->qual[m_rec->l_cnt].s_create_dt = format(ta.task_create_dt_tm,
    "MM/DD/YYYY HH:mm;;q"),
   m_rec->qual[m_rec->l_cnt].s_sender = trim(p2.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].
   s_subject = trim(ta.msg_subject,3), m_rec->qual[m_rec->l_cnt].s_msg_type = trim(
    uar_get_code_display(ta.task_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_msg_status = trim(uar_get_code_display(taa.task_status_cd),3), m_rec->
   qual[m_rec->l_cnt].f_msg_status_cd = taa.task_status_cd, m_rec->qual[m_rec->l_cnt].s_patient =
   trim(p.name_full_formatted,3),
   m_rec->qual[m_rec->l_cnt].s_fin = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].f_inbox_time =
   datetimediff(taa.updt_dt_tm,taa.beg_eff_dt_tm,3)
  HEAD taa.task_activity_assign_id
   null
  HEAD taamh.task_activity_assign_msg_h_id
   m_rec->qual[m_rec->l_cnt].l_tcnt += 1, stat = alterlist(m_rec->qual[m_rec->l_cnt].tqual,m_rec->
    qual[m_rec->l_cnt].l_tcnt), m_rec->qual[m_rec->l_cnt].tqual[m_rec->qual[m_rec->l_cnt].l_tcnt].
   f_task_activity_assign_id = taamh.task_activity_assign_id,
   m_rec->qual[m_rec->l_cnt].tqual[m_rec->qual[m_rec->l_cnt].l_tcnt].f_task_activity_assign_msg_h_id
    = taamh.task_activity_assign_msg_h_id, m_rec->qual[m_rec->l_cnt].tqual[m_rec->qual[m_rec->l_cnt].
   l_tcnt].s_action_dt_tm = format(taamh.updt_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->qual[m_rec->l_cnt]
   .tqual[m_rec->qual[m_rec->l_cnt].l_tcnt].s_action_status = trim(uar_get_code_display(taamh
     .task_status_cd),3),
   m_rec->qual[m_rec->l_cnt].tqual[m_rec->qual[m_rec->l_cnt].l_tcnt].s_action_status_prsnl = trim(p1
    .name_full_formatted,3), m_rec->qual[m_rec->l_cnt].tqual[m_rec->qual[m_rec->l_cnt].l_tcnt].
   l_updt_cnt = taamh.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl;"
  FROM task_activity ta
  PLAN (ta
   WHERE expand(ml_idx1,1,m_rec->l_cnt,ta.conversation_id,m_rec->qual[ml_idx1].f_conversation_id)
    AND ta.conversation_id > 0
    AND ta.active_ind=1)
  ORDER BY ta.conversation_id, ta.task_id
  HEAD ta.conversation_id
   mf_prev_task_dt = 0.0
  HEAD ta.task_id
   mf_prev_task_time_diff = 0
   IF (mf_prev_task_dt > 0)
    mf_prev_task_time_diff = datetimediff(ta.task_create_dt_tm,cnvtdatetime(mf_prev_task_dt),3),
    ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,ta.task_id,m_rec->qual[ml_idx1].f_task_id)
    IF (ml_idx2 > 0)
     m_rec->qual[ml_idx2].f_prev_msg_time = mf_prev_task_time_diff
    ENDIF
    mf_prev_task_dt = ta.task_create_dt_tm
   ELSE
    mf_prev_task_dt = ta.task_create_dt_tm
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO  $OUTDEV
  conversation_id = m_rec->qual[d1.seq].f_conversation_id, msg_id = m_rec->qual[d1.seq].f_task_id,
  msg_pool = trim(substring(1,100,m_rec->qual[d1.seq].s_msg_pool),3),
  patient = trim(substring(1,100,m_rec->qual[d1.seq].s_patient),3), fin = trim(substring(1,100,m_rec
    ->qual[d1.seq].s_fin),3), msg_sender = trim(substring(1,100,m_rec->qual[d1.seq].s_sender),3),
  msg_subject = trim(substring(1,200,m_rec->qual[d1.seq].s_subject),3), msg_type = trim(substring(1,
    50,m_rec->qual[d1.seq].s_msg_type),3), msg_create_dt = trim(substring(1,20,m_rec->qual[d1.seq].
    s_create_dt),3),
  msg_current_status = trim(substring(1,50,m_rec->qual[d1.seq].s_msg_status),3), inbox_msg_time =
  m_rec->qual[d1.seq].f_inbox_time, prev_msg_time = m_rec->qual[d1.seq].f_prev_msg_time,
  msg_action_dt = trim(substring(1,20,m_rec->qual[d1.seq].tqual[d2.seq].s_action_dt_tm),3),
  msg_action_personnel = trim(substring(1,100,m_rec->qual[d1.seq].tqual[d2.seq].s_action_status_prsnl
    ),3), msg_personnel_aciton = trim(substring(1,50,m_rec->qual[d1.seq].tqual[d2.seq].
    s_action_status),3)
  FROM (dummyt d1  WITH seq = m_rec->l_cnt),
   dummyt d2
  PLAN (d1
   WHERE maxrec(d2,m_rec->qual[d1.seq].l_tcnt))
   JOIN (d2)
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
