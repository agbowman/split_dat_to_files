CREATE PROGRAM bhs_sch_cancel_appt_inbox_msg:dba
 RECORD m_appts(
   1 l_knt = i4
   1 lst[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_sch_event_id = f8
     2 f_order_id = f8
     2 f_order_provider_id = f8
     2 f_assign_pool_id = f8
     2 f_cancel_person_id = f8
     2 d_beg_dt_tm = dq8
     2 s_appt_desc = vc
     2 s_cancel_reason = vc
     2 s_fin = vc
     2 s_msg_subject = vc
     2 s_message = vc
 ) WITH protect
 RECORD m_schcontent(
   1 l_knt = i4
   1 lst[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_order_id = f8
     2 f_sch_event_id = f8
     2 f_event_id = f8
     2 f_cancel_person_id = f8
     2 f_msg_sender_prsnl_id = f8
     2 assign_prsnl_list[*]
       3 f_assign_prsnl_id = f8
       3 n_cc_ind = i2
       3 l_selection_nbr = i4
       3 n_reply_allowed_ind = i2
     2 assign_pool_list[*]
       3 f_assign_pool_id = f8
       3 f_assign_prsnl_id = f8
       3 n_cc_ind = i2
       3 l_selection_nbr = i4
     2 s_subject = vc
     2 s_message = vc
     2 f_event_cd = f8
     2 f_task_type_cd = f8
     2 n_messagetype = i2
     2 n_save_to_chart_ind = i2
     2 l_priority = i4
     2 c_status = c1
 ) WITH protect
 RECORD m_msgcontent(
   1 f_person_id = f8
   1 f_encntr_id = f8
   1 f_order_id = f8
   1 f_event_id = f8
   1 f_msg_sender_prsnl_id = f8
   1 assign_prsnl_list[*]
     2 f_assign_prsnl_id = f8
     2 n_cc_ind = i2
     2 l_selection_nbr = i4
     2 n_reply_allowed_ind = i2
   1 assign_pool_list[*]
     2 f_assign_pool_id = f8
     2 f_assign_prsnl_id = f8
     2 n_cc_ind = i2
     2 l_selection_nbr = i4
   1 s_subject = vc
   1 s_message = vc
   1 f_event_cd = f8
   1 f_task_type_cd = f8
   1 n_messagetype = i2
   1 n_save_to_chart_ind = i2
   1 l_priority = i4
   1 c_status = c1
 ) WITH protect
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
 EXECUTE bhs_hlp_ccl
 DECLARE mf_phone_msg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"PHONE MSG"))
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_rad_cat_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"RADIOLOGY"
   ))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_ops_complete_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",460,"COMPLETE"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14233,"CANCELED"))
 DECLARE mf_hold_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14233,"HOLD"))
 DECLARE mf_noshow_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14233,"NOSHOW"))
 DECLARE mf_pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14233,"NOSHOW"))
 DECLARE mf_cancelnotifprov_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14229,
   "CANCELLATIONNOTIFICATIONTOPROVIDER"))
 DECLARE mf_phone_msg_event_cd = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "PHONEMSG"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_knt = i4 WITH protect, noconstant(0)
 DECLARE ml_oknt = i4 WITH protect, noconstant(0)
 DECLARE ml_pknt = i4 WITH protect, noconstant(0)
 DECLARE ml_aloop = i4 WITH protect, noconstant(0)
 DECLARE ml_mloop = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_dt_cncl = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_dt_noshow_hld = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 IF ((mf_phone_msg_event_cd=- (1)))
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=72
     AND cv.display_key="PHONEMSG"
     AND cv.active_ind=1)
   ORDER BY cv.begin_effective_dt_tm DESC
   HEAD REPORT
    mf_phone_msg_event_cd = cv.code_value
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data[1].status = "F"
 SELECT
  FROM ops2_job oj,
   ops2_sched_job osj,
   ops2_sched_step oss
  PLAN (oj
   WHERE oj.job_name="SCH Cancel Appointment Inbox Message"
    AND oj.active_ind=1
    AND oj.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (osj
   WHERE osj.ops2_job_id=oj.ops2_job_id
    AND osj.active_ind=1
    AND osj.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (oss
   WHERE oss.ops2_sched_job_id=osj.ops2_sched_job_id
    AND oss.status_cd=mf_ops_complete_cd
    AND oss.active_ind=1
    AND oss.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY oss.actual_end_dt_tm DESC
  HEAD REPORT
   ms_beg_dt_tm = trim(format(cnvtlookbehind("4,D",oss.actual_end_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d")),
   ms_beg_dt_cncl = trim(format(cnvtlookbehind("30,MIN",oss.actual_end_dt_tm),
     "dd-mmm-yyyy hh:mm:ss;;d")), ms_beg_dt_noshow_hld = trim(format(cnvtlookbehind("3,D",oss
      .actual_end_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d"))
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_beg_dt_tm = trim(format(cnvtdatetime((curdate - 4),0),"dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_beg_dt_cncl = trim(format(cnvtlookbehind("30,MIN",cnvtdatetime(curdate,curtime)),
    "dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_beg_dt_noshow_hld = trim(format(cnvtlookbehind("3,D",cnvtdatetime(curdate,curtime)),
    "dd-mmm-yyyy hh:mm:ss;;d"))
 ENDIF
 SET ms_end_dt_tm = trim(format(cnvtdatetime((curdate+ 1),0),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL echo(build2("ms_beg_dt_tm: ",ms_beg_dt_tm))
 CALL echo(build2("ms_beg_dt_cncl: ",ms_beg_dt_cncl))
 CALL echo(build2("ms_beg_dt_noshow_hld: ",ms_beg_dt_noshow_hld))
 CALL echo(build2("ms_end_dt_tm: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM sch_event_action sea,
   sch_appt s,
   sch_booking sb,
   sch_event_attach sord,
   orders o,
   order_action oa,
   prsnl pr,
   encounter e,
   person p,
   encntr_alias fin
  PLAN (sea
   WHERE sea.action_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND sea.action_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND sea.active_ind=1
    AND sea.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
    AND ((sea.action_meaning IN ("HOLD", "NOSHOW")) OR (sea.action_meaning="CANCEL"
    AND sea.sch_reason_cd=mf_cancelnotifprov_cd)) )
   JOIN (s
   WHERE s.sch_event_id=sea.sch_event_id
    AND s.sch_state_cd IN (mf_canceled_cd, mf_hold_cd, mf_noshow_cd, mf_pending_cd)
    AND s.active_ind=1
    AND s.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (sb
   WHERE sb.booking_id=s.booking_id
    AND sb.active_ind=1
    AND sb.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (sord
   WHERE sord.sch_event_id=s.sch_event_id
    AND sord.active_ind=1
    AND sord.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (o
   WHERE o.order_id=sord.order_id
    AND o.catalog_type_cd=mf_rad_cat_type_cd
    AND o.active_ind=1)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_order_cd)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id)
   JOIN (e
   WHERE e.encntr_id=s.encntr_id)
   JOIN (p
   WHERE p.person_id=s.person_id)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=mf_fin_cd
    AND fin.active_ind=1
    AND fin.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  ORDER BY s.person_id, s.encntr_id, pr.person_id,
   s.sch_event_id, o.order_id
  HEAD REPORT
   ml_knt = 0
  HEAD s.person_id
   null
  HEAD s.encntr_id
   null
  HEAD pr.person_id
   null
  HEAD s.sch_event_id
   ml_knt += 1, m_appts->l_knt = ml_knt, m0 = alterlist(m_appts->lst,ml_knt),
   m_appts->lst[ml_knt].f_person_id = s.person_id, m_appts->lst[ml_knt].f_encntr_id = s.encntr_id,
   m_appts->lst[ml_knt].f_cancel_person_id = sea.action_prsnl_id,
   m_appts->lst[ml_knt].d_beg_dt_tm = cnvtdatetime(s.beg_dt_tm), m_appts->lst[ml_knt].s_cancel_reason
    = trim(uar_get_code_display(sea.sch_reason_cd)), m_appts->lst[ml_knt].s_fin = fin.alias,
   m_appts->lst[ml_knt].f_sch_event_id = s.sch_event_id, m_appts->lst[ml_knt].s_appt_desc = trim(
    uar_get_code_display(sb.appt_type_cd))
   IF (sea.action_meaning="CANCEL")
    IF (sea.action_dt_tm >= cnvtdatetime(ms_beg_dt_cncl))
     m_appts->lst[ml_knt].s_msg_subject = concat("Canceled Appointment - ",trim(m_appts->lst[ml_knt].
       s_appt_desc)," for Account#: ",trim(fin.alias)," on ",
      format(s.beg_dt_tm,"mm/dd/yy HH:mm;;D")), m_appts->lst[ml_knt].s_message = concat(
      "Your patient just cancelled a radiology exam and at this",
      " time the appointment has not been rescheduled. Please contact",
      " your patient and have them call the scheduling department if",
      " appointment needs to be rescheduled.",char(10),
      char(10),"Canceled Appointment: ",trim(m_appts->lst[ml_knt].s_appt_desc),char(10),"Account#: ",
      trim(m_appts->lst[ml_knt].s_fin),char(10),"Scheduled Date: ",trim(format(m_appts->lst[ml_knt].
        d_beg_dt_tm,"mm/dd/yyyy HH:mm;;D")))
    ENDIF
   ELSEIF (sea.action_meaning="HOLD")
    IF (sea.action_dt_tm < cnvtdatetime(ms_beg_dt_noshow_hld))
     m_appts->lst[ml_knt].s_msg_subject = concat("Appointment On Hold - ",trim(m_appts->lst[ml_knt].
       s_appt_desc)," for Account#: ",trim(fin.alias)," on ",
      format(s.beg_dt_tm,"mm/dd/yy HH:mm;;D")), m_appts->lst[ml_knt].s_message = concat(
      "Your patient just placed a radiology exam on hold and at this",
      " time the appointment has not been rescheduled. Please contact",
      " your patient and have them call the scheduling department if",
      " appointment needs to be rescheduled.",char(10),
      char(10),"Appointment On Hold: ",trim(m_appts->lst[ml_knt].s_appt_desc),char(10),"Account#: ",
      trim(m_appts->lst[ml_knt].s_fin),char(10),"Scheduled Date: ",trim(format(m_appts->lst[ml_knt].
        d_beg_dt_tm,"mm/dd/yyyy HH:mm;;D")))
    ENDIF
   ELSEIF (sea.action_meaning="NOSHOW")
    IF (sea.action_dt_tm < cnvtdatetime(ms_beg_dt_noshow_hld))
     m_appts->lst[ml_knt].s_msg_subject = concat("Appointment No Show - ",trim(m_appts->lst[ml_knt].
       s_appt_desc)," for Account#: ",trim(fin.alias)," on ",
      format(s.beg_dt_tm,"mm/dd/yy HH:mm;;D")), m_appts->lst[ml_knt].s_message = concat(
      "Your patient did not show for a radiology exam and at this",
      " time the appointment has not been rescheduled. Please contact",
      " your patient and have them call the scheduling department if",
      " appointment needs to be rescheduled.",char(10),
      char(10),"No Show Appointment: ",trim(m_appts->lst[ml_knt].s_appt_desc),char(10),"Account#: ",
      trim(m_appts->lst[ml_knt].s_fin),char(10),"Scheduled Date: ",trim(format(m_appts->lst[ml_knt].
        d_beg_dt_tm,"mm/dd/yyyy HH:mm;;D")))
    ENDIF
   ENDIF
   m_appts->lst[ml_knt].f_order_provider_id = oa.order_provider_id, m_appts->lst[ml_knt].f_order_id
    = o.order_id
  WITH nocounter
 ;end select
 CALL echorecord(m_appts)
 IF ( NOT ((m_appts->l_knt > 0)))
  SET reply->ops_event = "Ops Job completed successfully - no messages sent"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Ops Job completed successfully - no messages sent"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  person_id = m_appts->lst[d1.seq].f_person_id, encntr_id = m_appts->lst[d1.seq].f_encntr_id,
  sch_event_id = m_appts->lst[d1.seq].f_sch_event_id,
  order_provider_id = m_appts->lst[d1.seq].f_order_provider_id
  FROM (dummyt d1  WITH seq = m_appts->l_knt),
   dummyt d2,
   task_activity ta,
   task_activity_assignment taa
  PLAN (d1
   WHERE (m_appts->lst[d1.seq].s_msg_subject > " ")
    AND (m_appts->lst[d1.seq].f_order_provider_id > 0.00))
   JOIN (d2)
   JOIN (ta
   WHERE (ta.person_id=m_appts->lst[d1.seq].f_person_id)
    AND (ta.encntr_id=m_appts->lst[d1.seq].f_encntr_id)
    AND (ta.msg_subject=m_appts->lst[d1.seq].s_msg_subject))
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND (taa.assign_prsnl_id=m_appts->lst[d1.seq].f_order_provider_id))
  ORDER BY d1.seq, person_id, encntr_id
  HEAD REPORT
   ml_knt = 0
  HEAD d1.seq
   ml_knt += 1, m_schcontent->l_knt = ml_knt, m0 = alterlist(m_schcontent->lst,ml_knt),
   m_schcontent->lst[ml_knt].f_person_id = m_appts->lst[d1.seq].f_person_id, m_schcontent->lst[ml_knt
   ].f_encntr_id = m_appts->lst[d1.seq].f_encntr_id, m_schcontent->lst[ml_knt].f_order_id = m_appts->
   lst[d1.seq].f_order_id,
   m_schcontent->lst[ml_knt].f_event_cd = mf_phone_msg_event_cd, m_schcontent->lst[ml_knt].
   f_task_type_cd = mf_phone_msg_cd, m_schcontent->lst[ml_knt].n_save_to_chart_ind = 1,
   m_schcontent->lst[ml_knt].f_cancel_person_id = m_appts->lst[d1.seq].f_cancel_person_id,
   m_schcontent->lst[ml_knt].s_subject = m_appts->lst[d1.seq].s_msg_subject, m_schcontent->lst[ml_knt
   ].s_message = m_appts->lst[d1.seq].s_message,
   ml_pknt = 0, ml_pknt += 1, stat = alterlist(m_schcontent->lst[ml_knt].assign_prsnl_list,ml_pknt),
   m_schcontent->lst[ml_knt].assign_prsnl_list[ml_pknt].f_assign_prsnl_id = m_appts->lst[d1.seq].
   f_order_provider_id
  WITH outerjoin = d2, dontexist, nocounter
 ;end select
 CALL echorecord(m_schcontent)
 IF ((m_schcontent->l_knt > 0))
  FOR (ml_mloop = 1 TO m_schcontent->l_knt)
    SET m_msgcontent->f_person_id = m_schcontent->lst[ml_mloop].f_person_id
    SET m_msgcontent->f_encntr_id = m_schcontent->lst[ml_mloop].f_encntr_id
    SET m_msgcontent->f_order_id = m_schcontent->lst[ml_mloop].f_order_id
    SET m_msgcontent->s_subject = m_schcontent->lst[ml_mloop].s_subject
    SET m_msgcontent->s_message = m_schcontent->lst[ml_mloop].s_message
    SET m_msgcontent->f_event_cd = m_schcontent->lst[ml_mloop].f_event_cd
    SET m_msgcontent->f_task_type_cd = m_schcontent->lst[ml_mloop].f_task_type_cd
    SET m_msgcontent->n_save_to_chart_ind = m_schcontent->lst[ml_mloop].n_save_to_chart_ind
    SET reqinfo->updt_id = m_schcontent->lst[ml_mloop].f_cancel_person_id
    SET m_msgcontent->f_msg_sender_prsnl_id = m_schcontent->lst[ml_mloop].f_cancel_person_id
    FOR (ml_aloop = 1 TO size(m_schcontent->lst[ml_mloop].assign_prsnl_list,5))
     SET m0 = alterlist(m_msgcontent->assign_prsnl_list,ml_aloop)
     SET m_msgcontent->assign_prsnl_list[ml_aloop].f_assign_prsnl_id = m_schcontent->lst[ml_mloop].
     assign_prsnl_list[ml_aloop].f_assign_prsnl_id
    ENDFOR
    CALL echo("******* call ccl script to generate inbox message(s) ******")
    EXECUTE bhs_pc_inbox_msg  WITH replace(m_content,m_msgcontent)
    CALL echorecord(m_msgcontent)
  ENDFOR
 ENDIF
 SET reply->ops_event = "Ops Job completed successfully - messages sent"
 SET reply->status_data.subeventstatus[1].targetobjectvalue =
 "Ops Job completed successfully - messages sent"
#exit_script
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectname = ""
END GO
