CREATE PROGRAM bhs_rpt_pool_ccd_match:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Pool name search:" = "",
  "Select Pool:" = 0,
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, s_pool_search_str, f_pool_grp_id,
  s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 mat[*]
     2 f_taa_id = f8
     2 f_conv_id = f8
     2 f_pat_id = f8
     2 s_pat_name = vc
     2 s_msg_sub = vc
     2 s_match_by = vc
     2 f_match_pid = f8
     2 s_match_dt_tm = vc
 ) WITH protect
 DECLARE mf_pool_id = f8 WITH protect, constant(cnvtreal( $F_POOL_GRP_ID))
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_msg = vc WITH protect, noconstant(" ")
 DECLARE ml_beg = i4 WITH protect, noconstant(0)
 DECLARE ml_end = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  ta.conversation_id, ta.task_id, lt.long_text_id,
  taa.task_activity_assign_id, lt.parent_entity_id, p.name_full_formatted,
  taa.assign_person_id, pr.name_full_formatted, taa.assign_prsnl_id,
  taa.assign_prsnl_group_id, taa.task_id, taa.task_activity_assign_id,
  ta.msg_sender_id, ta.msg_subject, ta.conversation_id
  FROM task_activity_assignment taa,
   long_text lt,
   task_activity ta,
   person p
  PLAN (taa
   WHERE taa.assign_prsnl_group_id=mf_pool_id
    AND taa.active_ind=1
    AND taa.beg_eff_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (lt
   WHERE lt.parent_entity_id=taa.task_activity_assign_id
    AND lt.parent_entity_name="TASK_ACTIVITY_ASSIGNMENT"
    AND lt.active_ind=1
    AND lt.long_text="*Patient matched by*")
   JOIN (ta
   WHERE ta.task_id=taa.task_id)
   JOIN (p
   WHERE (p.person_id= Outerjoin(ta.person_id)) )
  ORDER BY taa.task_activity_assign_id, lt.updt_dt_tm
  HEAD REPORT
   pl_cnt = 0
  HEAD taa.task_activity_assign_id
   pl_cnt += 1,
   CALL alterlist(m_rec->mat,pl_cnt), m_rec->mat[pl_cnt].f_conv_id = ta.conversation_id,
   m_rec->mat[pl_cnt].f_pat_id = ta.person_id, m_rec->mat[pl_cnt].s_pat_name = trim(p
    .name_full_formatted,3), m_rec->mat[pl_cnt].s_msg_sub = ta.msg_subject,
   m_rec->mat[pl_cnt].s_match_dt_tm = trim(format(lt.updt_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), ms_msg =
   trim(replace(lt.long_text,char(10)," "),3), ms_msg = trim(replace(ms_msg,char(13)," "),3),
   ml_beg = (findstring("Patient matched by ",ms_msg)+ 19), ml_end = findstring("on ",ms_msg,ml_beg),
   CALL echo(build2("beg: ",ml_beg," end: ",ml_end)),
   ms_tmp = substring(ml_beg,(ml_end - ml_beg),ms_msg),
   CALL echo(concat(":",ms_tmp,":")), m_rec->mat[pl_cnt].s_match_by = ms_tmp
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  match_by = m_rec->mat[d1.seq].s_match_by, match_dt_tm = m_rec->mat[d1.seq].s_match_dt_tm, patient
   = m_rec->mat[d1.seq].s_pat_name,
  msg_subject = substring(1,50,m_rec->mat[d1.seq].s_msg_sub)
  FROM (dummyt d1  WITH seq = value(size(m_rec->mat,5)))
  ORDER BY match_by
  WITH format, separator = " ", maxrow = 1
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
